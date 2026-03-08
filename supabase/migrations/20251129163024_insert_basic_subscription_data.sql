-- Insert Basic entitlement (matching RevenueCat entitlement)
-- RevenueCat entitlement_id: entl2b801dae26, lookup_key: Basic
INSERT INTO public.entitlements (entitlement_key, name)
VALUES ('Basic', 'Basic Subscription')
ON CONFLICT (entitlement_key) DO NOTHING;

-- Insert subscription limits for Basic entitlement (reduced limits compared to Premium)
-- Limits comparison:
-- | Limit                    | Basic | Premium |
-- |--------------------------|-------|---------|
-- | max_programs             | 5     | 50      |
-- | max_sessions_per_program | 10    | 30      |
-- | history_days             | 30    | 365     |
-- | max_exercises            | 50    | 200     |
-- | can_export_data          | false | true    |
-- | can_share_programs       | false | true    |
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
  5,     -- max_programs (Premium: 50)
  10,    -- max_sessions_per_program (Premium: 30)
  30,    -- history_days (Premium: 365)
  50,    -- max_exercises (Premium: 200)
  false, -- can_export_data (Premium: true)
  false, -- can_share_programs (Premium: true)
  '{}'::jsonb
FROM public.entitlements e
WHERE e.entitlement_key = 'Basic'
ON CONFLICT (entitlement_id) DO NOTHING;

