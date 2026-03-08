-- Insert the Premium entitlement (matching RevenueCat entitlement)
-- RevenueCat entitlement_id: entlcadfef7190, lookup_key: Premium
-- Note: We use gen_random_uuid() to generate a unique ID, but the entitlement_key
-- is what matters for mapping to RevenueCat
INSERT INTO public.entitlements (entitlement_key, name)
VALUES ('Premium', 'Premium Subscription')
ON CONFLICT (entitlement_key) DO NOTHING;

-- Insert subscription limits for Premium entitlement
-- Adjust these values according to your business requirements
INSERT INTO public.subscription_limits (
  entitlement_id,
  max_programs,
  max_sessions_per_program,
  history_days,
  max_exercises,
  can_export_data,
  can_share_programs,
  metadata
)
SELECT
  e.id,
  50,  -- max_programs
  30,  -- max_sessions_per_program
  365, -- history_days (1 year)
  200, -- max_exercises
  true, -- can_export_data
  true, -- can_share_programs
  '{}'::jsonb -- metadata
FROM public.entitlements e
WHERE e.entitlement_key = 'Premium'
ON CONFLICT (entitlement_id) DO NOTHING;

