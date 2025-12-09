# Résumé : Configuration RevenueCat - Automatisé vs Manuel

## ✅ Actions Automatisées (Complétées)

### 1. Migrations SQL ✅
- ✅ Migration `create_subscriptions_schema` : Schéma complet avec tables, RLS, index, triggers
- ✅ Migration `insert_initial_subscription_data` : Entitlement "Premium" et limites
- ✅ Migration `create_subscription_rpc_functions` : RPCs (`get_user_subscription_summary`, `check_feature_access`, `handle_subscription_webhook`)

### 2. Edge Function Déployée ✅
- ✅ **Function Name** : `revenuecat-webhook`
- ✅ **Status** : ACTIVE (Version 1)
- ✅ **URL** : `https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook`
- ✅ **Config.toml** : `verify_jwt = false` ajouté pour les futurs déploiements

**Note importante :** L'Edge Function a été déployée avec `verify_jwt: true` par défaut. Vous devrez la désactiver via le Dashboard (voir section manuelle ci-dessous).

---

## ⚠️ Actions Manuelles Requises

### 2. Configuration du Secret RevenueCat dans Supabase

**Status : MANUEL (Impossible via MCP)**

**Raison :** Les outils MCP Supabase ne permettent pas de créer/gérer des secrets via l'API. Cette opération doit être effectuée via le Dashboard Supabase.

**Étapes détaillées :**

1. **Accéder au Dashboard Supabase :**
   - URL : https://supabase.com/dashboard
   - Sélectionnez votre projet **Trainer Test** (ID: `waeeuifpqrwgfoqosqct`)

2. **Naviguer vers les Secrets :**
   - Menu latéral : **Settings** → **Edge Functions** → **Secrets**
   - Ou directement : https://supabase.com/dashboard/project/waeeuifpqrwgfoqosqct/settings/functions

3. **Ajouter le nouveau secret :**
   - Cliquez sur **"Add new secret"** ou **"New Secret"**
   - **Name** : `REVENUECAT_WEBHOOK_SECRET` (exactement ce nom, case-sensitive)
   - **Value** : La clé de signature webhook de RevenueCat (à obtenir à l'étape 4)

4. **Créer/Configurer le webhook dans RevenueCat (étape préalable) :**
   - Allez sur https://app.revenuecat.com
   - Sélectionnez le projet **Trainer (test)** (ID: `proj85a9119d`)
   - Naviguez vers **Integrations** → **Webhooks** (ou **Project Settings** → **Webhooks**)
   - Cliquez sur **"Add new configuration"** ou **"Add Webhook"**
   - Nommez votre webhook (ex: "Supabase Backend")
   - **URL du webhook** : 
     ```
     https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook
     ```
   - **Authorization Header (Optionnel mais recommandé)** : Créez une valeur secrète (ex: `trainer_webhook_secret_2024` ou générez une clé aléatoire)
     - ⚠️ **IMPORTANT** : Cette valeur doit être copiée et ajoutée comme secret dans Supabase (étape 5)
   - Configurez les autres paramètres (environnement, événements) selon vos besoins
   - **Sauvegardez** le webhook

5. **Ajouter le secret dans Supabase :**
   - Retournez dans Supabase Dashboard → Edge Functions → Secrets
   - Cliquez sur **"Add new secret"** ou **"New Secret"**
   - **Name** : `REVENUECAT_WEBHOOK_SECRET` (exactement ce nom, case-sensitive)
   - **Value** : Collez la **même valeur EXACTE** que celle configurée dans le champ "Authorization Header" de RevenueCat (étape 4)
     - Si vous avez mis `Bearer 441c33d902199f99` dans RevenueCat, mettez exactement `Bearer 441c33d902199f99` dans Supabase
     - Si vous avez mis `441c33d902199f99` (sans Bearer) dans RevenueCat, mettez exactement `441c33d902199f99` dans Supabase
     - ⚠️ **Important** : Le préfixe "Bearer " doit être identique des deux côtés (avec ou sans)
     - ⚠️ **Note** : RevenueCat enverra cette valeur exacte dans le header `Authorization`, l'Edge Function la comparera directement
     - ✅ **Le code de l'Edge Function gère automatiquement** les deux formats (avec ou sans Bearer), donc peu importe lequel vous choisissez, tant qu'il est identique des deux côtés
   - Cliquez sur **Save** ou **Create Secret**

6. **Vérification :**

   **a) Vérifier dans Supabase Dashboard :**
   - Retournez dans Supabase Dashboard → **Settings** → **Edge Functions** → **Secrets**
   - Le secret `REVENUECAT_WEBHOOK_SECRET` doit apparaître dans la liste des secrets
   - Vous pouvez voir le **nom** du secret (mais pas la valeur pour des raisons de sécurité)
   - Si vous ne voyez pas le secret dans la liste, retournez à l'étape 5 pour le créer

   **b) Vérifier la correspondance avec RevenueCat :**
   - Ouvrez un nouvel onglet et allez dans RevenueCat Dashboard → **Integrations** → **Webhooks**
   - Ouvrez la configuration de votre webhook (celui que vous avez créé)
   - Dans le champ **"Authorization Header"**, notez la valeur exacte (ou copiez-la)
   - ⚠️ **IMPORTANT** : Cette valeur doit correspondre **caractère par caractère** à celle dans Supabase
   - Vérifiez notamment :
     - Les espaces au début/fin (ils ne doivent pas exister, ou être identiques)
     - La casse (majuscules/minuscules doivent être identiques)
     - Les caractères spéciaux doivent être exactement les mêmes

   **c) Vérifier que l'Edge Function peut y accéder :**
   - Le secret sera automatiquement disponible dans l'Edge Function via `Deno.env.get('REVENUECAT_WEBHOOK_SECRET')`
   - Pour tester, vous pouvez consulter les logs de l'Edge Function après avoir reçu un webhook
   - Si le secret n'est pas configuré, l'Edge Function retournera une erreur `500` avec le message "Webhook secret not configured"
   - Vous pouvez vérifier les logs dans : Supabase Dashboard → **Edge Functions** → **revenuecat-webhook** → **Logs**

   **d) Test de validation (optionnel) :**
   - ⚠️ **Important** : Pour tester correctement, vous devez utiliser un `user_id` (UUID) qui existe dans votre table `auth.users`
   - Récupérez un UUID utilisateur valide depuis Supabase Dashboard → **Table Editor** → `auth.users`
   - Vous pouvez tester manuellement en envoyant une requête avec curl :
     ```bash
     curl -X POST \
       https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook \
       -H "Authorization: VOTRE_VALEUR_SECRETE_ICI" \
       -H "Content-Type: application/json" \
       -d '{"event":{"id":"test-123","type":"INITIAL_PURCHASE","app_user_id":"UUID_UTILISATEUR_VALIDE","product_id":"test-product","entitlement_ids":["Premium"]}}'
     ```
   - Remplacez :
     - `VOTRE_VALEUR_SECRETE_ICI` par la valeur exacte configurée dans RevenueCat (ex: `Bearer 441c33d902199f99`)
     - `UUID_UTILISATEUR_VALIDE` par un UUID réel de votre table `auth.users` (ex: `87f9a881-6d8c-43a3-9ad2-f7982f2fd68a`)
   - **Résultats possibles :**
     - ✅ Si le secret correspond ET l'utilisateur existe :
       - `{"success":true,"event_type":"INITIAL_PURCHASE"}` (200) - Webhook traité avec succès
     - ✅ Si le secret correspond MAIS l'utilisateur n'existe pas :
       - `{"error":"Failed to update subscription"}` (500) - Erreur de foreign key (utilisateur inexistant)
     - ✅ Si le secret correspond MAIS entitlement non trouvé :
       - `{"error":"Entitlement not found"}` (400) - Entitlement "Premium" non trouvé dans la base
     - ❌ Si le secret ne correspond pas :
       - `{"error":"Invalid authorization header"}` (401)
     - ❌ Si le secret n'est pas configuré :
       - `{"error":"Webhook secret not configured"}` (500)

   **📝 Conseils pour éviter les erreurs courantes :**
   - ✅ Utilisez un outil pour copier/coller la valeur (évitez de la retaper manuellement)
   - ✅ Vérifiez qu'il n'y a pas d'espaces supplémentaires au début ou à la fin
   - ✅ Si vous avez mis `Bearer ` dans RevenueCat, mettez aussi `Bearer ` dans Supabase (ou inversement)
   - ✅ Conservez la valeur dans un gestionnaire de mots de passe pour référence future
   - ✅ Si vous modifiez la valeur dans RevenueCat, **n'oubliez pas** de la mettre à jour dans Supabase aussi

**⚠️ Sécurité :** Cette valeur est utilisée pour authentifier les webhooks RevenueCat. RevenueCat l'enverra dans le header `Authorization` de chaque requête POST. Ne la partagez jamais publiquement et utilisez une valeur forte et aléatoire.

---

### 3. Désactiver la Vérification JWT pour l'Edge Function

**Status : MANUEL (Configuration initiale requise)**

**Raison :** Bien que `config.toml` ait été mis à jour pour les futurs déploiements, l'Edge Function a été déployée avec `verify_jwt: true` par défaut. Cette configuration doit être mise à jour via le Dashboard pour la fonction actuellement déployée.

**Étapes détaillées :**

**Option 1 - Via Supabase Dashboard (Recommandé) :**

1. **Accéder aux Edge Functions :**
   - Dashboard Supabase → **Edge Functions** (dans le menu latéral)
   - Ou directement : https://supabase.com/dashboard/project/waeeuifpqrwgfoqosqct/functions

2. **Sélectionner la fonction :**
   - Cliquez sur **revenuecat-webhook**

3. **Désactiver JWT Verification :**
   - Cherchez la section **"Settings"** ou **"Configuration"** de la fonction
   - Trouvez l'option **"Verify JWT"** ou **"Require Authentication"** ou **"JWT Verification"**
   - **Désactivez-la** (toggle off ou checkbox unchecked)
   - ⚠️ **Si vous ne trouvez pas cette option** : Elle peut être dans les paramètres de la fonction ou dans un menu déroulant "Settings"
   - 📝 **Note** : Si vous voyez encore `verify_jwt: true` dans les détails de la fonction, cela confirme qu'il faut le désactiver

4. **Sauvegarder :**
   - Cliquez sur **Save** ou **Update**
   - La fonction devrait se redéployer automatiquement avec la nouvelle configuration

**Option 2 - Via Supabase CLI (Si disponible) :**

```bash
# Si vous avez Supabase CLI installé et configuré
supabase functions update revenuecat-webhook --no-verify-jwt --project-ref waeeuifpqrwgfoqosqct
```

**Pourquoi c'est nécessaire :**
- Les webhooks RevenueCat n'envoient **pas** de JWT Bearer token Supabase
- La sécurité est assurée par l'authorization header configuré dans RevenueCat
- ⚠️ **Sans désactiver le JWT, Supabase rejette la requête AVANT qu'elle n'atteigne votre code Edge Function**
- L'erreur que vous verrez sera : `{"code":401,"message":"Invalid JWT"}` - c'est Supabase qui bloque, pas votre code

**⚠️ Erreur courante :** Si vous recevez `{"code":401,"message":"Invalid JWT"}`, c'est que la vérification JWT est encore activée. Cette erreur vient de Supabase, pas de votre Edge Function.

---

### 4. Configuration du Webhook dans RevenueCat Dashboard

**Status : MANUEL (Impossible via MCP RevenueCat)**

**Raison :** Les outils MCP RevenueCat ne permettent pas de configurer les webhooks. Cette opération doit être effectuée via le Dashboard RevenueCat.

**Étapes détaillées :**

1. **Accéder au Dashboard RevenueCat :**
   - URL : https://app.revenuecat.com
   - Connectez-vous à votre compte
   - Sélectionnez votre projet **Trainer (test)** (ID: `proj85a9119d`)

2. **Naviguer vers les Webhooks :**
   - Menu latéral : **Project Settings** → **Webhooks**
   - Ou directement : https://app.revenuecat.com/projects/proj85a9119d/webhooks

3. **Créer un nouveau webhook :**
   - Cliquez sur **"Add Webhook"** ou **"New Webhook"** ou **"Create Webhook"**

4. **Configurer l'URL :**
   - **Webhook URL** : 
     ```
     https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook
     ```
   - **Method** : `POST` (par défaut, vérifiez qu'il est sélectionné)

5. **Sélectionner les événements :**
   - Cochez les événements suivants (minimum recommandé) :
     - ✅ `INITIAL_PURCHASE` - Premier achat d'un utilisateur
     - ✅ `RENEWAL` - Renouvellement automatique
     - ✅ `CANCELLATION` - Annulation (abonnement valide jusqu'à expiration)
     - ✅ `EXPIRATION` - Expiration d'un abonnement
     - ✅ `REFUND` - Remboursement
     - ✅ `RESTORE` - Restauration d'achats (restore purchases)
   
   **Événements optionnels (recommandés) :**
     - `BILLING_ISSUE` - Problème de facturation (paiement échoué)
     - `PRODUCT_CHANGE` - Changement de produit d'abonnement

6. **Configurer l'Authorization Header (Optionnel mais fortement recommandé) :**
   - Dans le formulaire de création du webhook, trouvez le champ **"Authorization Header"** (optionnel)
   - Créez une valeur secrète forte (ex: générez une chaîne aléatoire de 32+ caractères)
     - Vous pouvez utiliser : `openssl rand -hex 32` ou tout autre générateur de clé
     - Exemple : `trainer_webhook_7a3b9c2d4e5f6a7b8c9d0e1f2a3b4c5d`
   - ⚠️ **IMPORTANT** : Cette **même valeur exacte** doit être ajoutée comme secret `REVENUECAT_WEBHOOK_SECRET` dans Supabase (voir étape 2 ci-dessus)
   - RevenueCat enverra cette valeur dans le header `Authorization` de chaque requête POST

7. **Configurer l'environnement (si applicable) :**
   - Pour le Test Store, sélectionnez **"Sandbox"** ou **"Production"** selon votre configuration
   - Le Test Store envoie généralement des webhooks dans l'environnement **Sandbox**

8. **Sauvegarder le webhook :**
   - Cliquez sur **"Save"**, **"Create"** ou **"Add Webhook"**
   - RevenueCat peut tester automatiquement l'URL (vérifiez les logs)

9. **Vérifier le statut :**
   - Après sauvegarde, le webhook devrait apparaître avec un statut **"Active"** ou **"Enabled"**
   - Vous pouvez voir l'historique des webhooks envoyés dans cette section

10. **Tester le webhook (optionnel mais recommandé) :**
    - RevenueCat propose généralement un bouton **"Test Webhook"** ou **"Send Test Event"**
    - Utilisez-le pour envoyer un événement de test
    - Vérifiez les logs dans Supabase Dashboard → Edge Functions → revenuecat-webhook → Logs
    - Vérifiez que les données apparaissent dans les tables `subscriptions` et `subscription_events`

**URL complète de votre Edge Function :**
```
https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook
```

---

## 📋 Checklist de Vérification

Avant de tester, assurez-vous que :

- [ ] ✅ Les 3 migrations SQL ont été appliquées (vérifié automatiquement)
- [ ] ✅ L'Edge Function `revenuecat-webhook` est déployée (vérifié automatiquement)
- [ ] ⚠️ Le secret `REVENUECAT_WEBHOOK_SECRET` est configuré dans Supabase Dashboard
- [ ] ⚠️ La vérification JWT est désactivée pour `revenuecat-webhook` dans Supabase Dashboard
- [ ] ⚠️ Le webhook est configuré dans RevenueCat Dashboard avec la bonne URL
- [ ] ⚠️ Les événements sont sélectionnés dans RevenueCat (INITIAL_PURCHASE, RENEWAL, etc.)
- [ ] ⚠️ La clé de signature RevenueCat correspond au secret Supabase

---

## 🔍 Comment Vérifier que Tout Fonctionne

### 1. Tester l'Edge Function manuellement

```bash
curl -X OPTIONS \
  https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook \
  -H "Access-Control-Request-Method: POST"
```

Devrait retourner `200 OK` avec les headers CORS.

### 2. Vérifier les tables dans Supabase

- Dashboard → **Table Editor**
- Vérifiez que les tables suivantes existent :
  - `entitlements` (avec au moins une entrée "Premium")
  - `products`
  - `entitlement_products`
  - `subscription_limits` (avec les limites pour Premium)
  - `subscriptions`
  - `subscription_events`

### 3. Tester depuis l'application Example

```bash
cd example
flutter run
```

- Connectez-vous avec un utilisateur
- Allez dans **"Test Subscriptions"**
- Testez **"Get Subscription Summary"** (devrait retourner `null` si pas d'abonnement)
- Testez **"Check Premium"** pour vérifier l'accès

### 4. Déclencher un webhook de test depuis RevenueCat

- RevenueCat Dashboard → **Webhooks** → Votre webhook → **"Test Webhook"** ou **"Send Test Event"**
- Vérifiez les logs dans Supabase Dashboard → **Edge Functions** → **revenuecat-webhook** → **Logs**
- Vérifiez que des données apparaissent dans `subscription_events` et potentiellement `subscriptions`

---

## 📝 URLs et IDs Importants

### Supabase
- **Project ID** : `waeeuifpqrwgfoqosqct`
- **Project Name** : `Trainer Test`
- **Project URL** : `https://waeeuifpqrwgfoqosqct.supabase.co`
- **Edge Function URL** : `https://waeeuifpqrwgfoqosqct.supabase.co/functions/v1/revenuecat-webhook`
- **Dashboard** : https://supabase.com/dashboard/project/waeeuifpqrwgfoqosqct

### RevenueCat
- **Project ID** : `proj85a9119d`
- **Project Name** : `Trainer (test)`
- **Entitlement ID** : `entlcadfef7190`
- **Entitlement Key** : `Premium`
- **Dashboard** : https://app.revenuecat.com/projects/proj85a9119d

---

## ⚠️ Notes Importantes

1. **Test Store :** Les webhooks du Test Store peuvent nécessiter des déclenchements manuels depuis le dashboard RevenueCat ou via le SDK. Les événements ne se déclenchent pas toujours automatiquement.

2. **Ordre de Configuration :** Il est recommandé de suivre cet ordre :
   1. Configurer le secret dans Supabase (étape 2)
   2. Désactiver JWT verification (étape 3)
   3. Configurer le webhook dans RevenueCat (étape 4)

3. **Sécurité :** La désactivation du JWT est sécurisée car la validation est assurée par l'authorization header configuré dans RevenueCat (comme recommandé dans leur [documentation officielle](https://www.revenuecat.com/docs/integrations/webhooks)). Ne désactivez le JWT **que** pour cette fonction spécifique.

4. **Premier Test :** Après configuration complète, utilisez le bouton "Test Webhook" de RevenueCat pour valider que tout fonctionne avant de procéder à des tests réels.

5. **Synchronisation Utilisateurs RevenueCat ↔ Supabase :**
   - ⚠️ **Important** : Vos utilisateurs Supabase actuels ne sont probablement **pas** connus de RevenueCat
   - Pour tester le webhook, ce n'est **pas un problème** : le webhook peut créer un abonnement même si l'utilisateur n'existe pas encore dans RevenueCat
   - **En production** : Vous devrez vous assurer que `app_user_id` (RevenueCat) correspond à l'UUID de l'utilisateur Supabase (`auth.uid()`)
   - **Dans votre application Flutter**, lors de l'initialisation de RevenueCat SDK, configurez l'`app_user_id` avec l'UUID de l'utilisateur Supabase :
     ```dart
     Purchases.configure(
       PurchasesConfiguration(apiKey)
         ..appUserID = user.id, // UUID de Supabase auth.uid()
     );
     ```
   - Cela garantira que les webhooks RevenueCat utiliseront les bons UUID utilisateurs

