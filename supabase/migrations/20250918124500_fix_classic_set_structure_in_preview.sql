-- This migration provides the final fix for the create_session_log function.
-- It transforms the structure of the sets within a 'CLASSIC' performance log
-- to match the 'ClassicExerciseParameters' Dart model. Specifically, it renames
-- 'reps' to 'reps_number' and 'number' to 'order_in_exercise' for each set,
-- resolving the final deserialization error.
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
    v_session_type TEXT;
    v_created_log jsonb;
    v_session_preview jsonb;
    v_updated_session_preview jsonb;
    first_round_exercises jsonb;
    exercise_log jsonb;
BEGIN
    v_session_id := (session_log_data->>'session_id')::int;
    SELECT s.type INTO v_session_type FROM public.sessions s WHERE s.id = v_session_id;

    -- Step 1: Verify ownership
    IF NOT EXISTS (
        SELECT 1 FROM public.sessions s
        JOIN public.programs p ON s.program_id = p.id
        WHERE s.id = v_session_id AND p.user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Session not found or access denied';
    END IF;

    -- Step 2: Insert logs
    INSERT INTO public.session_logs (user_id, session_id, started_at, ended_at)
    VALUES (v_user_id, v_session_id, (session_log_data->>'started_at')::timestamptz, (session_log_data->>'ended_at')::timestamptz)
    RETURNING id INTO new_session_log_id;
    FOR round_data IN SELECT * FROM jsonb_array_elements(session_log_data->'rounds')
    LOOP
        INSERT INTO public.round_logs (session_log_id, round_number)
        VALUES (new_session_log_id, (round_data->>'round_number')::int)
        RETURNING id INTO new_round_log_id;
        FOR exercise_log_data IN SELECT * FROM jsonb_array_elements(round_data->'exercises')
        LOOP
            INSERT INTO public.exercises_logs (round_log_id, session_exercise_id, performance, order_in_round_log)
            VALUES (new_round_log_id, (exercise_log_data->>'session_exercise_id')::int, exercise_log_data, (exercise_log_data->>'order_in_round_log')::int);
        END LOOP;
    END LOOP;

    -- Step 3: Build created SessionLog for return
    SELECT
        jsonb_build_object(
            'id', sl.id, 'session_id', sl.session_id, 'name', s.name, 'started_at', sl.started_at, 'ended_at', sl.ended_at, 'type', s.type,
            'rounds', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', rl.id, 'round_number', rl.round_number,
                        'exercises', COALESCE((
                            SELECT jsonb_agg(
                                el.performance || jsonb_build_object('type', s.type, 'order_in_round_log', el.order_in_round_log)
                            ) FROM public.exercises_logs el WHERE el.round_log_id = rl.id
                        ), '[]'::jsonb)
                    ) ORDER BY rl.round_number ASC
                ) FROM public.round_logs rl WHERE rl.session_log_id = sl.id
            ), '[]'::jsonb)
        )
    INTO v_created_log
    FROM public.session_logs sl
    JOIN public.sessions s ON sl.session_id = s.id
    WHERE sl.id = new_session_log_id;

    -- Step 4: Build the session preview using the trusted logic
    SELECT
        jsonb_build_object(
            'id', s.id, 'name', s.name, 'order_in_program', s.order_in_program, 'type', s.type, 'style', s.style,
            'exercises', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', se.id, 'exercise_id', se.exercise_id, 'order_in_session', se.order_in_session,
                        'session_type', s.type, 'exercise', jsonb_build_object('name', e.name),
                        'parameters', se.parameters,
                        'progression', (SELECT jsonb_agg(ep.*) FROM public.exercise_progressions ep WHERE ep.session_exercise_id = se.id AND ep.user_id = v_user_id)
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
    INTO v_session_preview
    FROM public.sessions s
    WHERE s.id = v_session_id;

    -- Step 5: Update the preview with the new performance, transforming 'CLASSIC' sets
    v_updated_session_preview := v_session_preview;
    first_round_exercises := (session_log_data->'rounds'->0->'exercises');

    FOR exercise_log IN SELECT * FROM jsonb_array_elements(first_round_exercises)
    LOOP
        DECLARE
            exercise_index INT;
            session_exercise_id_to_find INT;
            final_exercise_log jsonb;
        BEGIN
            session_exercise_id_to_find := (exercise_log->>'session_exercise_id')::int;
            
            SELECT idx - 1 INTO exercise_index
            FROM jsonb_array_elements(v_updated_session_preview->'exercises') WITH ORDINALITY arr(elem, idx)
            WHERE (elem->>'id')::int = session_exercise_id_to_find;

            IF exercise_index IS NOT NULL THEN
                 final_exercise_log := exercise_log;
                 IF v_session_type = 'CLASSIC' THEN
                    -- Transform the sets array
                    SELECT jsonb_build_object(
                        'sets', (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'order_in_exercise', (s->>'number')::int,
                                    'reps_number', (s->>'reps')::int,
                                    'weight', (s->>'weight')::float,
                                    'rest_duration', (s->>'rest_duration')::bigint
                                )
                            )
                            FROM jsonb_array_elements(exercise_log->'sets') s
                        )
                    )
                    INTO final_exercise_log;
                 END IF;

                 v_updated_session_preview := jsonb_set(
                    v_updated_session_preview,
                    ARRAY['exercises', exercise_index::text, 'progression'],
                    jsonb_build_array(jsonb_build_object('next_objective_parameters', final_exercise_log)),
                    true
                );
            END IF;
        END;
    END LOOP;

    -- Step 6: Return the final combined object
    RETURN jsonb_build_object(
        'session_log', v_created_log,
        'updated_session_preview', v_updated_session_preview
    );
END;
$function$;
