-- This migration fixes the create_session_log function by using the correct
-- column name 'next_objective_parameters' from the 'exercise_progressions' table.
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
    v_session_preview jsonb;
    v_updated_session_preview jsonb;
    first_round_exercises jsonb;
    exercise_log jsonb;
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
        INSERT INTO public.round_logs (session_log_id, round_number)
        VALUES (
            new_session_log_id,
            (round_data->>'round_number')::int
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
            'name', s.name, -- Add session name
            'started_at', sl.started_at,
            'ended_at', sl.ended_at,
            'type', s.type, -- For SessionLog deserialization
            'rounds', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', rl.id,
                        'round_number', rl.round_number,
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
                    ) ORDER BY rl.round_number ASC
                )
                FROM public.round_logs rl
                WHERE rl.session_log_id = sl.id
            ), '[]'::jsonb)
        )
    INTO v_created_log
    FROM public.session_logs sl
    JOIN public.sessions s ON sl.session_id = s.id
    WHERE sl.id = new_session_log_id;
    -- Build the original session object for the preview
    SELECT
        jsonb_build_object(
            'id', s.id,
            'program_id', s.program_id,
            'name', s.name,
            'order_in_program', s.order_in_program,
            'type', s.type,
            'style', s.style,
            'parameters', s.parameters,
            'exercises', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', se.id,
                        'exercise_id', se.exercise_id,
                        'name', e.name,
                        'order_in_session', se.order_in_session,
                        'template_parameters', se.parameters,
                        'objective_parameters', ep.next_objective_parameters, -- Use the correct column name
                        'type', s.type
                    ) ORDER BY se.order_in_session
                )
                FROM public.session_exercises se
                JOIN public.exercises e ON se.exercise_id = e.id
                LEFT JOIN public.exercise_progressions ep ON se.id = ep.session_exercise_id AND ep.user_id = v_user_id
                WHERE se.session_id = s.id
            ), '[]'::jsonb)
        )
    INTO v_session_preview
    FROM public.sessions s
    WHERE s.id = v_session_id;
    -- Create the updated session preview
    v_updated_session_preview := v_session_preview;
    first_round_exercises := (session_log_data->'rounds'->0->'exercises');
    FOR exercise_log IN SELECT * FROM jsonb_array_elements(first_round_exercises)
    LOOP
        DECLARE
            exercise_index INT;
            session_exercise_id_to_find INT;
        BEGIN
            session_exercise_id_to_find := (exercise_log->>'session_exercise_id')::int;
            
            SELECT idx - 1 INTO exercise_index
            FROM jsonb_array_elements(v_updated_session_preview->'exercises') WITH ORDINALITY arr(elem, idx)
            WHERE (elem->>'id')::int = session_exercise_id_to_find;
            IF exercise_index IS NOT NULL THEN
                -- Set the performance log as the new 'objective_parameters'
                v_updated_session_preview := jsonb_set(
                    v_updated_session_preview,
                    ARRAY['exercises', exercise_index::text, 'objective_parameters'],
                    exercise_log,
                    true -- create the key if it doesn't exist
                );
            END IF;
        END;
    END LOOP;
    -- Return both the created log and the updated session preview
    RETURN jsonb_build_object(
        'session_log', v_created_log,
        'updated_session_preview', v_updated_session_preview
    );
END;
$function$;
