import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// Utility class for RevenueCat SDK operations.
///
/// This class provides static utility methods for common RevenueCat
/// operations that don't involve model conversion.
class RevenueCatUtils {
  /// Private constructor to prevent instantiation.
  const RevenueCatUtils._();

  /// Finds a RevenueCat Package by product identifier in the offerings.
  ///
  /// This method searches for a package by its `storeProduct.identifier`
  /// (the unique product ID like "basic_monthly_subscription") instead of
  /// the package identifier (like "$rc_monthly").
  ///
  /// This is important because package identifiers are shared across offerings
  /// (e.g., both "Premium" and "Basic" offerings can have a "$rc_monthly" package),
  /// while product identifiers are unique per product.
  ///
  /// - [rcOfferings]: The RevenueCat offerings to search in.
  /// - [productId]: The unique product identifier to find.
  ///
  /// Returns the matching [rc.Package] or null if not found.
  static rc.Package? findPackageByProductId(
    rc.Offerings rcOfferings,
    String productId,
  ) {
    for (final rc.Offering offering in rcOfferings.all.values) {
      for (final rc.Package package in offering.availablePackages) {
        if (package.storeProduct.identifier == productId) {
          return package;
        }
      }
    }
    return null;
  }
}
