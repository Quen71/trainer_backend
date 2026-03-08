-- Migration: Remove exercise limit trigger
-- Description: Removes the trigger on exercises table since exercises are now
--              limited per session (checked in RPC functions), not as a total count.
--              The check is now done at the session_exercises level in RPC functions.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. Restore trigger from migration 20260124160000_create_limit_triggers.sql

-- Drop the trigger and function
DROP TRIGGER IF EXISTS trigger_check_exercise_limit ON public.exercises;
DROP FUNCTION IF EXISTS public.check_exercise_limit();

-- Add comment explaining why the trigger was removed
COMMENT ON TABLE public.exercises IS 
'Stores a user''s personal library of exercises.
NOTE: Exercise limits are now enforced per session (max_exercises_per_session) 
in RPC functions, not as a total count. The trigger on this table has been removed.';
