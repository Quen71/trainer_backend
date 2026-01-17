-- Migration: Add RPC function to get entitlement limits by key
-- This function allows fetching subscription limits directly by entitlement key
-- without needing a subscription record (useful for immediate post-purchase feedback)

CREATE OR REPLACE FUNCTION public.get_entitlement_limits_by_key(
  p_entitlement_key TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_build_object(
      'max_programs', sl.max_programs,
      'max_sessions_per_program', sl.max_sessions_per_program,
      'history_days', sl.history_days,
      'max_exercises', sl.max_exercises,
      'can_export_data', sl.can_export_data,
      'can_share_programs', sl.can_share_programs,
      'metadata', COALESCE(sl.metadata, '{}'::jsonb)
    )
    FROM public.entitlements e
    LEFT JOIN public.subscription_limits sl ON e.id = sl.entitlement_id
    WHERE e.entitlement_key = p_entitlement_key
  );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_entitlement_limits_by_key(TEXT) TO authenticated;

COMMENT ON FUNCTION public.get_entitlement_limits_by_key(TEXT) IS 
'Returns subscription limits for a given entitlement key (e.g., "Premium", "Basic"). 
Used for immediate post-purchase feedback without waiting for webhook processing.';
