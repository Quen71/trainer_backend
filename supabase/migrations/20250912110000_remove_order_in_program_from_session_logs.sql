-- Remove the order_in_program column from the session_logs table
ALTER TABLE public.session_logs DROP COLUMN order_in_program;

-- Update the create_session_log function to remove order_in_program logic
CREATE OR REPLACE FUNCTION public.create_session_log(session_log_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    new_session_log_id INT;
    round_data jsonb;
    new_round_log_id INT;
    exercise_log_data jsonb;
    v_user_id UUID := auth.uid();
    v_session_id INT;
    v_created_log jsonb;
BEGIN
    v_session_id := (session_log_data->>'session_id')::int;

    -- Verify that the user owns the original session
    IF NOT EXISTS (
        SELECT 1
        FROM public.sessions s
        JOIN public.programs p ON s.program_id = p.id
        WHERE s.id = v_session_id AND p.user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Session not found or access denied';
    END IF;

    -- Insert the main session log
    INSERT INTO public.session_logs (user_id, session_id, started_at, ended_at)
    VALUES (
        v_user_id,
        v_session_id,
        (session_log_data->>'started_at')::timestamptz,
        (session_log_data->>'ended_at')::timestamptz
    )
    RETURNING id INTO new_session_log_id;

    -- Loop through rounds
    FOR round_data IN SELECT * FROM jsonb_array_elements(session_log_data->'rounds')
    LOOP
        -- Insert the round log
        INSERT INTO public.round_logs (session_log_id, round_number, order_in_session_log)
        VALUES (
            new_session_log_id,
            (round_data->>'round_number')::int,
            (round_data->>'order_in_session_log')::int
        )
        RETURNING id INTO new_round_log_id;

        -- Loop through exercise logs in the round
        FOR exercise_log_data IN SELECT * FROM jsonb_array_elements(round_data->'exercises')
        LOOP
            -- Insert the exercise log
            INSERT INTO public.exercises_logs (round_log_id, session_exercise_id, performance, order_in_round_log)
            VALUES (
                new_round_log_id,
                (exercise_log_data->>'session_exercise_id')::int,
                exercise_log_data,
                (exercise_log_data->>'order_in_round_log')::int
            );
        END LOOP;
    END LOOP;

    -- Fetch and build the complete SessionLog object to return
    SELECT
        jsonb_build_object(
            'id', sl.id,
            'session_id', sl.session_id,
            'started_at', sl.started_at,
            'ended_at', sl.ended_at,
            'type', s.type, -- For SessionLog deserialization
            'rounds', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', rl.id,
                        'round_number', rl.round_number,
                        'order_in_session_log', rl.order_in_session_log,
                        'exercises', COALESCE((
                            SELECT jsonb_agg(
                                -- The 'performance' object from the table is the ExerciseLog itself
                                el.performance || jsonb_build_object(
                                    'type', s.type,
                                    'order_in_round_log', el.order_in_round_log
                                )
                            )
                            FROM public.exercises_logs el
                            WHERE el.round_log_id = rl.id
                        ), '[]'::jsonb)
                    ) ORDER BY COALESCE(rl.order_in_session_log, rl.round_number) ASC
                )
                FROM public.round_logs rl
                WHERE rl.session_log_id = sl.id
            ), '[]'::jsonb)
        )
    INTO v_created_log
    FROM public.session_logs sl
    JOIN public.sessions s ON sl.session_id = s.id
    WHERE sl.id = new_session_log_id;

    -- Return the created log directly for consistency
    RETURN v_created_log;
END;
$function$;

-- Update get_user_sessions_logs function to remove order_in_program
CREATE OR REPLACE FUNCTION public.get_user_sessions_logs(page_number integer, page_size integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    RETURN (
        SELECT jsonb_agg(log_json)
        FROM (
            SELECT
                jsonb_build_object(
                    'id', sl.id,
                    'session_id', sl.session_id,
                    'started_at', sl.started_at,
                    'ended_at', sl.ended_at,
                    'type', s.type, -- Crucial for deserialization
                    'rounds', COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', rl.id,
                                'round_number', rl.round_number,
                                'order_in_session_log', rl.order_in_session_log,
                                'exercises', COALESCE((
                                    SELECT jsonb_agg(
                                        -- Inject session type and exercise name for full deserialization
                                        el.performance || jsonb_build_object(
                                            'type', s.type,
                                            'order_in_round_log', el.order_in_round_log,
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
                            ) ORDER BY COALESCE(rl.order_in_session_log, rl.round_number) ASC
                        )
                        FROM public.round_logs rl
                        WHERE rl.session_log_id = sl.id
                    ), '[]'::jsonb)
                ) as log_json
            FROM public.session_logs sl
            JOIN public.sessions s ON sl.session_id = s.id
            JOIN public.programs p ON s.program_id = p.id
            WHERE p.user_id = v_user_id
            ORDER BY sl.started_at DESC
            LIMIT page_size
            OFFSET page_number * page_size
        ) as paginated_logs
    );
END;
$function$;
