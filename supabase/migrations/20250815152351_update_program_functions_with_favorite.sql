-- This migration updates existing RPC functions to include the 'is_favorite' attribute
-- when returning program data. This ensures a consistent data shape across the API.

-- Function: get_user_programs
-- Updates the function to add 'is_favorite' to each program object in the returned list.
CREATE OR REPLACE FUNCTION public.get_user_programs(page_number integer, page_size integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    RETURN (
        SELECT jsonb_agg(program_json)
        FROM (
            SELECT jsonb_build_object(
                'id', p.id,
                'user_id', p.user_id,
                'name', p.name,
                'description', p.description,
                'created_at', p.created_at,
                'updated_at', p.updated_at,
                'is_favorite', EXISTS (
                    SELECT 1
                    FROM favorite_programs fp
                    WHERE fp.program_id = p.id AND fp.user_id = v_user_id
                ),
                'sessions', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
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
                                        'exercise', jsonb_build_object('name', e.name),
                                        'parameters', se.parameters,
                                        'progression', (
                                            SELECT jsonb_agg(ep.*)
                                            FROM exercise_progressions ep
                                            WHERE ep.session_exercise_id = se.id
                                        )
                                    )
                                )
                                FROM session_exercises se
                                JOIN exercises e ON se.exercise_id = e.id
                                WHERE se.session_id = s.id
                            )
                        )
                        ||
                        CASE
                            WHEN s.type = 'AMRAP' THEN
                                jsonb_build_object('duration', s.parameters->'duration')
                            WHEN s.type IN ('EMOM', 'HIIT') THEN
                                jsonb_build_object('round_number', s.parameters->'round_number')
                            ELSE
                                '{}'::jsonb
                        END
                    )
                    FROM sessions s
                    WHERE s.program_id = p.id
                )
            ) as program_json
            FROM programs p
            WHERE p.user_id = v_user_id
            ORDER BY p.created_at DESC
            LIMIT page_size
            OFFSET page_number * page_size
        ) as paginated_programs
    );
END;
$function$;

-- Function: create_full_program
-- Updates the return statement to use the helper function 'get_full_program_by_id',
-- which correctly includes the 'is_favorite' status.
CREATE OR REPLACE FUNCTION public.create_full_program(full_program_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    new_program_id INT;
    session_data jsonb;
    new_session_id INT;
    exercise_data jsonb;
    new_exercise_id INT;
    new_session_exercise_id INT;
    v_user_id UUID := auth.uid();
BEGIN
    -- Insert the program
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
                ELSE
                    '{}'::jsonb
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

            -- Always create an initial progression record, now including the user_id
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
$function$;

-- Function: add_session_to_program
-- Updates the return statement to use the helper function 'get_full_program_by_id'.
CREATE OR REPLACE FUNCTION public.add_session_to_program(p_program_id integer, session_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    new_session_id INT;
    exercise_data jsonb;
    new_exercise_id INT;
    new_session_exercise_id INT;
    new_order_in_program INT;
    v_user_id UUID := auth.uid();
BEGIN
    -- Verify ownership of the program
    IF NOT EXISTS (
        SELECT 1 FROM programs
        WHERE id = p_program_id AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Program not found or access denied';
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

        -- Insert into session_exercises using the correct key 'parameters'
        INSERT INTO session_exercises (session_id, exercise_id, order_in_session, parameters)
        VALUES (
            new_session_id,
            new_exercise_id,
            (exercise_data->>'order_in_session')::INT,
            (exercise_data->'parameters')::jsonb
        )
        RETURNING id INTO new_session_exercise_id;

        -- Create initial progression record using the correct keys
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
$function$;


-- Function: delete_session_from_program
-- Updates the return statement to use the helper function 'get_full_program_by_id'.
CREATE OR REPLACE FUNCTION public.delete_session_from_program(p_session_id integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_program_id INT;
    v_user_id UUID := auth.uid();
    session_count INT;
BEGIN
    -- Find the program_id for the session to be deleted and verify ownership
    SELECT program_id INTO v_program_id
    FROM sessions s
    JOIN programs p ON s.program_id = p.id
    WHERE s.id = p_session_id AND p.user_id = v_user_id;

    IF v_program_id IS NULL THEN
        RAISE EXCEPTION 'Session not found or access denied';
    END IF;

    -- Check if it's the last session in the program
    SELECT COUNT(*) INTO session_count
    FROM sessions
    WHERE program_id = v_program_id;

    IF session_count <= 1 THEN
        RAISE EXCEPTION 'Cannot delete the last session of a program.';
    END IF;

    -- Delete the session (cascades to session_exercises and exercise_progressions)
    DELETE FROM sessions WHERE id = p_session_id;

    -- Re-order the remaining sessions
    WITH ranked_sessions AS (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY order_in_program) as new_order
        FROM sessions
        WHERE program_id = v_program_id
    )
    UPDATE sessions s
    SET order_in_program = rs.new_order
    FROM ranked_sessions rs
    WHERE s.id = rs.id;

    -- Return the complete updated program data using the helper function
    RETURN (
       SELECT get_full_program_by_id(v_program_id)
    );
END;
$function$;


-- Function: update_full_program
-- Updates the return statement to use the helper function 'get_full_program_by_id'.
CREATE OR REPLACE FUNCTION public.update_full_program(full_program_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    program_id_to_update int;
    session_data jsonb;
    v_user_id UUID := auth.uid();
BEGIN
    -- 1. Extract program ID and verify ownership
    program_id_to_update := (full_program_data->>'id')::int;
    IF NOT EXISTS (
        SELECT 1 FROM programs
        WHERE id = program_id_to_update AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Program not found or access denied';
    END IF;

    -- 2. Update program metadata
    UPDATE programs
    SET
        name = full_program_data->>'name',
        description = full_program_data->>'description'
    WHERE id = program_id_to_update;

    -- 3. Loop through sessions from input and update their order
    FOR session_data IN SELECT * FROM jsonb_array_elements(full_program_data->'sessions')
    LOOP
        UPDATE sessions
        SET order_in_program = (session_data->>'order_in_program')::int
        WHERE id = (session_data->>'id')::int AND program_id = program_id_to_update;
    END LOOP;

    -- 4. Return the complete program data using the helper function.
    RETURN (
        SELECT get_full_program_by_id(program_id_to_update)
    );
END;
$function$;

-- Function: get_profile_with_initial_data
-- Updates the function to add 'is_favorite' to each program object in the nested list.
CREATE OR REPLACE FUNCTION public.get_profile_with_initial_data(p_limit integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    RETURN (
        SELECT
            jsonb_build_object(
                'id', p.id,
                'role', p.role,
                'full_name', p.full_name,
                'created_at', p.created_at,
                'updated_at', p.updated_at,
                'username', p.username,
                'programs', COALESCE(
                    (
                        SELECT jsonb_agg(program_data)
                        FROM (
                            SELECT
                                jsonb_build_object(
                                    'id', prog.id,
                                    'user_id', prog.user_id,
                                    'name', prog.name,
                                    'description', prog.description,
                                    'created_at', prog.created_at,
                                    'updated_at', prog.updated_at,
                                    'is_favorite', EXISTS (
                                        SELECT 1
                                        FROM favorite_programs fp
                                        WHERE fp.program_id = prog.id AND fp.user_id = v_user_id
                                    ),
                                    'sessions', (
                                        SELECT jsonb_agg(
                                            jsonb_build_object(
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
                                                            'exercise', jsonb_build_object('name', e.name),
                                                            'parameters', se.parameters,
                                                            'progression', (
                                                                SELECT jsonb_agg(ep.*)
                                                                FROM exercise_progressions ep
                                                                WHERE ep.session_exercise_id = se.id
                                                            )
                                                        )
                                                    )
                                                    FROM session_exercises se
                                                    JOIN exercises e ON se.exercise_id = e.id
                                                    WHERE se.session_id = s.id
                                                )
                                            ) ||
                                            CASE
                                                WHEN s.type = 'AMRAP' THEN jsonb_build_object('duration', s.parameters->'duration')
                                                WHEN s.type IN ('EMOM', 'HIIT') THEN jsonb_build_object('round_number', s.parameters->'round_number')
                                                ELSE '{}'::jsonb
                                            END
                                        )
                                        FROM sessions s
                                        WHERE s.program_id = prog.id
                                    )
                                ) as program_data
                            FROM programs prog
                            WHERE prog.user_id = v_user_id
                            ORDER BY prog.created_at DESC
                            LIMIT p_limit
                        ) as limited_programs
                    ),
                    '[]'::jsonb
                ),
                'session_logs', COALESCE(
                    (
                        SELECT jsonb_agg(log_data)
                        FROM (
                            SELECT
                                jsonb_build_object(
                                    'id', sl.id,
                                    'session_id', sl.session_id,
                                    'started_at', sl.started_at,
                                    'ended_at', sl.ended_at,
                                    'type', s.type,
                                    'rounds', COALESCE((
                                        SELECT jsonb_agg(
                                            jsonb_build_object(
                                                'id', rl.id,
                                                'round_number', rl.round_number,
                                                'exercises', COALESCE((
                                                    SELECT jsonb_agg(
                                                        el.performance || jsonb_build_object(
                                                            'type', s.type,
                                                            'exercise_name', (
                                                                SELECT ex.name
                                                                FROM public.session_exercises se
                                                                JOIN public.exercises ex ON se.exercise_id = ex.id
                                                                WHERE se.id = el.session_exercise_id
                                                            )
                                                        )
                                                    )
                                                    FROM public.exercises_logs el
                                                    WHERE el.round_log_id = rl.id
                                                ), '[]'::jsonb)
                                            ) ORDER BY rl.round_number
                                        )
                                        FROM public.round_logs rl
                                        WHERE rl.session_log_id = sl.id
                                    ), '[]'::jsonb)
                                ) as log_data
                            FROM public.session_logs sl
                            JOIN public.sessions s ON sl.session_id = s.id
                            WHERE sl.user_id = v_user_id
                            ORDER BY sl.started_at DESC
                            LIMIT p_limit
                        ) as limited_logs
                    ),
                    '[]'::jsonb
                )
            )
        FROM
            public.profiles p
        WHERE
            p.id = v_user_id
    );
END;
$$;
