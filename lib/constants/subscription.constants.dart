/// Constants related to subscription product and entitlement mappings.
///
/// This file contains static mappings between RevenueCat product identifiers
/// and their associated entitlement keys. This follows RevenueCat best
/// practices by keeping entitlement mapping logic client-side.
class SubscriptionConstants {
  /// Private constructor to prevent instantiation.
  const SubscriptionConstants._();

  /// Maps product identifiers to their associated entitlement keys.
  ///
  /// This map contains all products from all stores (Test Store, App Store,
  /// Play Store) and their corresponding entitlements. When adding new
  /// products or entitlements, update this map accordingly.
  static const Map<String, String> productToEntitlement = <String, String>{
    // Test Store products - Premium
    'premium_monthly_subscription': 'Premium',
    'premium_annual_subscription': 'Premium',

    // Test Store products - Basic
    'basic_monthly_subscription': 'Basic',
    'basic_annual_subscription': 'Basic',

    // App Store products
    'fr.trainer.test.Monthly': 'Premium',
    'fr.trainer.test.Annual': 'Premium',

    // Play Store products
    'premium_monthly:pm': 'Premium',
    'premium_annualy:pa': 'Premium',
  };
}
