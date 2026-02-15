-- Migration: Create performance indexes for limit checking queries
-- Description: Creates indexes on programs.user_id, sessions.program_id, and exercises.user_id
--              to optimize COUNT() queries used in subscription limit verification.
--              These indexes are created BEFORE the verification functions to ensure
--              optimal performance from the start.
--
-- ROLLBACK INSTRUCTIONS:
-- To rollback this migration:
-- 1. DROP INDEX IF EXISTS public.idx_programs_user_id;
-- 2. DROP INDEX IF EXISTS public.idx_sessions_program_id;
-- 3. DROP INDEX IF EXISTS public.idx_exercises_user_id;
-- 4. DROP INDEX IF EXISTS public.idx_programs_user_created;

-- Step 1: Create index on programs.user_id for COUNT queries
CREATE INDEX IF NOT EXISTS idx_programs_user_id 
ON public.programs(user_id);

-- Step 2: Create index on sessions.program_id for COUNT queries per program
CREATE INDEX IF NOT EXISTS idx_sessions_program_id 
ON public.sessions(program_id);

-- Step 3: Create index on exercises.user_id for COUNT queries
CREATE INDEX IF NOT EXISTS idx_exercises_user_id 
ON public.exercises(user_id);

-- Step 4: Create composite index for sorting programs by user and creation date
-- This is useful for pagination and ordering queries
CREATE INDEX IF NOT EXISTS idx_programs_user_created 
ON public.programs(user_id, created_at DESC);

-- Add comments for documentation
COMMENT ON INDEX public.idx_programs_user_id IS 
'Index for optimizing COUNT queries on programs per user (subscription limit checks)';

COMMENT ON INDEX public.idx_sessions_program_id IS 
'Index for optimizing COUNT queries on sessions per program (subscription limit checks)';

COMMENT ON INDEX public.idx_exercises_user_id IS 
'Index for optimizing COUNT queries on exercises per user (subscription limit checks)';

COMMENT ON INDEX public.idx_programs_user_created IS 
'Composite index for optimizing queries that filter by user_id and order by created_at DESC';
