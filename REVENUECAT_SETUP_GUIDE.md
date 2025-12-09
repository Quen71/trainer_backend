# Guide de Configuration RevenueCat - Actions Automatisées vs Manuelles

## ✅ Actions Automatisées (Déjà Complétées)

### 1. Migrations SQL Appliquées ✅

**Statut : TERMINÉ**

Les trois migrations suivantes ont été appliquées automatiquement à votre projet Supabase (`waeeuifpqrwgfoqosqct`) :

- ✅ `create_subscriptions_schema` : Création du schéma complet (tables, RLS, index, triggers)
- ✅ `insert_initial_subscription_data` : Insertion de l'entitlement "Premium" et de ses limites
- ✅ `create_subscription_rpc_functions` : Création des RPCs (`get_user_subscription_summary`, `check_feature_access`, `handle_subscription_webhook`)

**Tables créées :**
- `entitlements`
- `products`
- `entitlement_products`
- `subscription_limits`
- `subscriptions`
- `subscription_events`

### 2. Edge Function Déployée ✅

**Statut : TERMINÉ**

L'Edge Function `revenuecat-webhook` a été déployée avec succès.

**URL de l'Edge Function :**
```
https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook
```

**Détails du déploiement :**
- **ID** : `4c517790-a897-4a4b-b3ec-832397ef6a69`
- **Version** : 1
- **Statut** : ACTIVE
- **Verify JWT** : true (activé par défaut)

---

## ⚠️ Actions Manuelles Requises

### 2. Configuration du Secret RevenueCat dans Supabase

**Pourquoi manuel ?** Les outils MCP Supabase ne permettent pas de créer/gérer des secrets via l'API. Cela doit être fait via le Dashboard Supabase.

**Étapes à suivre :**

1. **Accéder au Dashboard Supabase :**
   - Allez sur https://supabase.com/dashboard
   - Sélectionnez votre projet `Trainer Test` (ID: `waeeuifpqrwgfoqosqct`)

2. **Naviguer vers les Secrets :**
   - Dans le menu latéral, allez dans **Settings** → **Edge Functions** → **Secrets**

3. **Ajouter le secret :**
   - Cliquez sur **Add Secret**
   - **Name** : `REVENUECAT_WEBHOOK_SECRET`
   - **Value** : La clé de signature webhook de RevenueCat (vous l'obtiendrez à l'étape 4)

4. **Obtenir la clé de signature depuis RevenueCat :**
   - Dans RevenueCat Dashboard, allez dans votre projet `Trainer (test)` (ID: `proj85a9119d`)
   - Naviguez vers **Project Settings** → **Webhooks**
   - Copiez la **Webhook Signing Key** (ou créez-en une nouvelle si elle n'existe pas)

5. **Vérifier le secret :**
   - Le secret doit être visible dans la liste des secrets Supabase
   - Il sera automatiquement disponible dans l'Edge Function via `Deno.env.get('REVENUECAT_WEBHOOK_SECRET')`

**Note importante :** La clé de signature RevenueCat est utilisée pour valider que les webhooks proviennent bien de RevenueCat et non d'un tiers malveillant.

---

### 3. Configuration du Webhook dans RevenueCat Dashboard

**Pourquoi manuel ?** Les outils MCP RevenueCat ne permettent pas de configurer les webhooks. Cette opération doit être effectuée via le Dashboard RevenueCat.

**Étapes à suivre :**

1. **Accéder au Dashboard RevenueCat :**
   - Allez sur https://app.revenuecat.com
   - Connectez-vous à votre compte
   - Sélectionnez votre projet **Trainer (test)** (ID: `proj85a9119d`)

2. **Naviguer vers les Webhooks :**
   - Dans le menu latéral, allez dans **Project Settings** → **Webhooks**

3. **Ajouter un nouveau webhook :**
   - Cliquez sur **Add Webhook** ou **New Webhook**
   - **URL du webhook** : 
     ```
     https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook
     ```
   - **Method** : `POST` (par défaut)

4. **Sélectionner les événements à écouter :**
   - Cochez les événements suivants :
     - ✅ `INITIAL_PURCHASE` : Premier achat d'un utilisateur
     - ✅ `RENEWAL` : Renouvellement automatique d'un abonnement
     - ✅ `CANCELLATION` : Annulation d'un abonnement (mais toujours valide jusqu'à expiration)
     - ✅ `EXPIRATION` : Expiration d'un abonnement
     - ✅ `REFUND` : Remboursement
     - ✅ `RESTORE` : Restauration d'achats (restore purchases)
     - ✅ `BILLING_ISSUE` : Problème de facturation (facultatif mais recommandé)
     - ✅ `PRODUCT_CHANGE` : Changement de produit (facultatif)

5. **Configurer la clé de signature :**
   - **Webhook Signing Key** : Générer ou copier la clé existante
   - ⚠️ **IMPORTANT** : Copiez cette clé et ajoutez-la comme secret dans Supabase (étape 2 ci-dessus)

6. **Environnement :**
   - Pour le Test Store, vous pouvez utiliser l'environnement **Sandbox** ou **Production** selon votre configuration
   - Le Test Store envoie généralement des webhooks dans l'environnement **Sandbox**

7. **Sauvegarder le webhook :**
   - Cliquez sur **Save** ou **Create Webhook**
   - RevenueCat va tester l'URL (vérifiez les logs si nécessaire)

8. **Vérifier le webhook :**
   - Après sauvegarde, vous devriez voir un statut "Active" ou "Enabled"
   - RevenueCat peut envoyer un webhook de test (vérifiez les logs Supabase)

**URL complète de votre Edge Function :**
```
https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook
```

---

## 🔍 Vérification et Tests

### Tester l'Edge Function

1. **Vérifier que l'Edge Function est accessible :**
   ```bash
   curl https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook \
     -X OPTIONS \
     -H "Access-Control-Request-Method: POST"
   ```
   Devrait retourner `200 OK` avec les headers CORS.

2. **Tester avec un webhook RevenueCat :**
   - Dans RevenueCat Dashboard → Webhooks, vous pouvez déclencher un webhook de test
   - Vérifiez les logs dans Supabase Dashboard → Edge Functions → revenuecat-webhook → Logs

3. **Vérifier les données dans Supabase :**
   - Allez dans Supabase Dashboard → Table Editor
   - Vérifiez que les tables `subscriptions` et `subscription_events` sont créées
   - Vérifiez que l'entitlement "Premium" existe dans la table `entitlements`

### Tester depuis l'Application Example

1. **Lancer l'application example :**
   ```bash
   cd example
   flutter run
   ```

2. **Tester les fonctionnalités :**
   - Connectez-vous avec un utilisateur
   - Allez dans "Test Subscriptions"
   - Testez "Get Subscription Summary" (devrait retourner `null` si pas d'abonnement)
   - Testez "Check Premium" pour vérifier l'accès

---

## 📝 Résumé des URLs et IDs

### Supabase
- **Project ID** : `waeeuifpqrwgfoqosqct`
- **Project URL** : `https://waeeuifpqrwgfoqosqct.supabase.co`
- **Edge Function URL** : `https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook`

### RevenueCat
- **Project ID** : `proj85a9119d`
- **Project Name** : `Trainer (test)`
- **Entitlement ID** : `entlcadfef7190`
- **Entitlement Key** : `Premium`

---

## ⚠️ Notes Importantes

1. **Test Store :** Vous utilisez le Test Store de RevenueCat, donc les webhooks peuvent ne pas se déclencher automatiquement. Vous devrez peut-être déclencher des événements manuellement depuis le dashboard RevenueCat ou via le SDK.

2. **JWT Verification :** ⚠️ **IMPORTANT** - L'Edge Function a été déployée avec `verify_jwt: true` par défaut. Les webhooks RevenueCat ne passent **PAS** de JWT Bearer token, ils utilisent uniquement la signature HMAC dans le header `X-RevenueCat-Signature`. Vous devrez **désactiver la vérification JWT** pour cette fonction :
   
   **Option 1 - Via Supabase Dashboard :**
   - Allez dans **Edge Functions** → **revenuecat-webhook**
   - Désactivez l'option "Verify JWT" ou "Require Authentication"
   
   **Option 2 - Via Supabase CLI (si disponible) :**
   ```bash
   supabase functions update revenuecat-webhook --no-verify-jwt
   ```
   
   La validation de sécurité sera assurée par la signature HMAC RevenueCat (`X-RevenueCat-Signature`), donc la désactivation du JWT est sécurisée.

3. **Secrets :** Assurez-vous que le secret `REVENUECAT_WEBHOOK_SECRET` est bien configuré dans Supabase avant que RevenueCat n'envoie des webhooks, sinon ils échoueront.

4. **Premier Test :** Après configuration, testez avec un webhook de test depuis RevenueCat pour valider que tout fonctionne correctement.

