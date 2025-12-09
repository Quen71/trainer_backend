# Analyse du Bug : Abonnement Annual Non Créé

## Problème Identifié

Le webhook pour l'achat `premium_annual_subscription` a été reçu (événement `INITIAL_PURCHASE` enregistré à `13:35:28`), mais l'abonnement en base Supabase n'a **jamais** été mis à jour avec le `product_id` Annual. L'abonnement est resté avec le `product_id` Monthly (`eab4d335-221a-4a88-ac57-578595697835`).

## Séquence Temporelle

1. **13:34:19** : Webhook `INITIAL_PURCHASE` pour `premium_monthly_subscription` ✅
   - Abonnement créé avec `product_id` = Monthly
   - Status : `active`

2. **13:35:28** : Webhook `INITIAL_PURCHASE` pour `premium_annual_subscription` ⚠️
   - Événement enregistré dans `subscription_events`
   - **Abonnement NON mis à jour** (reste avec Monthly)

3. **13:42:14 - 13:58:17** : Plusieurs webhooks `RENEWAL` pour Monthly
   - L'abonnement est mis à jour avec les renouvellements Monthly
   - Status final : `expired`

## Analyse du Code Edge Function

### Logique Actuelle (lignes 111-169)

1. **Cherche l'entitlement via `entitlement_ids`** (lignes 115-126)
   - Si `event.entitlement_ids` existe, cherche dans `entitlements` table
   - Pour Annual : `entitlement_ids` = `null` → Skip

2. **Cherche l'entitlement via `product_id`** (lignes 128-148)
   - Cherche le produit `premium_annual_subscription` dans `products` table
   - Trouve le lien dans `entitlement_products` → Obtient `entitlement_id`
   - **Problème potentiel** : Le produit Annual n'existait peut-être pas encore au moment du webhook

3. **Fallback vers "Premium"** (lignes 150-161)
   - Si aucun entitlement trouvé, utilise "Premium" par défaut

### Logique de Création de Produit (lignes 172-205)

1. **Cherche le produit existant** (lignes 173-180)
   - Si `premium_annual_subscription` existe → utilise son `id`
   
2. **Crée le produit si nécessaire** (lignes 182-205)
   - Si le produit n'existe pas, le crée
   - **Crée le lien** dans `entitlement_products` après création
   - **MAIS** : Le `entitlementId` a déjà été déterminé AVANT (lignes 111-169)

## Bug Identifié

### Scénario du Bug

Quand le webhook Annual arrive **pour la première fois** :

1. ✅ `entitlement_ids` = `null` → Skip première recherche
2. ❌ Recherche via `product_id` : `premium_annual_subscription` **n'existe pas encore** → Skip
3. ✅ Fallback vers "Premium" → `entitlementId` = UUID de Premium
4. ✅ Crée le produit `premium_annual_subscription` (ligne 183-192)
5. ✅ Crée le lien `entitlement_products` (ligne 200-203)
6. ✅ Appelle `handle_subscription_webhook` avec le bon `entitlement_id` et `product_id`

**MAIS** : L'appel à `handle_subscription_webhook` devrait normalement faire un `UPDATE` via `ON CONFLICT` car il y a déjà un abonnement avec le même `(user_id, entitlement_id)`.

### Pourquoi l'UPDATE n'a pas fonctionné ?

**Hypothèse 1** : Le `productId` était `null` au moment de l'appel
- Si `productError` a été déclenché (ligne 194-195), `productId` reste `null`
- L'appel RPC avec `p_product_id: null` pourrait échouer ou être ignoré
- **Vérification** : Le produit Annual existe maintenant, donc il a été créé → Le `productId` n'était probablement pas null

**Hypothèse 2** : Erreur silencieuse dans `handle_subscription_webhook`
- La fonction RPC pourrait avoir échoué silencieusement
- Les logs Edge Function ne montrent pas d'erreur 500 au moment du webhook Annual
- **Mais** : Les logs montrent uniquement les requêtes HTTP, pas les erreurs internes

**Hypothèse 3** : Race condition
- Le webhook Annual arrive pendant le traitement d'un autre webhook
- Un RENEWAL Monthly pourrait avoir été traité juste après, écrasant l'UPDATE Annual
- **Peu probable** : Les webhooks sont séquentiels normalement

**Hypothèse 4** : Problème avec `handle_subscription_webhook` RPC
- La fonction pourrait ne pas retourner d'erreur mais ne pas faire l'UPDATE
- Vérifier la fonction SQL pour des problèmes potentiels

## Solution Proposée

### Fix 1 : Améliorer la Logique de Recherche d'Entitlement

Le problème principal est que la recherche d'entitlement se fait **AVANT** la création du produit. Si le produit n'existe pas encore, on utilise le fallback "Premium", ce qui est correct. Mais il faut s'assurer que le produit est bien créé et lié avant d'appeler le RPC.

**Correction proposée** :
1. Créer/obtenir le produit **EN PREMIER** (lignes 171-205)
2. Ensuite, rechercher l'entitlement via le lien `entitlement_products` si `entitlement_ids` est null
3. Cela garantit que le produit existe et est lié avant la recherche d'entitlement

### Fix 2 : Ajouter des Logs Détaillés

Ajouter des `console.log` dans l'Edge Function pour tracer :
- L'entitlement trouvé
- Le produit créé/obtenu
- Les paramètres passés à `handle_subscription_webhook`
- Les erreurs éventuelles de la fonction RPC

### Fix 3 : Vérifier la Fonction RPC

La fonction `handle_subscription_webhook` semble correcte avec `ON CONFLICT DO UPDATE`, mais vérifier :
- Si elle retourne bien l'ID de l'abonnement mis à jour
- Si elle gère correctement les cas où `product_id` est null
- Si elle met bien à jour tous les champs nécessaires

## Test de Validation

Pour valider le fix :

1. Supprimer l'abonnement existant pour l'utilisateur test
2. Réacheter Premium Monthly
3. Réacheter Premium Annual immédiatement après
4. Vérifier que l'abonnement en base est mis à jour avec `product_id` = Annual
5. Vérifier les logs Edge Function pour confirmer le traitement

## Conclusion

Le bug semble provenir d'une **race condition ou d'une erreur silencieuse** lors de l'appel à `handle_subscription_webhook`. La solution consiste à :
1. Réorganiser la logique pour créer le produit avant de rechercher l'entitlement
2. Ajouter des logs détaillés pour tracer le problème
3. Vérifier que la fonction RPC fonctionne correctement

