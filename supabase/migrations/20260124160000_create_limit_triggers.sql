-- Migration: Create triggers for subscription limit enforcement
-- Description: Creates BEFORE INSERT triggers on programs, sessions, and exercises
--              to enforce subscription limits as a second layer of security.
--              These triggers prevent direct inserts that bypass RPC functions.
--              Triggers reuse the check_user_can_create_resource() function (DRY).
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. DROP TRIGGER IF EXISTS trigger_check_program_limit ON public.programs;
-- 2. DROP TRIGGER IF EXISTS trigger_check_session_limit ON public.sessions;
-- 3. DROP TRIGGER IF EXISTS trigger_check_exercise_limit ON public.exercises;
-- 4. DROP FUNCTION IF EXISTS public.check_program_limit();
-- 5. DROP FUNCTION IF EXISTS public.check_session_limit();
-- 6. DROP FUNCTION IF EXISTS public.check_exercise_limit();

-- Step 1: Create trigger function for programs
CREATE OR REPLACE FUNCTION public.check_program_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_limits jsonb;
BEGIN
  -- Use the reusable helper function
  -- This will raise an exception if limit is exceeded
  v_limits := public.check_user_can_create_resource(NEW.user_id, 'programs');
  
  -- If we get here, the check passed
  RETURN NEW;
END;
$$;

-- Step 2: Create trigger function for sessions
CREATE OR REPLACE FUNCTION public.check_session_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID;
  v_limits jsonb;
BEGIN
  -- Get user_id via program (sessions don't have user_id directly)
  SELECT p.user_id INTO v_user_id
  FROM public.programs p
  WHERE p.id = NEW.program_id;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Program not found for session';
  END IF;

  -- Use the reusable helper function
  -- This will raise an exception if limit is exceeded
  v_limits := public.check_user_can_create_resource(v_user_id, 'sessions_per_program', NEW.program_id);
  
  -- If we get here, the check passed
  RETURN NEW;
END;
$$;

-- Step 3: Create trigger function for exercises
CREATE OR REPLACE FUNCTION public.check_exercise_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_exercise_exists BOOLEAN;
  v_limits jsonb;
BEGIN
  -- Check if exercise already exists (ON CONFLICT will handle it, but we check anyway)
  -- If exercise exists, allow (it's an update via ON CONFLICT, not a new creation)
  SELECT EXISTS(
    SELECT 1 FROM public.exercises
    WHERE user_id = NEW.user_id AND name = NEW.name
  ) INTO v_exercise_exists;

  -- If exercise already exists, allow (it's an update via ON CONFLICT)
  IF v_exercise_exists THEN
    RETURN NEW;
  END IF;

  -- Use the reusable helper function for NEW exercises
  -- This will raise an exception if limit is exceeded
  v_limits := public.check_user_can_create_resource(NEW.user_id, 'exercises');
  
  -- If we get here, the check passed
  RETURN NEW;
END;
$$;

-- Step 4: Create triggers
DROP TRIGGER IF EXISTS trigger_check_program_limit ON public.programs;
CREATE TRIGGER trigger_check_program_limit
  BEFORE INSERT ON public.programs
  FOR EACH ROW
  EXECUTE FUNCTION public.check_program_limit();

DROP TRIGGER IF EXISTS trigger_check_session_limit ON public.sessions;
CREATE TRIGGER trigger_check_session_limit
  BEFORE INSERT ON public.sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.check_session_limit();

DROP TRIGGER IF EXISTS trigger_check_exercise_limit ON public.exercises;
CREATE TRIGGER trigger_check_exercise_limit
  BEFORE INSERT ON public.exercises
  FOR EACH ROW
  EXECUTE FUNCTION public.check_exercise_limit();

-- Add comments
COMMENT ON FUNCTION public.check_program_limit() IS 
'Trigger function to enforce max_programs limit before INSERT on programs table.
Reuses check_user_can_create_resource() function (DRY).';

COMMENT ON FUNCTION public.check_session_limit() IS 
'Trigger function to enforce max_sessions_per_program limit before INSERT on sessions table.
Reuses check_user_can_create_resource() function (DRY).';

COMMENT ON FUNCTION public.check_exercise_limit() IS 
'Trigger function to enforce max_exercises limit before INSERT on exercises table.
Allows existing exercises (ON CONFLICT updates). Reuses check_user_can_create_resource() function (DRY).';
