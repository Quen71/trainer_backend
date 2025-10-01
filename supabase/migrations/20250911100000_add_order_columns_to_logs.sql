-- Add order columns to log tables
ALTER TABLE public.session_logs ADD COLUMN order_in_program INTEGER;
ALTER TABLE public.round_logs ADD COLUMN order_in_session_log INTEGER;
ALTER TABLE public.exercises_logs ADD COLUMN order_in_round_log INTEGER;

-- Backfill existing data
-- For session_logs, populate order_in_program from the parent session
UPDATE public.session_logs sl
SET order_in_program = s.order_in_program
FROM public.sessions s
WHERE sl.session_id = s.id;

-- For round_logs, populate order_in_session_log from the round_number
UPDATE public.round_logs
SET order_in_session_log = round_number;

-- For exercises_logs, generate an order based on their insertion order (approximated by id)
WITH ordered_exercises AS (
  SELECT
    id,
    ROW_NUMBER() OVER(PARTITION BY round_log_id ORDER BY id) as rn
  FROM public.exercises_logs
)
UPDATE public.exercises_logs el
SET order_in_round_log = oe.rn
FROM ordered_exercises oe
WHERE el.id = oe.id;

-- For classic exercises_logs, update performance JSON to add a default 'rest_duration' to sets
WITH classic_logs AS (
    SELECT el.id
    FROM public.exercises_logs el
    JOIN public.round_logs rl ON el.round_log_id = rl.id
    JOIN public.session_logs sl ON rl.session_log_id = sl.id
    JOIN public.sessions s ON sl.session_id = s.id
    WHERE s.type = 'CLASSIC' AND el.performance -> 'sets' IS NOT NULL AND jsonb_typeof(el.performance -> 'sets') = 'array'
),
updated_performance AS (
    SELECT
        cl.id as log_id,
        jsonb_set(
            el.performance,
            '{sets}',
            (
                SELECT jsonb_agg(
                    CASE
                        WHEN set_element -> 'rest_duration' IS NULL THEN
                            set_element || '{"rest_duration": 0}'::jsonb
                        ELSE
                            set_element
                    END
                )
                FROM jsonb_array_elements(el.performance -> 'sets') AS set_element
            )
        ) as new_performance
    FROM public.exercises_logs el
    JOIN classic_logs cl ON el.id = cl.id
)
UPDATE public.exercises_logs el
SET performance = up.new_performance
FROM updated_performance up
WHERE el.id = up.log_id;

-- Backfill ended_at for existing session_logs where it is null
UPDATE public.session_logs
SET ended_at = started_at
WHERE ended_at IS NULL;

-- Set columns to NOT NULL
ALTER TABLE public.session_logs ALTER COLUMN order_in_program SET NOT NULL;
ALTER TABLE public.round_logs ALTER COLUMN order_in_session_log SET NOT NULL;
ALTER TABLE public.exercises_logs ALTER COLUMN order_in_round_log SET NOT NULL;
ALTER TABLE public.session_logs ALTER COLUMN ended_at SET NOT NULL;


-- Update the create_session_log function
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
    v_order_in_program INT; -- New variable
BEGIN
    v_session_id := (session_log_data->>'session_id')::int;

    -- Verify that the user owns the original session and get order_in_program
    SELECT s.order_in_program INTO v_order_in_program
    FROM public.sessions s
    JOIN public.programs p ON s.program_id = p.id
    WHERE s.id = v_session_id AND p.user_id = v_user_id;

    IF v_order_in_program IS NULL THEN
        RAISE EXCEPTION 'Session not found or access denied';
    END IF;

    -- Insert the main session log
    INSERT INTO public.session_logs (user_id, session_id, started_at, ended_at, order_in_program) -- Added column
    VALUES (
        v_user_id,
        v_session_id,
        (session_log_data->>'started_at')::timestamptz,
        (session_log_data->>'ended_at')::timestamptz,
        v_order_in_program -- Added value
    )
    RETURNING id INTO new_session_log_id;

    -- Loop through rounds
    FOR round_data IN SELECT * FROM jsonb_array_elements(session_log_data->'rounds')
    LOOP
        -- Insert the round log
        INSERT INTO public.round_logs (session_log_id, round_number, order_in_session_log) -- Added column
        VALUES (
            new_session_log_id,
            (round_data->>'round_number')::int,
            (round_data->>'order_in_session_log')::int -- Added value
        )
        RETURNING id INTO new_round_log_id;

        -- Loop through exercise logs in the round
        FOR exercise_log_data IN SELECT * FROM jsonb_array_elements(round_data->'exercises')
        LOOP
            -- Insert the exercise log
            INSERT INTO public.exercises_logs (round_log_id, session_exercise_id, performance, order_in_round_log) -- Added column
            VALUES (
                new_round_log_id,
                (exercise_log_data->>'session_exercise_id')::int,
                exercise_log_data,
                (exercise_log_data->>'order_in_round_log')::int -- Added value
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
            'order_in_program', sl.order_in_program, -- Added field
            'type', s.type, -- For SessionLog deserialization
            'rounds', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', rl.id,
                        'round_number', rl.round_number,
                        'order_in_session_log', rl.order_in_session_log, -- Added field
                        'exercises', COALESCE((
                            SELECT jsonb_agg(
                                -- The 'performance' object from the table is the ExerciseLog itself
                                el.performance || jsonb_build_object(
                                    'type', s.type,
                                    'order_in_round_log', el.order_in_round_log -- Added field
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

-- Update get_user_sessions_logs function
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
                    'order_in_program', sl.order_in_program, -- Added field
                    'type', s.type, -- Crucial for deserialization
                    'rounds', COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', rl.id,
                                'round_number', rl.round_number,
                                'order_in_session_log', rl.order_in_session_log, -- Added field
                                'exercises', COALESCE((
                                    SELECT jsonb_agg(
                                        -- Inject session type and exercise name for full deserialization
                                        el.performance || jsonb_build_object(
                                            'type', s.type,
                                            'order_in_round_log', el.order_in_round_log, -- Added field
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
