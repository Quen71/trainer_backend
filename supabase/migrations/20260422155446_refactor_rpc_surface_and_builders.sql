-- Migration: Refactor RPC surface and canonical JSON builders
-- Description:
-- - hardens SECURITY DEFINER functions with consistent search_path
-- - removes unused public RPCs from the exposed surface
-- - revokes execute from internal helpers
-- - centralizes program/session/session_log JSON builders
-- - canonicalizes subscription limits JSON across RPCs

-- ============================================================================
-- Canonical internal helpers
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_subscription_limits_json(
  p_entitlement_id uuid
)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT COALESCE(
    (
      SELECT jsonb_build_object(
        'max_programs', sl.max_programs,
        'max_sessions_per_program', sl.max_sessions_per_program,
        'history_days', sl.history_days,
        'max_exercises_per_session', sl.max_exercises_per_session,
        'can_export_data', sl.can_export_data,
        'can_share_programs', sl.can_share_programs,
        'metadata', COALESCE(sl.metadata, '{}'::jsonb)
      )
      FROM public.subscription_limits sl
      WHERE sl.entitlement_id = p_entitlement_id
    ),
    '{}'::jsonb
  );
$$;

CREATE OR REPLACE FUNCTION public.get_session_preview_by_id(
  p_session_id bigint,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT
    jsonb_build_object(
      'id', s.id,
      'name', s.name,
      'order_in_program', s.order_in_program,
      'type', s.type,
      'style', s.style,
      'exercises', COALESCE(
        (
          SELECT jsonb_agg(
            jsonb_build_object(
              'id', se.id,
              'exercise_id', se.exercise_id,
              'order_in_session', se.order_in_session,
              'exercise', jsonb_build_object('name', e.name),
              'parameters', se.parameters,
              'progression', COALESCE(
                (
                  SELECT jsonb_agg(ep.* ORDER BY ep.created_at)
                  FROM public.exercise_progressions ep
                  WHERE ep.session_exercise_id = se.id
                    AND (p_user_id IS NULL OR ep.user_id = p_user_id)
                ),
                '[]'::jsonb
              )
            )
            ORDER BY se.order_in_session
          )
          FROM public.session_exercises se
          JOIN public.exercises e ON e.id = se.exercise_id
          WHERE se.session_id = s.id
        ),
        '[]'::jsonb
      )
    ) ||
    CASE
      WHEN s.type = 'AMRAP' THEN jsonb_build_object('duration', s.parameters->'duration')
      WHEN s.type IN ('EMOM', 'HIIT') THEN jsonb_build_object('round_number', s.parameters->'round_number')
      ELSE '{}'::jsonb
    END
  FROM public.sessions s
  WHERE s.id = p_session_id;
$$;

CREATE OR REPLACE FUNCTION public.get_session_log_by_id(
  p_session_log_id bigint
)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT jsonb_build_object(
    'id', sl.id,
    'session_id', sl.session_id,
    'name', s.name,
    'program_name', p.name,
    'started_at', sl.started_at,
    'ended_at', sl.ended_at,
    'type', s.type,
    'rounds', COALESCE(
      (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', rl.id,
            'round_number', rl.round_number,
            'exercises', COALESCE(
              (
                SELECT jsonb_agg(
                  el.performance || jsonb_build_object(
                    'type', s.type,
                    'order_in_round_log', el.order_in_round_log,
                    'exercise_name', ex.name
                  )
                  ORDER BY el.order_in_round_log
                )
                FROM public.exercises_logs el
                JOIN public.session_exercises se ON se.id = el.session_exercise_id
                JOIN public.exercises ex ON ex.id = se.exercise_id
                WHERE el.round_log_id = rl.id
              ),
              '[]'::jsonb
            )
          )
          ORDER BY rl.round_number
        )
        FROM public.round_logs rl
        WHERE rl.session_log_id = sl.id
      ),
      '[]'::jsonb
    )
  )
  FROM public.session_logs sl
  JOIN public.sessions s ON s.id = sl.session_id
  JOIN public.programs p ON p.id = s.program_id
  WHERE sl.id = p_session_log_id
    AND p.user_id = auth.uid();
$$;

-- ============================================================================
-- Program and history builders
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_full_program_by_id(p_program_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'id', p.id,
            'user_id', p.user_id,
            'name', p.name,
            'description', p.description,
            'created_at', p.created_at,
            'updated_at', p.updated_at,
            'is_favorite', EXISTS (
                SELECT 1
                FROM public.favorite_programs fp
                WHERE fp.program_id = p.id
                  AND fp.user_id = v_user_id
            ),
            'sessions', COALESCE(
                (
                    SELECT jsonb_agg(
                        public.get_session_preview_by_id(s.id, v_user_id)
                        ORDER BY s.order_in_program
                    )
                    FROM public.sessions s
                    WHERE s.program_id = p.id
                ),
                '[]'::jsonb
            )
        )
        FROM public.programs p
        WHERE p.id = p_program_id
    );
END;
$$;

CREATE OR REPLACE FUNCTION public.get_user_programs(page_number integer, page_size integer)
RETURNS json
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT COALESCE(
    (
      SELECT jsonb_agg(
        public.get_full_program_by_id(p.id)
        ORDER BY p.created_at DESC
      )
      FROM (
        SELECT prog.id, prog.created_at
        FROM public.programs prog
        WHERE prog.user_id = auth.uid()
        ORDER BY prog.created_at DESC
        LIMIT page_size
        OFFSET page_number * page_size
      ) p
    ),
    '[]'::jsonb
  )::json;
$$;

CREATE OR REPLACE FUNCTION public.get_user_sessions_logs(page_number integer, page_size integer)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT COALESCE(
    (
      SELECT jsonb_agg(
        public.get_session_log_by_id(sl.id)
        ORDER BY sl.started_at DESC
      )
      FROM (
        SELECT session_log.id, session_log.started_at
        FROM public.session_logs session_log
        JOIN public.sessions s ON s.id = session_log.session_id
        JOIN public.programs p ON p.id = s.program_id
        WHERE p.user_id = auth.uid()
        ORDER BY session_log.started_at DESC
        LIMIT page_size
        OFFSET page_number * page_size
      ) sl
    ),
    '[]'::jsonb
  );
$$;

CREATE OR REPLACE FUNCTION public.get_profile_with_initial_data(p_limit integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id uuid := auth.uid();
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'id', p.id,
            'role', p.role,
            'full_name', p.full_name,
            'created_at', p.created_at,
            'updated_at', p.updated_at,
            'username', p.username,
            'programs', COALESCE(
                (
                    SELECT jsonb_agg(
                        public.get_full_program_by_id(prog.id)
                        ORDER BY prog.created_at DESC
                    )
                    FROM (
                        SELECT pr.id, pr.created_at
                        FROM public.programs pr
                        WHERE pr.user_id = v_user_id
                        ORDER BY pr.created_at DESC
                        LIMIT p_limit
                    ) prog
                ),
                '[]'::jsonb
            ),
            'session_logs', COALESCE(
                (
                    SELECT jsonb_agg(
                        public.get_session_log_by_id(sl.id)
                        ORDER BY sl.started_at DESC
                    )
                    FROM (
                        SELECT session_log.id, session_log.started_at
                        FROM public.session_logs session_log
                        JOIN public.sessions s ON s.id = session_log.session_id
                        JOIN public.programs prog ON prog.id = s.program_id
                        WHERE session_log.user_id = v_user_id
                        ORDER BY session_log.started_at DESC
                        LIMIT p_limit
                    ) sl
                ),
                '[]'::jsonb
            )
        )
        FROM public.profiles p
        WHERE p.id = v_user_id
    );
END;
$$;

CREATE OR REPLACE FUNCTION public.create_session_log(session_log_data jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
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

    IF NOT EXISTS (
        SELECT 1
        FROM public.sessions s
        JOIN public.programs p ON p.id = s.program_id
        WHERE s.id = v_session_id
          AND p.user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Session not found or access denied';
    END IF;

    INSERT INTO public.session_logs (user_id, session_id, started_at, ended_at)
    VALUES (
        v_user_id,
        v_session_id,
        (session_log_data->>'started_at')::timestamptz,
        (session_log_data->>'ended_at')::timestamptz
    )
    RETURNING id INTO new_session_log_id;

    FOR round_data IN SELECT * FROM jsonb_array_elements(session_log_data->'rounds')
    LOOP
        INSERT INTO public.round_logs (session_log_id, round_number)
        VALUES (new_session_log_id, (round_data->>'round_number')::int)
        RETURNING id INTO new_round_log_id;

        FOR exercise_log_data IN SELECT * FROM jsonb_array_elements(round_data->'exercises')
        LOOP
            INSERT INTO public.exercises_logs (
                round_log_id,
                session_exercise_id,
                performance,
                order_in_round_log
            )
            VALUES (
                new_round_log_id,
                (exercise_log_data->>'session_exercise_id')::int,
                exercise_log_data,
                (exercise_log_data->>'order_in_round_log')::int
            );
        END LOOP;
    END LOOP;

    SELECT public.get_session_log_by_id(new_session_log_id::bigint) INTO v_created_log;
    SELECT public.get_session_preview_by_id(v_session_id::bigint, v_user_id) INTO v_session_preview;

    v_updated_session_preview := v_session_preview;
    first_round_exercises := session_log_data->'rounds'->0->'exercises';

    FOR exercise_log IN SELECT * FROM jsonb_array_elements(first_round_exercises)
    LOOP
        DECLARE
            exercise_index INT;
            session_exercise_id_to_find INT;
            final_exercise_log jsonb;
        BEGIN
            session_exercise_id_to_find := (exercise_log->>'session_exercise_id')::int;

            SELECT idx - 1
            INTO exercise_index
            FROM jsonb_array_elements(v_updated_session_preview->'exercises') WITH ORDINALITY arr(elem, idx)
            WHERE (elem->>'id')::int = session_exercise_id_to_find;

            IF exercise_index IS NOT NULL THEN
                final_exercise_log := exercise_log;

                IF v_session_type = 'CLASSIC' THEN
                    SELECT jsonb_build_object(
                        'sets',
                        (
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

    RETURN jsonb_build_object(
        'session_log', v_created_log,
        'updated_session_preview', v_updated_session_preview
    );
END;
$$;

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
    v_max_exercises_per_session INT;
    v_exercises_count INT;
BEGIN
    v_session_id := (p_session_data->>'id')::int;
    IF v_session_id IS NULL THEN
        RAISE EXCEPTION 'Session ID is missing from the payload.';
    END IF;

    SELECT s.program_id
    INTO v_program_id
    FROM public.sessions s
    JOIN public.programs p ON p.id = s.program_id
    WHERE s.id = v_session_id
      AND p.user_id = v_auth_user_id;

    IF v_program_id IS NULL THEN
        RAISE EXCEPTION 'Session not found or access denied.';
    END IF;

    IF jsonb_array_length(p_session_data->'exercises') = 0 THEN
        RAISE EXCEPTION 'A session must contain at least one exercise.';
    END IF;

    IF p_session_data ? 'exercises' AND jsonb_typeof(p_session_data->'exercises') = 'array' THEN
        SELECT public.get_user_limits_with_usage(v_auth_user_id) INTO v_limits;
        v_max_exercises_per_session := (v_limits->'limits'->>'max_exercises_per_session')::int;
        v_exercises_count := jsonb_array_length(p_session_data->'exercises');

        IF v_max_exercises_per_session IS NOT NULL AND v_exercises_count > v_max_exercises_per_session THEN
            RAISE EXCEPTION 'LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION:%s/%s Cette séance dépasse la limite de %s exercices par séance. Demandé: %s',
                v_exercises_count,
                v_max_exercises_per_session,
                v_max_exercises_per_session,
                v_exercises_count;
        END IF;
    END IF;

    UPDATE public.sessions
    SET
        name = p_session_data->>'name',
        parameters = CASE
            WHEN (p_session_data->>'type')::session_type = 'AMRAP' THEN jsonb_build_object('duration', (p_session_data->>'duration')::bigint)
            WHEN (p_session_data->>'type')::session_type IN ('EMOM', 'HIIT') THEN jsonb_build_object('round_number', (p_session_data->>'round_number')::int)
            ELSE '{}'::jsonb
        END
    WHERE id = v_session_id;

    SELECT array_agg(id) INTO v_existing_exercise_ids
    FROM public.session_exercises
    WHERE session_id = v_session_id;

    FOR exercise_data IN SELECT * FROM jsonb_array_elements(p_session_data->'exercises')
    LOOP
        IF exercise_data->'parameters' IS NULL THEN
            RAISE EXCEPTION 'Exercise "%" is missing required "parameters".', exercise_data->>'name';
        END IF;

        v_exercise_name := exercise_data->>'name';

        SELECT id INTO v_exercise_id
        FROM public.exercises
        WHERE user_id = v_auth_user_id
          AND name = v_exercise_name;

        IF v_exercise_id IS NULL THEN
            INSERT INTO public.exercises (user_id, name)
            VALUES (v_auth_user_id, v_exercise_name)
            RETURNING id INTO v_exercise_id;
        END IF;

        v_session_exercise_id := (exercise_data->>'id')::int;

        IF v_session_exercise_id IS NULL OR v_session_exercise_id = 0 THEN
            INSERT INTO public.session_exercises (session_id, exercise_id, order_in_session, parameters)
            VALUES (
                v_session_id,
                v_exercise_id,
                (exercise_data->>'order_in_session')::int,
                (exercise_data->'parameters')::jsonb
            )
            RETURNING id INTO v_session_exercise_id;

            INSERT INTO public.exercise_progressions (user_id, session_exercise_id, next_objective_parameters)
            VALUES (
                v_auth_user_id,
                v_session_exercise_id,
                COALESCE(
                    (exercise_data->'progression'->0->'next_objective_parameters')::jsonb,
                    (exercise_data->'parameters')::jsonb
                )
            );
        ELSE
            UPDATE public.session_exercises
            SET
                order_in_session = (exercise_data->>'order_in_session')::int,
                parameters = (exercise_data->'parameters')::jsonb,
                exercise_id = v_exercise_id
            WHERE id = v_session_exercise_id
              AND session_id = v_session_id;

            UPDATE public.exercise_progressions
            SET next_objective_parameters = COALESCE(
                (exercise_data->'progression'->0->'next_objective_parameters')::jsonb,
                (exercise_data->'parameters')::jsonb
            )
            WHERE session_exercise_id = v_session_exercise_id;
        END IF;

        v_ids_to_keep := array_append(v_ids_to_keep, v_session_exercise_id);
    END LOOP;

    DELETE FROM public.session_exercises
    WHERE session_id = v_session_id
      AND id = ANY(COALESCE(v_existing_exercise_ids, '{}'::int[]))
      AND id NOT IN (SELECT unnest(v_ids_to_keep));

    RETURN jsonb_build_object(
        'program_id', v_program_id,
        'session', public.get_session_preview_by_id(v_session_id::bigint, v_auth_user_id)
    );
END;
$$;

-- ============================================================================
-- Subscription canonicalization
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_user_subscription_summary(p_user_id UUID)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID := COALESCE(p_user_id, auth.uid());
  v_subscription jsonb;
BEGIN
  IF v_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: can only view own subscription';
  END IF;

  SELECT jsonb_build_object(
    'id', s.id,
    'user_id', s.user_id,
    'status', s.status,
    'started_at', s.started_at,
    'expires_at', s.expires_at,
    'is_trial', s.is_trial,
    'entitlement', jsonb_build_object(
      'id', e.id,
      'entitlement_key', e.entitlement_key,
      'name', e.name
    ),
    'product', CASE
      WHEN p.id IS NOT NULL THEN jsonb_build_object(
        'id', p.id,
        'product_id', p.product_id,
        'vendor', p.vendor,
        'period_interval', p.period_interval
      )
      ELSE NULL
    END,
    'limits', public.get_subscription_limits_json(e.id)
  )
  INTO v_subscription
  FROM public.subscriptions s
  INNER JOIN public.entitlements e ON e.id = s.entitlement_id
  LEFT JOIN public.products p ON p.id = s.product_id
  WHERE s.user_id = v_user_id
    AND s.status IN ('active', 'trialing', 'in_grace')
    AND (s.expires_at IS NULL OR s.expires_at > now())
  ORDER BY e.priority DESC, s.created_at DESC
  LIMIT 1;

  IF v_subscription IS NULL THEN
    SELECT jsonb_build_object(
      'id', NULL,
      'user_id', v_user_id,
      'status', 'free'::text,
      'started_at', NULL,
      'expires_at', NULL,
      'is_trial', false,
      'entitlement', jsonb_build_object(
        'id', e.id,
        'entitlement_key', e.entitlement_key,
        'name', e.name
      ),
      'product', NULL,
      'limits', public.get_subscription_limits_json(e.id)
    )
    INTO v_subscription
    FROM public.entitlements e
    WHERE e.entitlement_key = 'Free'
    LIMIT 1;
  END IF;

  IF v_subscription IS NULL THEN
    RAISE EXCEPTION 'Unable to determine user subscription limits: Free entitlement not found';
  END IF;

  RETURN v_subscription;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_entitlement_limits_by_key(
  p_entitlement_key TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_entitlement_id uuid;
BEGIN
  SELECT e.id
  INTO v_entitlement_id
  FROM public.entitlements e
  WHERE e.entitlement_key = p_entitlement_key
  LIMIT 1;

  IF v_entitlement_id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN public.get_subscription_limits_json(v_entitlement_id);
END;
$$;

-- ============================================================================
-- Surface cleanup and hardening
-- ============================================================================

DROP FUNCTION IF EXISTS public.check_feature_access(UUID, TEXT);

ALTER FUNCTION public.add_program_to_favorites(bigint) SET search_path = public, pg_temp;
ALTER FUNCTION public.remove_program_from_favorites(bigint) SET search_path = public, pg_temp;
ALTER FUNCTION public.delete_program(integer) SET search_path = public, pg_temp;
ALTER FUNCTION public.delete_session_from_program(integer) SET search_path = public, pg_temp;
ALTER FUNCTION public.update_full_program(jsonb) SET search_path = public, pg_temp;
ALTER FUNCTION public.delete_user_account() SET search_path = public, pg_temp;
ALTER FUNCTION public.handle_new_user() SET search_path = public, pg_temp;
ALTER FUNCTION public.handle_subscription_webhook(UUID, UUID, UUID, TEXT, public.subscription_status, timestamptz, timestamptz, BOOLEAN, jsonb) SET search_path = public, pg_temp;
ALTER FUNCTION public.create_test_user(text, text, text) SET search_path = public, auth, extensions, pg_temp;

-- Public client RPCs: authenticated only
REVOKE EXECUTE ON FUNCTION public.create_full_program(jsonb) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_user_programs(integer, integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.update_full_program(jsonb) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.add_session_to_program(integer, jsonb) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.delete_session_from_program(integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.delete_program(integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.add_program_to_favorites(bigint) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.remove_program_from_favorites(bigint) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.update_full_session(jsonb) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.create_session_log(jsonb) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_user_sessions_logs(integer, integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_profile_with_initial_data(integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.delete_user_account() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_user_subscription_summary(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_user_limits_with_usage(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_entitlement_limits_by_key(TEXT) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.create_full_program(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_programs(integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_full_program(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_session_to_program(integer, jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_session_from_program(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_program(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_program_to_favorites(bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.remove_program_from_favorites(bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_full_session(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_session_log(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_sessions_logs(integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_profile_with_initial_data(integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_subscription_summary(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_limits_with_usage(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_entitlement_limits_by_key(TEXT) TO authenticated;

-- Internal helpers: not part of the public RPC surface
REVOKE EXECUTE ON FUNCTION public.get_subscription_limits_json(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_session_preview_by_id(bigint, uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_session_log_by_id(bigint) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_full_program_by_id(bigint) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.log_limit_event(UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT) FROM PUBLIC, anon, authenticated;
DO $$
BEGIN
  IF to_regprocedure('public.check_user_can_create_resource(uuid,text,bigint)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.check_user_can_create_resource(UUID, TEXT, BIGINT) FROM PUBLIC, anon, authenticated';
  END IF;

  IF to_regprocedure('public.check_user_can_create_resource(uuid,text,bigint,bigint)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.check_user_can_create_resource(UUID, TEXT, BIGINT, BIGINT) FROM PUBLIC, anon, authenticated';
  END IF;
END;
$$;
REVOKE EXECUTE ON FUNCTION public.handle_subscription_webhook(UUID, UUID, UUID, TEXT, public.subscription_status, timestamptz, timestamptz, BOOLEAN, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.handle_subscription_webhook(UUID, UUID, UUID, TEXT, public.subscription_status, timestamptz, timestamptz, BOOLEAN, jsonb) TO service_role;

