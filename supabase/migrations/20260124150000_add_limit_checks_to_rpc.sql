-- Migration: Add subscription limit checks to RPC functions
-- Description: Adds limit validation to create_full_program, add_session_to_program,
--              and update_full_session to prevent exceeding subscription limits.
--              Uses the reusable check_user_can_create_resource() function (DRY).
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. Restore create_full_program from migration 20251030120000_add_validation_in_create_full_program.sql
-- 2. Restore add_session_to_program from migration 20250815152351_update_program_functions_with_favorite.sql
-- 3. Restore update_full_session from previous version (check migrations or database)

-- Step 1: Update create_full_program to check limits
CREATE OR REPLACE FUNCTION public.create_full_program(full_program_data jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    new_program_id INT;
    session_data jsonb;
    new_session_id INT;
    exercise_data jsonb;
    new_exercise_id INT;
    new_session_exercise_id INT;
    v_user_id UUID := auth.uid();
    v_limits jsonb;
    v_sessions_count INT;
    v_max_sessions_per_program INT;
BEGIN
    -- Validate: program must have at least one session
    IF full_program_data ? 'sessions' IS FALSE
       OR jsonb_typeof(full_program_data->'sessions') <> 'array'
       OR jsonb_array_length(full_program_data->'sessions') = 0 THEN
        RAISE EXCEPTION 'A program must have at least one session';
    END IF;

    -- Validate: each session must have at least one exercise
    IF EXISTS (
        SELECT 1
        FROM jsonb_array_elements(full_program_data->'sessions') s
        WHERE s ? 'exercises' IS FALSE
          OR jsonb_typeof(s->'exercises') <> 'array'
          OR jsonb_array_length(s->'exercises') = 0
    ) THEN
        RAISE EXCEPTION 'A session must have at least one exercise';
    END IF;

    -- Check subscription limits BEFORE any insert
    -- This will raise an exception if max_programs limit is exceeded
    v_limits := public.check_user_can_create_resource(v_user_id, 'programs');
    
    -- Get max_sessions_per_program limit
    v_max_sessions_per_program := (v_limits->'limits'->>'max_sessions_per_program')::int;
    v_sessions_count := jsonb_array_length(full_program_data->'sessions');

    -- Check if number of sessions exceeds limit
    IF v_max_sessions_per_program IS NOT NULL AND v_sessions_count > v_max_sessions_per_program THEN
        RAISE EXCEPTION 'LIMIT_EXCEEDED:MAX_SESSIONS:%s/%s Ce programme dépasse la limite de %s séances par programme. Demandé: %s',
            v_sessions_count, v_max_sessions_per_program, v_max_sessions_per_program, v_sessions_count;
    END IF;

    -- Check exercises limit (count all unique exercises in all sessions)
    DECLARE
        v_total_exercises INT := 0;
        v_max_exercises INT := (v_limits->'limits'->>'max_exercises')::int;
        v_current_exercises INT := (v_limits->'usage'->>'exercises_count')::int;
        v_new_unique_exercises INT := 0;
    BEGIN
        -- Count unique new exercises (that don't already exist for this user)
        SELECT COUNT(DISTINCT ex->>'name')::int INTO v_new_unique_exercises
        FROM jsonb_array_elements(full_program_data->'sessions') s,
             jsonb_array_elements(s->'exercises') ex
        WHERE NOT EXISTS (
            SELECT 1 FROM public.exercises
            WHERE user_id = v_user_id AND name = ex->>'name'
        );

        -- Check if adding these exercises would exceed limit
        IF v_max_exercises IS NOT NULL AND (v_current_exercises + v_new_unique_exercises) > v_max_exercises THEN
            RAISE EXCEPTION 'LIMIT_EXCEEDED:MAX_EXERCISES:%s/%s Ajouter ces exercices dépasserait la limite de %s exercices. Actuel: %s, À ajouter: %s',
                (v_current_exercises + v_new_unique_exercises), v_max_exercises, v_max_exercises, v_current_exercises, v_new_unique_exercises;
        END IF;
    END;

    -- Insert the program (after all validations)
    INSERT INTO programs (user_id, name, description)
    VALUES (
        v_user_id,
        full_program_data->>'name',
        full_program_data->>'description'
    )
    RETURNING id INTO new_program_id;

    -- Loop through sessions
    FOR session_data IN SELECT * FROM jsonb_array_elements(full_program_data->'sessions')
    LOOP
        -- Insert the session
        INSERT INTO sessions (program_id, name, "order_in_program", type, style, parameters)
        VALUES (
            new_program_id,
            session_data->>'name',
            (session_data->>'order_in_program')::INT,
            (session_data->>'type')::session_type,
            (session_data->>'style')::session_style,
            CASE
                WHEN (session_data->>'type')::session_type = 'AMRAP' THEN
                    jsonb_build_object('duration', (session_data->>'duration')::bigint)
                WHEN (session_data->>'type')::session_type IN ('EMOM', 'HIIT') THEN
                    jsonb_build_object('round_number', (session_data->>'round_number')::int)
                ELSE '{}'::jsonb
            END
        )
        RETURNING id INTO new_session_id;

        -- Loop through exercises
        FOR exercise_data IN SELECT * FROM jsonb_array_elements(session_data->'exercises')
        LOOP
            -- Find or create the exercise FOR THE CURRENT USER
            INSERT INTO exercises (user_id, name)
            VALUES (v_user_id, exercise_data->>'name')
            ON CONFLICT (user_id, name) DO NOTHING;

            SELECT id INTO new_exercise_id FROM exercises WHERE user_id = v_user_id AND name = exercise_data->>'name';

            -- Insert into session_exercises
            INSERT INTO session_exercises (session_id, exercise_id, "order_in_session", parameters)
            VALUES (
                new_session_id,
                new_exercise_id,
                (exercise_data->>'order_in_session')::INT,
                (exercise_data->'parameters')::jsonb
            )
            RETURNING id INTO new_session_exercise_id;

            -- Always create an initial progression record
            INSERT INTO exercise_progressions (user_id, session_exercise_id, next_objective_parameters)
            VALUES (
                v_user_id,
                new_session_exercise_id,
                COALESCE(
                    (exercise_data->'progression'->0->'next_objective_parameters')::jsonb,
                    (exercise_data->'parameters')::jsonb
                )
            );
        END LOOP;
    END LOOP;

    -- Return the complete program data using the helper function
    RETURN (
        SELECT get_full_program_by_id(new_program_id)
    );
END;
$$;

-- Step 2: Update add_session_to_program to check limits
CREATE OR REPLACE FUNCTION public.add_session_to_program(p_program_id integer, session_data jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    new_session_id INT;
    exercise_data jsonb;
    new_exercise_id INT;
    new_session_exercise_id INT;
    new_order_in_program INT;
    v_user_id UUID := auth.uid();
    v_limits jsonb;
BEGIN
    -- Verify ownership of the program
    IF NOT EXISTS (
        SELECT 1 FROM programs
        WHERE id = p_program_id AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Program not found or access denied';
    END IF;

    -- Check subscription limits BEFORE insert
    -- This will raise an exception if max_sessions_per_program limit is exceeded
    v_limits := public.check_user_can_create_resource(v_user_id, 'sessions_per_program', p_program_id);

    -- Check exercises limit if new exercises are being added
    IF session_data ? 'exercises' AND jsonb_typeof(session_data->'exercises') = 'array' THEN
        DECLARE
            v_new_exercises_count INT;
            v_max_exercises INT := (v_limits->'limits'->>'max_exercises')::int;
            v_current_exercises INT := (v_limits->'usage'->>'exercises_count')::int;
        BEGIN
            -- Count unique new exercises (that don't already exist for this user)
            SELECT COUNT(DISTINCT ex->>'name')::int INTO v_new_exercises_count
            FROM jsonb_array_elements(session_data->'exercises') ex
            WHERE NOT EXISTS (
                SELECT 1 FROM public.exercises
                WHERE user_id = v_user_id AND name = ex->>'name'
            );

            -- Check if adding these exercises would exceed limit
            IF v_max_exercises IS NOT NULL AND (v_current_exercises + v_new_exercises_count) > v_max_exercises THEN
                RAISE EXCEPTION 'LIMIT_EXCEEDED:MAX_EXERCISES:%s/%s Ajouter ces exercices dépasserait la limite de %s exercices. Actuel: %s, À ajouter: %s',
                    (v_current_exercises + v_new_exercises_count), v_max_exercises, v_max_exercises, v_current_exercises, v_new_exercises_count;
            END IF;
        END;
    END IF;

    -- Determine the order for the new session
    SELECT COALESCE(MAX(order_in_program), 0) + 1
    INTO new_order_in_program
    FROM sessions
    WHERE program_id = p_program_id;

    -- Insert the session
    INSERT INTO sessions (program_id, name, order_in_program, type, style, parameters)
    VALUES (
        p_program_id,
        session_data->>'name',
        new_order_in_program,
        (session_data->>'type')::session_type,
        (session_data->>'style')::session_style,
        CASE
            WHEN (session_data->>'type')::session_type = 'AMRAP' THEN
                jsonb_build_object('duration', (session_data->>'duration')::bigint)
            WHEN (session_data->>'type')::session_type IN ('EMOM', 'HIIT') THEN
                jsonb_build_object('round_number', (session_data->>'round_number')::int)
            ELSE '{}'::jsonb
        END
    )
    RETURNING id INTO new_session_id;

    -- Loop through exercises for the new session
    FOR exercise_data IN SELECT * FROM jsonb_array_elements(session_data->'exercises')
    LOOP
        -- Find or create the exercise for the current user
        INSERT INTO exercises (user_id, name)
        VALUES (v_user_id, exercise_data->>'name')
        ON CONFLICT (user_id, name) DO NOTHING;

        SELECT id INTO new_exercise_id FROM exercises WHERE user_id = v_user_id AND name = exercise_data->>'name';

        -- Insert into session_exercises
        INSERT INTO session_exercises (session_id, exercise_id, order_in_session, parameters)
        VALUES (
            new_session_id,
            new_exercise_id,
            (exercise_data->>'order_in_session')::INT,
            (exercise_data->'parameters')::jsonb
        )
        RETURNING id INTO new_session_exercise_id;

        -- Create initial progression record
        INSERT INTO exercise_progressions (user_id, session_exercise_id, next_objective_parameters)
        VALUES (
            v_user_id,
            new_session_exercise_id,
            COALESCE(
                (exercise_data->'progression'->0->'next_objective_parameters')::jsonb,
                (exercise_data->'parameters')::jsonb
            )
        );
    END LOOP;

    -- Return the complete program data using the helper function
    RETURN (
        SELECT get_full_program_by_id(p_program_id)
    );
END;
$$;

-- Step 3: Update update_full_session to check exercises limit
-- Note: This function modifies an existing session, so we only check NEW exercises
CREATE OR REPLACE FUNCTION public.update_full_session(p_session_data jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_session_id INT;
    v_auth_user_id UUID := auth.uid();
    v_program_id INT;
    exercise_data jsonb;
    v_session_exercise_id INT;
    v_exercise_id INT;
    v_exercise_name TEXT;
    v_existing_exercise_ids INT[];
    v_ids_to_keep INT[] := '{}'::int[];
    v_limits jsonb;
    v_new_exercises_count INT;
    v_max_exercises INT;
    v_current_exercises INT;
BEGIN
    -- Extract session ID and verify ownership, get program_id
    v_session_id := (p_session_data->>'id')::int;
    IF v_session_id IS NULL THEN
        RAISE EXCEPTION 'Session ID is missing from the payload.';
    END IF;

    SELECT s.program_id INTO v_program_id
    FROM public.sessions s
    JOIN public.programs p ON s.program_id = p.id
    WHERE s.id = v_session_id AND p.user_id = v_auth_user_id;

    IF v_program_id IS NULL THEN
        RAISE EXCEPTION 'Session not found or access denied.';
    END IF;

    -- NEW: Validate that the session is not empty
    IF jsonb_array_length(p_session_data->'exercises') = 0 THEN
        RAISE EXCEPTION 'A session must contain at least one exercise.';
    END IF;

    -- Check exercises limit if new exercises are being added
    IF p_session_data ? 'exercises' AND jsonb_typeof(p_session_data->'exercises') = 'array' THEN
        -- Get limits
        SELECT public.get_user_limits_with_usage(v_auth_user_id) INTO v_limits;
        v_max_exercises := (v_limits->'limits'->>'max_exercises')::int;
        v_current_exercises := (v_limits->'usage'->>'exercises_count')::int;

        -- Count unique new exercises (that don't already exist for this user)
        SELECT COUNT(DISTINCT ex->>'name')::int INTO v_new_exercises_count
        FROM jsonb_array_elements(p_session_data->'exercises') ex
        WHERE NOT EXISTS (
            SELECT 1 FROM public.exercises
            WHERE user_id = v_auth_user_id AND name = ex->>'name'
        );

        -- Check if adding these exercises would exceed limit
        IF v_max_exercises IS NOT NULL AND (v_current_exercises + v_new_exercises_count) > v_max_exercises THEN
            RAISE EXCEPTION 'LIMIT_EXCEEDED:MAX_EXERCISES:%s/%s Ajouter ces exercices dépasserait la limite de %s exercices. Actuel: %s, À ajouter: %s',
                (v_current_exercises + v_new_exercises_count), v_max_exercises, v_max_exercises, v_current_exercises, v_new_exercises_count;
        END IF;
    END IF;

    -- Update session name and parameters
    UPDATE public.sessions
    SET
        name = p_session_data->>'name',
        parameters = CASE
            WHEN (p_session_data->>'type')::session_type = 'AMRAP' THEN jsonb_build_object('duration', (p_session_data->>'duration')::bigint)
            WHEN (p_session_data->>'type')::session_type IN ('EMOM', 'HIIT') THEN jsonb_build_object('round_number', (p_session_data->>'round_number')::int)
            ELSE '{}'::jsonb
        END
    WHERE id = v_session_id;

    -- Get current exercise IDs for deletion tracking
    SELECT array_agg(id) INTO v_existing_exercise_ids
    FROM public.session_exercises
    WHERE session_id = v_session_id;

    -- Loop through input exercises for UPSERT and reordering
    FOR exercise_data IN SELECT * FROM jsonb_array_elements(p_session_data->'exercises')
    LOOP
        IF exercise_data->'parameters' IS NULL THEN
            RAISE EXCEPTION 'Exercise \"%\" is missing required \"parameters\".', exercise_data->>'name';
        END IF;

        v_exercise_name := exercise_data->>'name';
        SELECT id INTO v_exercise_id
        FROM public.exercises
        WHERE user_id = v_auth_user_id AND name = v_exercise_name;

        IF v_exercise_id IS NULL THEN
            INSERT INTO public.exercises (user_id, name)
            VALUES (v_auth_user_id, v_exercise_name)
            RETURNING id INTO v_exercise_id;
        END IF;

        v_session_exercise_id := (exercise_data->>'id')::int;

        IF v_session_exercise_id IS NULL OR v_session_exercise_id = 0 THEN
            INSERT INTO public.session_exercises (session_id, exercise_id, order_in_session, parameters)
            VALUES (v_session_id, v_exercise_id, (exercise_data->>'order_in_session')::int, (exercise_data->'parameters')::jsonb)
            RETURNING id INTO v_session_exercise_id;

            INSERT INTO public.exercise_progressions (user_id, session_exercise_id, next_objective_parameters)
            VALUES (v_auth_user_id, v_session_exercise_id, COALESCE((exercise_data->'progression'->0->'next_objective_parameters')::jsonb, (exercise_data->'parameters')::jsonb));
        ELSE
            UPDATE public.session_exercises
            SET order_in_session = (exercise_data->>'order_in_session')::int,
                parameters = (exercise_data->'parameters')::jsonb
            WHERE id = v_session_exercise_id AND session_id = v_session_id;

            UPDATE public.exercise_progressions
            SET next_objective_parameters = COALESCE((exercise_data->'progression'->0->'next_objective_parameters')::jsonb, (exercise_data->'parameters')::jsonb)
            WHERE session_exercise_id = v_session_exercise_id;
        END IF;

        v_ids_to_keep := array_append(v_ids_to_keep, v_session_exercise_id);
    END LOOP;

    -- Delete removed exercises
    DELETE FROM public.session_exercises
    WHERE session_id = v_session_id AND id = ANY(COALESCE(v_existing_exercise_ids, '{}'::int[])) AND id NOT IN (SELECT unnest(v_ids_to_keep));

    -- Return response matching SessionApiResponse (program_id and session)
    RETURN jsonb_build_object(
        'program_id', v_program_id,
        'session', (
            SELECT jsonb_build_object(
                'id', s.id,
                'name', s.name,
                'order_in_program', s.order_in_program,
                'type', s.type,
                'style', s.style,
                'exercises', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', se.id,
                            'exercise_id', se.exercise_id,
                            'order_in_session', se.order_in_session,
                            'exercise', jsonb_build_object('name', e.name), -- FIX for deserialization
                            'parameters', se.parameters,
                            'progression', (
                                SELECT jsonb_agg(ep.*)
                                FROM public.exercise_progressions ep
                                WHERE ep.session_exercise_id = se.id
                            )
                        ) ORDER BY se.order_in_session
                    )
                    FROM public.session_exercises se
                    JOIN public.exercises e ON se.exercise_id = e.id
                    WHERE se.session_id = s.id
                )
            ) ||
            CASE
                WHEN s.type = 'AMRAP' THEN jsonb_build_object('duration', s.parameters->'duration')
                WHEN s.type IN ('EMOM', 'HIIT') THEN jsonb_build_object('round_number', s.parameters->'round_number')
                ELSE '{}'::jsonb
            END
            FROM public.sessions s
            WHERE s.id = v_session_id
        )
    );
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.create_full_program(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_session_to_program(integer, jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_full_session(jsonb) TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.create_full_program(jsonb) IS 
'Creates a new program with all sessions and exercises.
Includes subscription limit checks before any insert to prevent exceeding limits.';

COMMENT ON FUNCTION public.add_session_to_program(integer, jsonb) IS 
'Adds a new session to an existing program.
Includes subscription limit checks for max_sessions_per_program and max_exercises.';

COMMENT ON FUNCTION public.update_full_session(jsonb) IS 
'Updates an existing session with new exercises and parameters.
Includes subscription limit checks for new exercises only (not existing ones).';
