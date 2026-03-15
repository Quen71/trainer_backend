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
    // Test Store & App Store (iOS) products - Premium
    // (App Store uses the same store identifiers as the Test Store)
    'premium_monthly_subscription': 'Premium',
    'premium_annual_subscription': 'Premium',

    // Test Store & App Store (iOS) products - Basic
    'basic_monthly_subscription': 'Basic',
    'basic_annual_subscription': 'Basic',

    // Play Store (Android) products - Premium
    'premium_monthly:pm': 'Premium',
    'premium_annual:pa': 'Premium',

    // Play Store (Android) products - Basic
    'basic_monthly:bm': 'Basic',
    'basic_annual:ba': 'Basic',
  };
}
