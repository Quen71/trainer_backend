-- Migration: Create Free entitlement and add fallback logic
-- Description: Creates a Free entitlement with default limits and modifies
--              get_user_subscription_summary to automatically fallback to Free
--              when no active subscription exists.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. DROP FUNCTION IF EXISTS public.get_user_subscription_summary(UUID);
-- 2. Restore previous version from migration 20251031191143_create_subscription_rpc_functions.sql
-- 3. DELETE FROM public.subscription_limits WHERE entitlement_id IN (SELECT id FROM public.entitlements WHERE entitlement_key = 'Free');
-- 4. DELETE FROM public.entitlements WHERE entitlement_key = 'Free';

-- Step 1: Create Free entitlement if it doesn't exist
INSERT INTO public.entitlements (entitlement_key, name, priority)
VALUES ('Free', 'Free Plan', 0)
ON CONFLICT (entitlement_key) DO NOTHING;

-- Step 2: Create subscription limits for Free entitlement
INSERT INTO public.subscription_limits (
    entitlement_id,
    max_programs,
    max_sessions_per_program,
    max_exercises,
    history_days,
    can_export_data,
    can_share_programs
)
SELECT 
    e.id,
    1,  -- max_programs: Free users can create 1 program
    2,  -- max_sessions_per_program: 2 sessions max per program
    6,  -- max_exercises: 6 exercises total
    7,  -- history_days: 7 days of history
    false, -- can_export_data
    false  -- can_share_programs
FROM public.entitlements e
WHERE e.entitlement_key = 'Free'
ON CONFLICT (entitlement_id) DO UPDATE SET
    max_programs = EXCLUDED.max_programs,
    max_sessions_per_program = EXCLUDED.max_sessions_per_program,
    max_exercises = EXCLUDED.max_exercises,
    history_days = EXCLUDED.history_days,
    can_export_data = EXCLUDED.can_export_data,
    can_share_programs = EXCLUDED.can_share_programs;

-- Step 3: Update get_user_subscription_summary to include Free fallback
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
  -- Look for subscription with status='active' AND (expires_at IS NULL OR expires_at > NOW())
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
      'max_exercises', sl.max_exercises,
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
  -- IMPORTANT: Never return NULL, always return Free if no subscription found
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
        'max_exercises', sl.max_exercises,
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
Never returns NULL - always returns at least Free entitlement.';
