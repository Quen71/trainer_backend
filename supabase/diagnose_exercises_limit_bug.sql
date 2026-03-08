-- Script de diagnostic pour analyser le bug des limites d'exercices par séance
-- À exécuter dans l'éditeur SQL de Supabase

-- ============================================================================
-- SECTION 1: Vérifier la structure de la table subscription_limits
-- ============================================================================
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'subscription_limits'
ORDER BY ordinal_position;

-- ============================================================================
-- SECTION 2: Vérifier les valeurs actuelles des limites pour chaque entitlement
-- ============================================================================
SELECT 
    e.entitlement_key,
    e.name,
    sl.max_programs,
    sl.max_sessions_per_program,
    sl.max_exercises_per_session,
    sl.history_days
FROM public.entitlements e
LEFT JOIN public.subscription_limits sl ON e.id = sl.entitlement_id
ORDER BY e.priority DESC;

-- ============================================================================
-- SECTION 3: Tester get_user_subscription_summary pour un utilisateur Free
-- ============================================================================
-- Remplacer 'FREE_USER_ID' par l'ID réel de l'utilisateur de test Free
-- SELECT public.get_user_subscription_summary('FREE_USER_ID'::uuid);

-- ============================================================================
-- SECTION 4: Tester get_user_limits_with_usage pour un utilisateur Free
-- ============================================================================
-- Remplacer 'FREE_USER_ID' par l'ID réel de l'utilisateur de test Free
-- SELECT public.get_user_limits_with_usage('FREE_USER_ID'::uuid);

-- ============================================================================
-- SECTION 5: Vérifier la définition actuelle de create_full_program
-- ============================================================================
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'create_full_program' 
  AND pronamespace = 'public'::regnamespace;

-- ============================================================================
-- SECTION 6: Vérifier la définition actuelle de check_user_can_create_resource
-- ============================================================================
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'check_user_can_create_resource' 
  AND pronamespace = 'public'::regnamespace;

-- ============================================================================
-- SECTION 7: Vérifier les migrations appliquées
-- ============================================================================
SELECT version, name, statements, inserted_at
FROM supabase_migrations.schema_migrations
WHERE version >= '20260124190000'
ORDER BY version;
