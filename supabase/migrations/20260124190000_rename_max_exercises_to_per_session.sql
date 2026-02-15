-- Migration: Rename max_exercises to max_exercises_per_session
-- Description: Changes max_exercises from a total limit to a per-session limit,
--              matching the hierarchical structure: programs -> sessions -> exercises.
--              Updates all RPC functions and triggers accordingly.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. Restore all functions from previous migrations
-- 2. ALTER TABLE subscription_limits RENAME COLUMN max_exercises_per_session TO max_exercises;
-- 3. Restore previous values in subscription_limits table

-- Step 1: Rename the column
ALTER TABLE public.subscription_limits 
RENAME COLUMN max_exercises TO max_exercises_per_session;

-- Step 2: Update values to be per-session limits (adjust based on business requirements)
-- Free: 6 exercises per session (was 6 total)
-- Basic: 15 exercises per session (was 50 total)
-- Premium: 20 exercises per session (was 200 total)
UPDATE public.subscription_limits sl
SET max_exercises_per_session = CASE
  WHEN e.entitlement_key = 'Free' THEN 6
  WHEN e.entitlement_key = 'Basic' THEN 15
  WHEN e.entitlement_key = 'Premium' THEN 20
  ELSE max_exercises_per_session
END
FROM public.entitlements e
WHERE sl.entitlement_id = e.id;

-- Step 3: Update get_user_subscription_summary to use new column name
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
  -- Verify the user is accessing their own data
  IF v_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: can only view own subscription';
  END IF;

  -- Try to get active subscription
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
    'limits', jsonb_build_object(
      'max_programs', sl.max_programs,
      'max_sessions_per_program', sl.max_sessions_per_program,
      'history_days', sl.history_days,
      'max_exercises_per_session', sl.max_exercises_per_session,
      'can_export_data', sl.can_export_data,
      'can_share_programs', sl.can_share_programs,
      'metadata', COALESCE(sl.metadata, '{}'::jsonb)
    )
  )
  INTO v_subscription
  FROM public.subscriptions s
  INNER JOIN public.entitlements e ON s.entitlement_id = e.id
  LEFT JOIN public.products p ON s.product_id = p.id
  LEFT JOIN public.subscription_limits sl ON e.id = sl.entitlement_id
  WHERE s.user_id = v_user_id
    AND s.status IN ('active', 'trialing', 'in_grace')
    AND (s.expires_at IS NULL OR s.expires_at > now())
  ORDER BY e.priority DESC, s.created_at DESC
  LIMIT 1;

  -- If no active subscription, return Free entitlement as fallback
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
      'limits', jsonb_build_object(
        'max_programs', sl.max_programs,
        'max_sessions_per_program', sl.max_sessions_per_program,
        'history_days', sl.history_days,
        'max_exercises_per_session', sl.max_exercises_per_session,
        'can_export_data', sl.can_export_data,
        'can_share_programs', sl.can_share_programs,
        'metadata', COALESCE(sl.metadata, '{}'::jsonb)
      )
    )
    INTO v_subscription
    FROM public.entitlements e
    LEFT JOIN public.subscription_limits sl ON e.id = sl.entitlement_id
    WHERE e.entitlement_key = 'Free'
    LIMIT 1;
  END IF;

  -- Final safety check: if still NULL (shouldn't happen), raise error
  IF v_subscription IS NULL THEN
    RAISE EXCEPTION 'Unable to determine user subscription limits: Free entitlement not found';
  END IF;

  RETURN v_subscription;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_user_subscription_summary(UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION public.get_user_subscription_summary(UUID) IS 
'Returns the active subscription for a user with entitlement and limits information.
Automatically falls back to Free entitlement if no active subscription exists.
Never returns NULL - always returns at least Free entitlement.
UPDATED: max_exercises_per_session is now a per-session limit, not a total limit.';
