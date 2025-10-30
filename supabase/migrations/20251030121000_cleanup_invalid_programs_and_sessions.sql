-- Cleanup invalid data created prior to validations
-- 1) Remove sessions without exercises
-- 2) Remove programs without sessions (including those left empty after step 1)

-- Remove sessions without any session_exercises
DELETE FROM sessions s
WHERE NOT EXISTS (
    SELECT 1 FROM session_exercises se WHERE se.session_id = s.id
);

-- Remove programs without any sessions
DELETE FROM programs p
WHERE NOT EXISTS (
    SELECT 1 FROM sessions s WHERE s.program_id = p.id
);


