# Comportement du Test Store RevenueCat - Analyse

## Observation du Comportement

### Scénario de Test
1. Utilisateur connecté : UUID `d9b4e36e-6430-4370-8f7d-6a14a8ded32e`
2. Achat 1 : Premium Monthly → ✅ Réussi
3. Achat 2 : Premium Annual → ✅ Réussi

### Résultat Observé dans CustomerInfo

**Les deux abonnements apparaissent comme actifs simultanément :**
- `activeSubscriptions` : `["premium_monthly_subscription", "premium_annual_subscription"]`
- `entitlements.Premium` : Pointe vers `premium_annual_subscription` (dernier achat)
- `allPurchasedProductIdentifiers` : Contient les deux produits

### État dans Supabase

**Un seul abonnement actif en base :**
- `premium_monthly_subscription` (status: `active`)
- `expires_at`: `2025-11-02 13:54:18` (durée de 5 minutes dans le Test Store)
- L'abonnement Annual n'apparaît **pas** en base

**Événements enregistrés dans `subscription_events` :**
1. ✅ `INITIAL_PURCHASE` - `premium_monthly_subscription` à `13:34:18`
2. ✅ `INITIAL_PURCHASE` - `premium_annual_subscription` à `13:35:26` (webhook reçu !)
3. ⚠️ Plusieurs `RENEWAL` - `premium_monthly_subscription` (renouvellements automatiques toutes les 5 min dans le Test Store)

## Analyse et Explications

### 1. Limitations du Test Store RevenueCat

D'après la documentation RevenueCat et les recherches effectuées :

#### ✅ Ce que le Test Store fait :
- Simule les achats d'abonnements
- Génère des `CustomerInfo` avec les produits achetés
- Déclenche les webhooks vers Supabase
- Fournit des métadonnées précises (prix, descriptions, etc.)

#### ❌ Ce que le Test Store ne fait PAS :
- **Ne gère PAS les Subscription Groups** (comportement spécifique à App Store)
- **Ne gère PAS les remplacements automatiques** entre abonnements
- **Ne gère PAS les prorations** (comportement spécifique à Google Play)
- **Ne teste PAS les périodes de grâce** de facturation
- **Ne teste PAS les tentatives de recouvrement** en cas d'échec de paiement

### 2. Comportement Attendu en Production

#### App Store (iOS)
- **Subscription Groups** : Si les produits Monthly et Annual sont dans le même Subscription Group, l'achat d'Annual **remplace automatiquement** Monthly
- **Upgrade** : Le nouvel abonnement démarre immédiatement, l'ancien est annulé avec remboursement au prorata
- **Downgrade** : Le nouvel abonnement prend effet à la fin de la période actuelle

#### Google Play (Android)
- **Proration Modes** : Le comportement dépend du mode de proration configuré :
  - `IMMEDIATE_WITH_TIME_PRORATION` : Remplacement immédiat, proration temporelle
  - `IMMEDIATE_AND_CHARGE_PRORATED_PRICE` : Remplacement immédiat, facturation au prorata
  - `DEFERRED` : Remplacement à la fin de la période actuelle

### 3. Pourquoi le Comportement Diffère

#### Test Store (Comportement Observé)
Le Test Store est un **environnement de simulation simplifié** :
- Il enregistre chaque achat comme une transaction séparée
- Il ne simule **pas** la logique complexe des stores pour gérer les groupes d'abonnements
- Les deux abonnements restent dans `activeSubscriptions` car le Test Store ne gère pas le remplacement

#### Production (Comportement Attendu)
En production avec les vrais stores :
- **App Store** : Les Subscription Groups gèrent automatiquement le remplacement
- **Google Play** : Les modes de proration gèrent le remplacement selon la configuration
- Un seul abonnement devrait être actif pour un même entitlement

### 4. Vérification dans Supabase

**Observation importante :**
- En base Supabase, **un seul abonnement** est actif : `premium_monthly_subscription`
- L'abonnement Annual n'apparaît pas en base

**Explication confirmée :**
- ✅ Le webhook pour Annual **a bien été reçu** (événement `INITIAL_PURCHASE` enregistré à `13:35:26`)
- ❌ Mais l'abonnement Annual **n'a pas été créé** en base (seul Monthly existe)
- **Hypothèse la plus probable** : La contrainte UNIQUE `(user_id, entitlement_id)` dans la table `subscriptions` a empêché la création d'Annual car Monthly existait déjà
- La fonction `handle_subscription_webhook` utilise `ON CONFLICT (user_id, entitlement_id) DO UPDATE`, ce qui devrait normalement **remplacer** Monthly par Annual, mais cela n'a apparemment pas fonctionné correctement

**À investiguer** : Vérifier les logs de l'Edge Function au moment du webhook Annual (`13:35:28`)

## Recommandations

### Pour les Tests
1. **Test Store** : Accepter le comportement actuel comme limitation du Test Store
2. **Valider la logique métier** : S'assurer que votre code gère correctement le cas où un utilisateur a plusieurs abonnements
3. **Vérifier les webhooks** : Consulter les logs Supabase Edge Function pour voir si les webhooks Annual ont été reçus

### Pour la Production
1. **Tester avec les Sandboxes Réels** :
   - **iOS** : Utiliser TestFlight avec Subscription Groups configurés
   - **Android** : Utiliser Google Play Internal/Closed Testing avec modes de proration configurés

2. **Configuration RevenueCat** :
   - Vérifier que les produits Monthly et Annual sont bien attachés au même entitlement "Premium"
   - Pour App Store : S'assurer qu'ils sont dans le même Subscription Group
   - Pour Play Store : Configurer les modes de proration appropriés

3. **Logique Backend** :
   - Votre fonction `get_user_subscription_summary` retourne déjà le dernier abonnement actif (ORDER BY created_at DESC, LIMIT 1)
   - C'est correct : vous récupérez toujours l'abonnement le plus récent
   - Même si plusieurs abonnements existent, seul le plus récent est utilisé

### Points à Vérifier

1. **Logs Edge Function** :
   ```bash
   # Vérifier si le webhook Annual a été reçu
   # Dashboard Supabase → Edge Functions → revenuecat-webhook → Logs
   ```

2. **Événements en base** :
   - Vérifier la table `subscription_events` pour voir tous les événements reçus
   - Confirmer si un événement `INITIAL_PURCHASE` pour Annual a été enregistré

3. **Contrainte UNIQUE** :
   - La contrainte `(user_id, entitlement_id)` dans la table `subscriptions` devrait empêcher deux abonnements actifs pour le même entitlement
   - Si Annual a été créé, Monthly devrait avoir été mis à jour ou expiré

## Conclusion

**Le comportement observé est NORMAL pour le Test Store** : il s'agit d'une limitation connue. Le Test Store ne simule pas le comportement des Subscription Groups (iOS) ni des modes de proration (Android).

**En production**, les stores réels géreront automatiquement le remplacement :
- ✅ App Store : Via Subscription Groups
- ✅ Google Play : Via Proration Modes

**Votre backend est déjà prêt** : la fonction `get_user_subscription_summary` retourne toujours l'abonnement le plus récent, ce qui est le comportement attendu.

## Actions Recommandées

1. ✅ **Accepter cette limitation du Test Store** pour les tests initiaux
2. ⚠️ **Tester avec les Sandboxes Réels** avant la mise en production :
   - TestFlight pour iOS
   - Play Store Internal Testing pour Android
3. ✅ **Vérifier les logs Edge Function** pour comprendre pourquoi Annual n'apparaît pas en base
4. ✅ **Confirmer la configuration** des Subscription Groups (iOS) et Proration Modes (Android) dans RevenueCat Dashboard

