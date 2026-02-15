-- Migration: Fix sessions_count_by_program type in get_user_limits_with_usage
-- Description: Changes sessions_count_by_program to return integers instead of strings
--              to match the Dart model expectation (Map<String, int>).
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. Restore the function from migration 20260124140000_create_limit_verification_functions.sql
--    (change session_count::int back to session_count::text in jsonb_object_agg)

-- Fix get_user_limits_with_usage to return integers for sessions_count_by_program
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
  -- NOTE: sessions_count_by_program returns values as text (due to jsonb_object_agg limitation),
  -- but the Dart converter (SessionsCountMapConverter) handles the conversion to int
  -- NOTE: exercises_count removed - exercises are now limited per session, not total
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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_user_limits_with_usage(UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION public.get_user_limits_with_usage(UUID) IS 
'Returns subscription limits and current usage counts for a user in a single call.
Optimized for limit checking in RPC functions. Automatically includes Free fallback.
NOTE: sessions_count_by_program values are returned as text (jsonb_object_agg limitation),
but the Dart model uses SessionsCountMapConverter to convert them to integers.';
