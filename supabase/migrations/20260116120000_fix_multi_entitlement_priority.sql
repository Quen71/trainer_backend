-- Migration: Fix multi-entitlement priority in get_user_subscription_summary
-- Problem: When a user has multiple active subscriptions (e.g., Basic + Premium),
--          the function returns the most recently created one, not the highest tier.
-- Solution: Add entitlement priority and return the highest-priority active subscription.

-- Add priority column to entitlements table
ALTER TABLE public.entitlements
ADD COLUMN IF NOT EXISTS priority int NOT NULL DEFAULT 0;

-- Update existing entitlements with priorities (higher = better)
-- Assuming standard entitlement keys: Free < Basic < Premium
UPDATE public.entitlements
SET priority = CASE
  WHEN LOWER(entitlement_key) = 'free' THEN 0
  WHEN LOWER(entitlement_key) = 'basic' THEN 10
  WHEN LOWER(entitlement_key) = 'premium' THEN 20
  ELSE 0
END;

-- Update get_user_subscription_summary to prioritize by entitlement priority
CREATE OR REPLACE FUNCTION public.get_user_subscription_summary(p_user_id UUID)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID := COALESCE(p_user_id, auth.uid());
BEGIN
  -- Verify the user is accessing their own data
  IF v_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: can only view own subscription';
  END IF;

  RETURN (
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
        'metadata', sl.metadata
      )
    )
    FROM public.subscriptions s
    INNER JOIN public.entitlements e ON s.entitlement_id = e.id
    LEFT JOIN public.products p ON s.product_id = p.id
    LEFT JOIN public.subscription_limits sl ON e.id = sl.entitlement_id
    WHERE s.user_id = v_user_id
      AND s.status IN ('active', 'trialing', 'in_grace')
      AND (s.expires_at IS NULL OR s.expires_at > now())
    -- ORDER BY priority first (highest = best), then by created_at
    ORDER BY e.priority DESC, s.created_at DESC
    LIMIT 1
  );
END;
$$;

-- Add comment explaining the priority system
COMMENT ON COLUMN public.entitlements.priority IS 'Priority for multi-entitlement resolution (higher = better). Used when a user has multiple active subscriptions to determine which one to return.';
