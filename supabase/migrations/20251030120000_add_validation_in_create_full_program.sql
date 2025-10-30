-- Enforce validations in create_full_program:
-- - A program must have at least one session
-- - Each session must have at least one exercise
-- This replacement performs validation BEFORE any insert to avoid partial data.

CREATE OR REPLACE FUNCTION public.create_full_program(full_program_data jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_program_id INT;
    session_data jsonb;
    new_session_id INT;
    exercise_data jsonb;
    new_exercise_id INT;
    new_session_exercise_id INT;
    v_user_id UUID := auth.uid();
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

    -- Insert the program (after validations)
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
$$;


