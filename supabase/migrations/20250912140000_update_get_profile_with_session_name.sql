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
                                    'name', s.name, -- Added session name here
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
                                                             'order_in_round_log', el.order_in_round_log, -- Added order
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
