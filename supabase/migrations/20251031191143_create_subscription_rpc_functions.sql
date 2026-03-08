-- Function: get_user_subscription_summary
-- Returns the active subscription for a user with entitlement and limits information
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
    ORDER BY s.created_at DESC
    LIMIT 1
  );
END;
$$;

-- Function: check_feature_access
-- Checks if a user has access to a specific feature based on their active subscription
-- Returns boolean and limits information if access is granted
CREATE OR REPLACE FUNCTION public.check_feature_access(
  p_user_id UUID,
  p_feature_key TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
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

-- Function: handle_subscription_webhook (helper for Edge Function)
-- Handles upsert of subscription data from RevenueCat webhook
-- This function is called by the Edge Function with service_role privileges
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

