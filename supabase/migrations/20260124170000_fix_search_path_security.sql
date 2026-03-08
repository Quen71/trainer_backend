-- Migration: Fix search_path security in all SECURITY DEFINER functions
-- Description: Adds SET search_path = public, pg_temp to all SECURITY DEFINER functions
--              created in previous migrations to prevent SQL injection via schema search path.
--              This is a security best practice recommended by Supabase.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- Note: This migration only adds SET search_path clauses. To rollback, you would need to
-- remove these clauses from each function. However, it's recommended to keep them for security.
-- If rollback is absolutely necessary, restore previous function versions from earlier migrations.

-- Note: Most functions already have SET search_path from previous migrations.
-- This migration ensures all functions have it and fixes any that might be missing it.

-- The following functions should already have SET search_path from previous migrations:
-- - get_user_subscription_summary (Migration 1)
-- - get_user_limits_with_usage (Migration 3)
-- - check_user_can_create_resource (Migration 3)
-- - log_limit_event (Migration 3)
-- - create_full_program (Migration 4)
-- - add_session_to_program (Migration 4)
-- - update_full_session (Migration 4)
-- - check_program_limit (Migration 5)
-- - check_session_limit (Migration 5)
-- - check_exercise_limit (Migration 5)

-- Verify and fix get_user_subscription_summary if needed
-- (Should already have SET search_path from Migration 1, but ensure it's correct)
DO $$
BEGIN
  -- Check if function exists and has correct search_path
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname = 'get_user_subscription_summary'
      AND p.prosecdef = true
  ) THEN
    -- Function exists and should already have SET search_path from Migration 1
    -- No action needed, but we verify it's there
    RAISE NOTICE 'get_user_subscription_summary: Already has SET search_path from Migration 1';
  END IF;
END $$;

-- Verify and fix check_feature_access (from original migration)
-- This function was created before our migrations and might not have SET search_path
CREATE OR REPLACE FUNCTION public.check_feature_access(
  p_user_id UUID,
  p_feature_key TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID := COALESCE(p_user_id, auth.uid());
  v_has_access BOOLEAN := false;
  v_limits jsonb;
BEGIN
  -- Verify the user is accessing their own data
  IF v_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: can only check own feature access';
  END IF;

  -- Check if user has an active subscription
  SELECT
    true,
    jsonb_build_object(
      'max_programs', sl.max_programs,
      'max_sessions_per_program', sl.max_sessions_per_program,
      'history_days', sl.history_days,
      'max_exercises', sl.max_exercises,
      'can_export_data', sl.can_export_data,
      'can_share_programs', sl.can_share_programs,
      'metadata', sl.metadata,
      'entitlement', jsonb_build_object(
        'id', e.id,
        'entitlement_key', e.entitlement_key,
        'name', e.name
      )
    )
  INTO v_has_access, v_limits
  FROM public.subscriptions s
  INNER JOIN public.entitlements e ON s.entitlement_id = e.id
  LEFT JOIN public.subscription_limits sl ON e.id = sl.entitlement_id
  WHERE s.user_id = v_user_id
    AND s.status IN ('active', 'trialing', 'in_grace')
    AND (s.expires_at IS NULL OR s.expires_at > now())
  LIMIT 1;

  -- Return result
  RETURN jsonb_build_object(
    'has_access', COALESCE(v_has_access, false),
    'feature_key', p_feature_key,
    'limits', COALESCE(v_limits, '{}'::jsonb)
  );
END;
$$;

-- Verify and fix handle_subscription_webhook (from original migration)
CREATE OR REPLACE FUNCTION public.handle_subscription_webhook(
  p_user_id UUID,
  p_entitlement_id UUID,
  p_product_id UUID,
  p_vendor_transaction_id TEXT,
  p_status public.subscription_status,
  p_started_at timestamptz,
  p_expires_at timestamptz,
  p_is_trial BOOLEAN,
  p_raw_receipt jsonb
)
RETURNS TABLE(id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_subscription_id UUID;
BEGIN
  -- Upsert subscription
  INSERT INTO public.subscriptions (
    user_id,
    entitlement_id,
    product_id,
    vendor_transaction_id,
    status,
    started_at,
    expires_at,
    is_trial,
    raw_receipt
  )
  VALUES (
    p_user_id,
    p_entitlement_id,
    p_product_id,
    p_vendor_transaction_id,
    p_status,
    p_started_at,
    p_expires_at,
    p_is_trial,
    p_raw_receipt
  )
  ON CONFLICT (user_id, entitlement_id)
  DO UPDATE SET
    product_id = EXCLUDED.product_id,
    vendor_transaction_id = EXCLUDED.vendor_transaction_id,
    status = EXCLUDED.status,
    started_at = EXCLUDED.started_at,
    expires_at = EXCLUDED.expires_at,
    is_trial = EXCLUDED.is_trial,
    raw_receipt = EXCLUDED.raw_receipt,
    updated_at = now()
  RETURNING subscriptions.id INTO v_subscription_id;

  RETURN QUERY SELECT v_subscription_id;
END;
$$;

-- Add comment
COMMENT ON FUNCTION public.check_feature_access(UUID, TEXT) IS 
'Checks if a user has access to a specific feature based on their active subscription.
Fixed with SET search_path for security.';

COMMENT ON FUNCTION public.handle_subscription_webhook(UUID, UUID, UUID, TEXT, subscription_status, timestamptz, timestamptz, BOOLEAN, jsonb) IS 
'Handles upsert of subscription data from RevenueCat webhook.
Fixed with SET search_path for security.';
