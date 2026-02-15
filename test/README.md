# Tests d'Intégration - Limites d'Abonnement

Ce dossier contient les tests d'intégration pour le système de limites d'abonnement Supabase.

## Structure

```
test/
├── fixtures/
│   └── test_accounts.dart          # Comptes de test (Free/Basic/Premium)
├── helpers/
│   └── cleanup_helper.dart          # Helper pour nettoyer les données de test
├── integration/
│   ├── test_setup.dart              # Setup commun pour les tests
│   ├── free_plan_limits_test.dart   # Tests des limites Free Plan
│   ├── basic_plan_limits_test.dart  # Tests des limites Basic Plan
│   ├── premium_plan_limits_test.dart # Tests des limites Premium Plan
│   ├── usage_counters_test.dart     # Tests des compteurs d'utilisation
│   └── limit_events_test.dart       # Tests des événements de limite
└── README.md                        # Ce fichier
```

## Prérequis

1. **Projet Supabase de test séparé** (recommandé)
   - Créez un projet Supabase dédié aux tests
   - Appliquez toutes les migrations nécessaires
   - Configurez les entitlements (Free, Basic, Premium)

2. **Configuration Supabase**
   - Initialisez Supabase dans votre application avec les credentials de test
   - Les credentials doivent être dans `.env.test` (gitignored)

## Setup des Comptes de Test

### 1. Créer les Comptes Utilisateurs

Créez les comptes suivants dans Supabase Auth :

| Email | Mot de passe | Plan attendu |
|-------|--------------|--------------|
| `test-free@trainer.app` | `Trainer2025@` | Free |
| `test-basic@trainer.app` | `Trainer2025@` | Basic |
| `test.premium@trainer.test` | `TestPremium123!` | Premium |

### 2. Créer les Abonnements dans la Base de Données

#### Compte Free (`test-free@trainer.app`)
- Pas besoin d'abonnement explicite
- Le système doit fallback automatiquement vers Free

#### Compte Basic (`test-basic@trainer.app`)
```sql
-- Récupérer l'UUID de l'utilisateur
SELECT id FROM auth.users WHERE email = 'test.basic@trainer.test';

-- Créer l'abonnement Basic (remplacer USER_ID)
INSERT INTO subscriptions (user_id, entitlement_key, status, started_at, expires_at, is_trial)
VALUES (
  'USER_ID',
  'Basic',
  'active',
  NOW(),
  NOW() + INTERVAL '30 days',
  false
);
```

#### Compte Premium (`test.premium@trainer.test`)
```sql
-- Récupérer l'UUID de l'utilisateur
SELECT id FROM auth.users WHERE email = 'test.premium@trainer.test';

-- Créer l'abonnement Premium (remplacer USER_ID)
INSERT INTO subscriptions (user_id, entitlement_key, status, started_at, expires_at, is_trial)
VALUES (
  'USER_ID',
  'Premium',
  'active',
  NOW(),
  NOW() + INTERVAL '30 days',
  false
);
```

### 3. Vérifier les Entitlements

Assurez-vous que les entitlements suivants existent dans la table `entitlements` :

```sql
SELECT * FROM entitlements WHERE entitlement_key IN ('Free', 'Basic', 'Premium');
```

Les limites attendues sont :

| Entitlement | max_programs | max_sessions_per_program | max_exercises_per_session | history_days |
|-------------|--------------|--------------------------|---------------------------|--------------|
| Free | 1 | 2 | 6 | 7 |
| Basic | 5 | 10 | 15 | 30 |
| Premium | NULL (illimité) | 30 | 20 | 365 |

### 4. Script SQL Complet

Voici un script SQL complet pour créer tous les comptes et abonnements :

```sql
-- Note: Exécutez ce script dans l'ordre après avoir créé les utilisateurs via Supabase Auth

-- Fonction helper pour créer un abonnement
CREATE OR REPLACE FUNCTION create_test_subscription(
  p_email TEXT,
  p_entitlement_key TEXT,
  p_status TEXT,
  p_expires_at TIMESTAMPTZ
) RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = p_email;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found: %', p_email;
  END IF;
  
  INSERT INTO subscriptions (user_id, entitlement_key, status, started_at, expires_at, is_trial)
  VALUES (v_user_id, p_entitlement_key, p_status, NOW(), p_expires_at, false)
  ON CONFLICT (user_id) DO UPDATE
  SET entitlement_key = p_entitlement_key,
      status = p_status,
      expires_at = p_expires_at;
  
  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- Créer les abonnements
SELECT create_test_subscription('test-basic@trainer.app', 'Basic', 'active', NOW() + INTERVAL '30 days');
SELECT create_test_subscription('test.premium@trainer.test', 'Premium', 'active', NOW() + INTERVAL '30 days');

-- Nettoyer la fonction helper
DROP FUNCTION create_test_subscription(TEXT, TEXT, TEXT, TIMESTAMPTZ);
```

## Exécution des Tests

### Configuration de l'Environnement

Créez un fichier `.env.test` à la racine du projet (gitignored) :

```env
SUPABASE_URL=https://your-test-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Exécuter les Tests

```bash
# Tous les tests d'intégration
flutter test test/integration/

# Tests d'un plan spécifique
flutter test test/integration/free_plan_limits_test.dart
flutter test test/integration/basic_plan_limits_test.dart
flutter test test/integration/premium_plan_limits_test.dart

# Tests des compteurs et événements
flutter test test/integration/usage_counters_test.dart
flutter test test/integration/limit_events_test.dart

# Un test spécifique
flutter test test/integration/free_plan_limits_test.dart --name "should create 1 program successfully"
```

## Structure des Tests

Les tests sont organisés en fichiers séparés par scénario :

1. **free_plan_limits_test.dart** : Tests des limites du plan Free (1 programme, 2 sessions, 6 exercices)
2. **basic_plan_limits_test.dart** : Tests des limites du plan Basic (5 programmes, 10 sessions, 15 exercices)
3. **premium_plan_limits_test.dart** : Tests des limites du plan Premium (illimité programmes, 30 sessions, 20 exercices)
4. **usage_counters_test.dart** : Tests des compteurs d'utilisation
5. **limit_events_test.dart** : Tests du logging des événements de limite

Chaque fichier utilise le setup commun défini dans `test_setup.dart` pour éviter la duplication de code.

## Nettoyage

Chaque test nettoie automatiquement ses données après exécution via `CleanupHelper`. 

Si vous devez nettoyer manuellement :

```sql
-- Nettoyer les données d'un utilisateur spécifique
DELETE FROM programs WHERE user_id = 'USER_ID';
DELETE FROM subscription_limit_events WHERE user_id = 'USER_ID';
```

## Dépannage

### Erreur : "User not found"
- Vérifiez que les comptes ont été créés dans Supabase Auth
- Vérifiez les emails dans `test_accounts.dart`

### Erreur : "Subscription not found"
- Vérifiez que les abonnements ont été créés dans la table `subscriptions`
- Vérifiez que les `entitlement_key` correspondent (Free, Basic, Premium)

### Erreur : "Entitlement not found"
- Vérifiez que les entitlements existent dans la table `entitlements`
- Vérifiez que les limites sont correctement configurées

### Tests qui échouent de manière inattendue
- Vérifiez que les migrations Supabase sont à jour
- Vérifiez que les fonctions RPC sont correctement déployées
- Vérifiez les logs Supabase pour les erreurs de base de données

## Codes d'Erreur PostgreSQL

Les tests vérifient les codes d'erreur suivants dans les messages PostgreSQL :

- `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y` - Limite de programmes atteinte
- `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y` - Limite de sessions par programme atteinte
- `LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION:X/Y` - Limite d'exercices par séance atteinte

Ces codes sont dans le message de `PostgrestException`, pas dans un champ séparé.

## Notes Importantes

- ⚠️ **Ne jamais utiliser ces comptes en production**
- ⚠️ **Utiliser un projet Supabase séparé pour les tests**
- ⚠️ **Les tests modifient la base de données - ne pas exécuter sur la prod**
- ✅ **Les tests sont idempotents grâce au cleanup automatique**
- ✅ **Chaque test est indépendant et peut être exécuté isolément**
