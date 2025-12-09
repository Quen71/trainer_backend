# Guide Complet : Essais Gratuits avec RevenueCat

## 📋 Vue d'Ensemble

RevenueCat ne gère **pas directement** les essais gratuits. Les essais gratuits sont configurés directement dans les stores (App Store, Play Store) via les **"Introductory Offers"** (offres d'introduction). RevenueCat agit comme un **intermédiaire** qui :
1. Récupère les informations d'introductory offers depuis les stores
2. Les expose via son SDK
3. Suit automatiquement les périodes d'essai et les conversions

## ⚠️ Limitation du Test Store

**Important** : Le **Test Store de RevenueCat ne supporte PAS les offres d'introduction (introductory offers)**.

Cela signifie que :
- `storeProduct.introductoryPrice` sera toujours `null` avec le Test Store
- Les essais gratuits ne peuvent être testés qu'avec les **vrais stores** (App Store / Play Store) en mode sandbox
- L'implémentation dans le code doit prévoir un **fallback** lorsque `introductoryPrice` est `null`

## 🔧 Configuration dans les Stores

### App Store (iOS)

1. **Dans App Store Connect :**
   - Allez dans votre app → **Subscriptions**
   - Sélectionnez ou créez un groupe d'abonnements
   - Pour chaque produit d'abonnement, allez dans **Subscription Pricing**
   - Cliquez sur **Add Introductory Offer**
   - Sélectionnez **Free Trial**
   - Définissez la durée (ex: 14 jours)
   - Configurez l'éligibilité :
     - **All Users** : Tous les utilisateurs éligibles
     - **New Subscribers Only** : Seulement les nouveaux abonnés
     - **Existing Subscribers** : Utilisateurs ayant déjà souscrit

2. **Types d'offres d'introduction disponibles :**
   - **Free Trial** : Essai gratuit (0€ pendant X jours)
   - **Pay as You Go** : Prix réduit pendant X périodes
   - **Pay Up Front** : Prix réduit pour une période complète

### Play Store (Android)

1. **Dans Google Play Console :**
   - Allez dans **Monétisation** → **Abonnements**
   - Sélectionnez votre produit d'abonnement
   - Allez dans **Offres d'essai et tarifs promotionnels**
   - Cliquez sur **Créer une offre**
   - Sélectionnez **Essai gratuit**
   - Définissez la durée (ex: 14 jours)
   - Configurez l'éligibilité

2. **Note importante :**
   - Les offres d'essai gratuit sur Android sont gérées via les **Base Plans** dans Google Play Billing Library 5+
   - Pour les anciennes versions, utilisez les **Subscription Offers**

## 📱 Récupération des Informations via RevenueCat SDK

### Informations Disponibles dans le SDK

Le SDK RevenueCat Flutter expose les informations d'introductory offers via la propriété `introductoryPrice` du `StoreProduct` :

```dart
// RevenueCat SDK (rc.StoreProduct)
rc.StoreProduct storeProduct = package.storeProduct;

// Informations d'introductory offer disponibles :
storeProduct.introductoryPrice?.price          // Prix (0.0 pour free trial)
storeProduct.introductoryPrice?.priceString    // String formaté ("Free" ou "0,00 €")
storeProduct.introductoryPrice?.period         // Période (ex: "P14D" pour 14 jours)
storeProduct.introductoryPrice?.cycles         // Nombre de cycles
storeProduct.introductoryPrice?.periodUnit     // Enum PeriodUnit (day, week, month, year, unknown)
storeProduct.introductoryPrice?.periodNumberOfUnits  // Nombre d'unités
```

### Structure de IntroductoryPrice

```dart
// Structure RevenueCat Flutter SDK (purchases_flutter ^9.9.1)
import 'package:purchases_flutter/models/period_unit.dart';

class IntroductoryPrice {
  final double price;                    // 0.0 pour free trial
  final String priceString;             // "Free" ou "0,00 €"
  final String period;                   // "P14D" (ISO 8601 duration)
  final int cycles;                      // Nombre de cycles (généralement 1)
  final PeriodUnit periodUnit;           // Enum: day, week, month, year, unknown
  final int periodNumberOfUnits;         // 14 pour 14 jours
}

// PeriodUnit est un enum, pas une String
enum PeriodUnit { day, week, month, year, unknown }
```

## 🔄 État Actuel du Code

### Problème Identifié

Dans `subscription_card.widget.dart`, le texte est **hardcodé** :
```dart
label: '14 jours d\'essai gratuit',
```

Cela pose plusieurs problèmes :
1. ❌ Le texte ne s'adapte pas si l'offre change
2. ❌ Ne fonctionne pas si certains packages n'ont pas d'essai gratuit
3. ❌ Ne s'adapte pas à la durée réelle de l'essai
4. ❌ Ne gère pas les cas où il n'y a pas d'essai gratuit

### Modèle Actuel

Le modèle `StoreProduct` dans le backend **ne contient pas** les informations d'introductory price :

```dart
// train_backend/lib/models/subscriptions/store_product.dart
class StoreProduct {
  final String identifier;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;
  // ❌ Manque : introductoryPrice
}
```

## ✅ Solution Recommandée

### 1. Étendre le Modèle StoreProduct

Ajouter les informations d'introductory price au modèle backend :

```dart
// train_backend/lib/models/subscriptions/store_product.dart
class StoreProduct {
  // ... champs existants ...
  
  /// Information about the introductory offer (free trial or discounted price).
  /// 
  /// This field is null if no introductory offer is available for this product.
  final IntroductoryPrice? introductoryPrice;
}

/// Represents an introductory offer (free trial or discounted price).
class IntroductoryPrice {
  /// The price of the introductory offer (0.0 for free trials).
  final double price;
  
  /// The formatted price string (e.g., "Free", "0,00 €").
  final String priceString;
  
  /// The period of the introductory offer in ISO 8601 format (e.g., "P14D").
  final String period;
  
  /// The number of cycles for this introductory offer.
  final int cycles;
  
  /// The period unit (day, week, month, year, unknown).
  final PeriodUnit periodUnit;
  
  /// The number of period units (e.g., 14 for 14 days).
  final int periodNumberOfUnits;
}

/// Period unit enum matching RevenueCat SDK.
enum PeriodUnit { day, week, month, year, unknown }
```

### 2. Mettre à Jour le Service de Conversion

Modifier `SubscriptionsService._convertStoreProduct` pour inclure l'introductory price :

```dart
static StoreProduct _convertStoreProduct(rc.StoreProduct rcStoreProduct) {
  IntroductoryPrice? introductoryPrice;
  
  if (rcStoreProduct.introductoryPrice != null) {
    final rc.IntroductoryPrice rcIntro = rcStoreProduct.introductoryPrice!;
    introductoryPrice = IntroductoryPrice(
      price: rcIntro.price,
      priceString: rcIntro.priceString,
      period: rcIntro.period,
      cycles: rcIntro.cycles,
      periodUnit: _convertPeriodUnit(rcIntro.periodUnit),
      periodNumberOfUnits: rcIntro.periodNumberOfUnits,
    );
  }
  
  return StoreProduct(
    identifier: rcStoreProduct.identifier,
    title: rcStoreProduct.title,
    description: rcStoreProduct.description,
    price: rcStoreProduct.price,
    priceString: rcStoreProduct.priceString,
    currencyCode: rcStoreProduct.currencyCode,
    introductoryPrice: introductoryPrice, // ✅ Ajouté
  );
}

/// Converts RevenueCat PeriodUnit to backend PeriodUnit.
static PeriodUnit _convertPeriodUnit(rc.PeriodUnit rcPeriodUnit) {
  switch (rcPeriodUnit) {
    case rc.PeriodUnit.day:
      return PeriodUnit.day;
    case rc.PeriodUnit.week:
      return PeriodUnit.week;
    case rc.PeriodUnit.month:
      return PeriodUnit.month;
    case rc.PeriodUnit.year:
      return PeriodUnit.year;
    default:
      return PeriodUnit.unknown;
  }
}
```

### 3. Créer une Extension pour le Formatage

Créer une extension pour formater le texte d'essai gratuit :

```dart
// trainer/lib/core/extensions/introductory_price.extension.dart
extension IntroductoryPriceExtension on IntroductoryPriceEntity? {
  /// Returns a formatted free trial label (e.g., "14 jours d'essai gratuit").
  /// 
  /// Returns null if no introductory offer is available or if it's not a free trial.
  String? get freeTrialLabel {
    if (this == null || price > 0) return null;
    
    // Convert period to days
    final int days = _periodToDays(period);
    if (days <= 0) return null;
    
    return '$days ${days == 1 ? 'jour' : 'jours'} d\'essai gratuit';
  }
  
  int _periodToDays(String period) {
    // Parse ISO 8601 duration (e.g., "P14D" = 14 days)
    final RegExp regex = RegExp(r'P(?:(\d+)D)?');
    final Match? match = regex.firstMatch(period);
    if (match == null) return 0;
    
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  }
}
```

### 4. Mettre à Jour le Widget

Modifier `subscription_card.widget.dart` pour utiliser les informations dynamiques :

```dart
// Dans _SubscriptionCardState.build()
CustomButton.textExtended(
  context: context,
  label: _selectedPackage.storeProduct.introductoryPrice?.freeTrialLabel 
      ?? 'S\'abonner', // Fallback si pas d'essai gratuit
  onPress: widget.onPurchaseSubscriptionPressed != null
      ? () => widget.onPurchaseSubscriptionPressed?.call(_selectedPackage)
      : null,
),
```

## 🧪 Tests

### Vérifier la Configuration

1. **Dans RevenueCat Dashboard :**
   - Allez dans **Products** → Sélectionnez un produit
   - Vérifiez que les informations d'introductory offer sont synchronisées depuis le store

2. **Dans l'Application :**
   - Appelez `SubscriptionsService.getOfferings()`
   - Vérifiez que `storeProduct.introductoryPrice` n'est pas null
   - Vérifiez que les valeurs sont correctes (price = 0.0, period = "P14D")

### Tester avec Sandbox

1. **App Store Sandbox :**
   - Créez un compte de test dans App Store Connect
   - Connectez-vous avec ce compte sur un appareil iOS
   - Testez l'achat d'un abonnement
   - Vérifiez que l'essai gratuit est appliqué

2. **Play Store Sandbox :**
   - Ajoutez des comptes de test dans Google Play Console
   - Testez l'achat sur un appareil Android
   - Vérifiez que l'essai gratuit est appliqué

## 📊 Suivi des Essais Gratuits

### Dans RevenueCat Dashboard

RevenueCat suit automatiquement :
- ✅ Le nombre d'utilisateurs en essai gratuit
- ✅ Les conversions d'essai vers abonnement payant
- ✅ Les taux de conversion
- ✅ Les annulations pendant l'essai

### Dans Supabase

Le statut `trialing` est automatiquement géré via les webhooks :
- Lorsqu'un utilisateur commence un essai gratuit, le statut est `trialing`
- Le champ `is_trial` est mis à `true`
- À la fin de l'essai, si l'utilisateur continue, le statut passe à `active`

## ⚠️ Points d'Attention

1. **Éligibilité :**
   - Les stores gèrent l'éligibilité aux offres d'introduction
   - Un utilisateur qui a déjà utilisé un essai gratuit peut ne pas être éligible
   - RevenueCat ne peut pas forcer une offre d'introduction si l'utilisateur n'est pas éligible

2. **Synchronisation :**
   - Les changements dans les stores peuvent prendre quelques heures à se synchroniser
   - Vérifiez toujours dans RevenueCat Dashboard que les produits sont à jour

3. **Test Store :**
   - Le Test Store de RevenueCat **ne supporte PAS** les offres d'introduction
   - `introductoryPrice` sera toujours `null` avec le Test Store
   - Pour tester les essais gratuits, vous **devez** utiliser les stores natifs (App Store/Play Store) en sandbox

4. **Durée d'Essai :**
   - La durée maximale varie selon les stores :
     - **App Store** : Jusqu'à 1 an
     - **Play Store** : Jusqu'à 1 an
   - Les durées courantes sont : 3, 7, 14, 30 jours

## 📚 Ressources

- [RevenueCat Documentation - Introductory Offers](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers)
- [App Store Connect - Subscription Offers](https://developer.apple.com/documentation/storekit/in-app_purchase/orchestrating_subscription_offers)
- [Google Play Billing - Free Trials](https://developer.android.com/google/play/billing/subscriptions#free-trial)

