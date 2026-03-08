-- Migration: Update RPC functions for max_exercises_per_session
-- Description: Updates all RPC functions to check exercises limit per session
--              instead of total exercises count. Removes total exercises count
--              from usage statistics.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. Restore functions from migration 20260124140000_create_limit_verification_functions.sql
-- 2. Restore functions from migration 20260124150000_add_limit_checks_to_rpc.sql
-- 3. Restore trigger from migration 20260124160000_create_limit_triggers.sql

-- Step 1: Update get_user_limits_with_usage to remove total exercises count
CREATE OR REPLACE FUNCTION public.get_user_limits_with_usage(p_user_id UUID DEFAULT auth.uid())
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID := COALESCE(p_user_id, auth.uid());
  v_result jsonb;
BEGIN
  -- Verify the user is accessing their own data
  IF v_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: can only view own limits';
  END IF;

  -- Get subscription summary (includes Free fallback)
  SELECT public.get_user_subscription_summary(v_user_id) INTO v_result;

  -- If still null (shouldn't happen with Free fallback), return error
  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Unable to determine user subscription limits';
  END IF;

  -- Add current usage counts (removed exercises_count - no longer needed)
  SELECT v_result || jsonb_build_object(
    'usage', jsonb_build_object(
      'programs_count', (
        SELECT COUNT(*)::int
        FROM public.programs
        WHERE user_id = v_user_id
      ),
      'sessions_count_by_program', (
        SELECT COALESCE(
          jsonb_object_agg(program_id::text, session_count::text),
          '{}'::jsonb
        )
        FROM (
          SELECT 
            p.id as program_id,
            COUNT(s.id)::int as session_count
          FROM public.programs p
          LEFT JOIN public.sessions s ON s.program_id = p.id
          WHERE p.user_id = v_user_id
          GROUP BY p.id
        ) subq
      )
    )
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- Step 2: Update check_user_can_create_resource to add exercises_per_session
CREATE OR REPLACE FUNCTION public.check_user_can_create_resource(
  p_user_id UUID,
  p_resource_type TEXT, -- 'programs', 'sessions_per_program', 'exercises_per_session'
  p_program_id BIGINT DEFAULT NULL, -- Required for 'sessions_per_program'
  p_session_id BIGINT DEFAULT NULL -- Required for 'exercises_per_session'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_limits jsonb;
  v_current_count INT;
  v_max_allowed INT;
  v_error_code TEXT;
  v_error_message TEXT;
  v_entitlement_key TEXT;
BEGIN
  -- Get user limits and usage
  SELECT public.get_user_limits_with_usage(p_user_id) INTO v_limits;

  -- Extract entitlement key for logging
  v_entitlement_key := v_limits->'entitlement'->>'entitlement_key';

  -- Check subscription status first
  IF v_limits->>'status' = 'free' THEN
    -- Free plan: check limits
  ELSIF v_limits->>'status' NOT IN ('active', 'trialing', 'in_grace') THEN
    -- Subscription inactive
    v_error_code := 'SUBSCRIPTION_INACTIVE';
    v_error_message := format('SUBSCRIPTION_INACTIVE Votre abonnement n''est pas actif (status: %s).', v_limits->>'status');
    
    -- Log event
    PERFORM public.log_limit_event(
      p_user_id,
      'subscription_inactive',
      NULL,
      NULL,
      NULL,
      v_entitlement_key
    );
    
    RAISE EXCEPTION '%', v_error_message;
  END IF;

  -- Check expiration if expires_at is set
  IF v_limits->>'expires_at' IS NOT NULL AND v_limits->>'expires_at' != 'null' THEN
    IF (v_limits->>'expires_at')::timestamptz <= now() THEN
      v_error_code := 'SUBSCRIPTION_EXPIRED';
      v_error_message := 'SUBSCRIPTION_EXPIRED Votre abonnement a expiré.';
      
      -- Log event
      PERFORM public.log_limit_event(
        p_user_id,
        'subscription_expired',
        NULL,
        NULL,
        NULL,
        v_entitlement_key
      );
      
      RAISE EXCEPTION '%', v_error_message;
    END IF;
  END IF;

  -- Check based on resource type
  CASE p_resource_type
    WHEN 'programs' THEN
      v_current_count := (v_limits->'usage'->>'programs_count')::int;
      v_max_allowed := (v_limits->'limits'->>'max_programs')::int;
      v_error_code := 'LIMIT_EXCEEDED:MAX_PROGRAMS';
      v_error_message := format('LIMIT_EXCEEDED:MAX_PROGRAMS:%s/%s Vous avez atteint la limite de programmes.', v_current_count, v_max_allowed);

    WHEN 'sessions_per_program' THEN
      IF p_program_id IS NULL THEN
        RAISE EXCEPTION 'program_id is required for sessions_per_program check';
      END IF;
      
      -- Get current session count for this program
      SELECT COUNT(*)::int INTO v_current_count
      FROM public.sessions
      WHERE program_id = p_program_id;

      v_max_allowed := (v_limits->'limits'->>'max_sessions_per_program')::int;
      v_error_code := 'LIMIT_EXCEEDED:MAX_SESSIONS';
      v_error_message := format('LIMIT_EXCEEDED:MAX_SESSIONS:%s/%s Limite de séances atteinte pour ce programme.', v_current_count, v_max_allowed);

    WHEN 'exercises_per_session' THEN
      IF p_session_id IS NULL THEN
        RAISE EXCEPTION 'session_id is required for exercises_per_session check';
      END IF;
      
      -- Get current exercise count for this session
      SELECT COUNT(*)::int INTO v_current_count
      FROM public.session_exercises
      WHERE session_id = p_session_id;

      v_max_allowed := (v_limits->'limits'->>'max_exercises_per_session')::int;
      v_error_code := 'LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION';
      v_error_message := format('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION:%s/%s Limite d''exercices atteinte pour cette séance.', v_current_count, v_max_allowed);

    ELSE
      RAISE EXCEPTION 'Invalid resource_type: %', p_resource_type;
  END CASE;

  -- Check if limit would be exceeded
  IF v_max_allowed IS NOT NULL AND v_current_count >= v_max_allowed THEN
    -- Log limit hit event
    PERFORM public.log_limit_event(
      p_user_id,
      'limit_hit',
      p_resource_type,
      v_current_count,
      v_max_allowed,
      v_entitlement_key
    );
    
    RAISE EXCEPTION '%', v_error_message;
  END IF;

  -- Return limits for potential use
  RETURN v_limits;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_user_limits_with_usage(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_user_can_create_resource(UUID, TEXT, BIGINT, BIGINT) TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.get_user_limits_with_usage(UUID) IS 
'Returns subscription limits and current usage counts for a user in a single call.
Optimized for limit checking in RPC functions. Automatically includes Free fallback.
UPDATED: Removed exercises_count - exercises are now limited per session, not total.';

COMMENT ON FUNCTION public.check_user_can_create_resource(UUID, TEXT, BIGINT, BIGINT) IS 
'Reusable helper function to check if a subscription limit would be exceeded.
Raises an exception with a standardized error code if the limit is exceeded.
Returns limits JSONB if check passes. Used by both RPC functions and triggers (DRY).
UPDATED: Added exercises_per_session check - exercises are now limited per session, not total.';
