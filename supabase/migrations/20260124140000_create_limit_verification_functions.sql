-- Migration: Create reusable limit verification functions
-- Description: Creates helper functions for subscription limit checking that are
--              reusable by both RPC functions and triggers (DRY principle).
--              Also creates a monitoring table to log limit events.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. DROP FUNCTION IF EXISTS public.log_limit_event(UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT);
-- 2. DROP FUNCTION IF EXISTS public.check_user_can_create_resource(UUID, TEXT, BIGINT);
-- 3. DROP FUNCTION IF EXISTS public.get_user_limits_with_usage(UUID);
-- 4. DROP TABLE IF EXISTS public.subscription_limit_events;

-- Step 1: Create monitoring table for limit events
CREATE TABLE IF NOT EXISTS public.subscription_limit_events (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type text NOT NULL, -- 'limit_hit', 'subscription_expired', 'subscription_inactive'
  resource_type text, -- 'program', 'session', 'exercise'
  current_count integer,
  max_allowed integer,
  entitlement_key text,
  created_at timestamptz DEFAULT NOW()
);

-- Create index on user_id for efficient queries
CREATE INDEX IF NOT EXISTS idx_subscription_limit_events_user_id 
ON public.subscription_limit_events(user_id);

-- Create index on created_at for time-based queries
CREATE INDEX IF NOT EXISTS idx_subscription_limit_events_created_at 
ON public.subscription_limit_events(created_at DESC);

-- Enable RLS on monitoring table
ALTER TABLE public.subscription_limit_events ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only view their own limit events
CREATE POLICY "Users can view their own limit events"
ON public.subscription_limit_events
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Step 2: Create function to log limit events
CREATE OR REPLACE FUNCTION public.log_limit_event(
  p_user_id UUID,
  p_event_type TEXT,
  p_resource_type TEXT DEFAULT NULL,
  p_current_count INTEGER DEFAULT NULL,
  p_max_allowed INTEGER DEFAULT NULL,
  p_entitlement_key TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.subscription_limit_events (
    user_id,
    event_type,
    resource_type,
    current_count,
    max_allowed,
    entitlement_key
  )
  VALUES (
    p_user_id,
    p_event_type,
    p_resource_type,
    p_current_count,
    p_max_allowed,
    p_entitlement_key
  );
END;
$$;

-- Step 3: Create unified RPC function to get limits with usage
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

  -- Add current usage counts
  SELECT v_result || jsonb_build_object(
    'usage', jsonb_build_object(
      'programs_count', (
        SELECT COUNT(*)::int
        FROM public.programs
        WHERE user_id = v_user_id
      ),
      'exercises_count', (
        SELECT COUNT(*)::int
        FROM public.exercises
        WHERE user_id = v_user_id
      ),
      'sessions_count_by_program', (
        SELECT jsonb_object_agg(program_id::text, session_count::text)
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

-- Step 4: Create reusable function to check if user can create a resource
-- This function is used by BOTH RPC functions AND triggers (DRY)
CREATE OR REPLACE FUNCTION public.check_user_can_create_resource(
  p_user_id UUID,
  p_resource_type TEXT, -- 'programs', 'sessions_per_program', 'exercises'
  p_program_id BIGINT DEFAULT NULL -- Required for 'sessions_per_program'
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

    WHEN 'exercises' THEN
      v_current_count := (v_limits->'usage'->>'exercises_count')::int;
      v_max_allowed := (v_limits->'limits'->>'max_exercises')::int;
      v_error_code := 'LIMIT_EXCEEDED:MAX_EXERCISES';
      v_error_message := format('LIMIT_EXCEEDED:MAX_EXERCISES:%s/%s Limite d''exercices atteinte.', v_current_count, v_max_allowed);

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
GRANT EXECUTE ON FUNCTION public.check_user_can_create_resource(UUID, TEXT, BIGINT) TO authenticated;

-- Add comments
COMMENT ON TABLE public.subscription_limit_events IS 
'Stores events related to subscription limits (limit hits, expired subscriptions, etc.) for analytics and monitoring.';

COMMENT ON FUNCTION public.log_limit_event(UUID, TEXT, TEXT, INTEGER, INTEGER, TEXT) IS 
'Logs a subscription limit event to the monitoring table.';

COMMENT ON FUNCTION public.get_user_limits_with_usage(UUID) IS 
'Returns subscription limits and current usage counts for a user in a single call.
Optimized for limit checking in RPC functions. Automatically includes Free fallback.';

COMMENT ON FUNCTION public.check_user_can_create_resource(UUID, TEXT, BIGINT) IS 
'Reusable helper function to check if a subscription limit would be exceeded.
Raises an exception with a standardized error code if the limit is exceeded.
Returns limits JSONB if check passes. Used by both RPC functions and triggers (DRY).';
