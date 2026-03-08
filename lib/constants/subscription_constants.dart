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
    // Test Store products
    'premium_monthly_subscription': 'Premium',
    'premium_annual_subscription': 'Premium',

    // App Store products
    'fr.trainer.test.Monthly': 'Premium',
    'fr.trainer.test.Annual': 'Premium',

    // Play Store products
    'premium_monthly:pm': 'Premium',
    'premium_annualy:pa': 'Premium',
  };

  /// Returns the entitlement key associated with a product identifier.
  ///
  /// - [productId]: The product identifier from RevenueCat (e.g.,
  ///   `premium_monthly_subscription`, `fr.trainer.test.Monthly`).
  ///
  /// Returns the entitlement key (e.g., `'Premium'`) if the product is
  /// found in the configuration, or `null` if the product is not mapped.
  ///
  /// Example:
  /// ```dart
  /// final String? entitlement = SubscriptionConstants.getEntitlementForProduct(
  ///   'premium_monthly_subscription',
  /// );
  /// // Returns: 'Premium'
  /// ```
  static String? getEntitlementForProduct(String productId) => productToEntitlement[productId];
}
