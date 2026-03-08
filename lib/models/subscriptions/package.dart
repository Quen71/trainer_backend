import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:trainer_backend/models/subscriptions/enums/package_type.dart';
import 'package:trainer_backend/models/subscriptions/store_product.dart';

part 'package.g.dart';

/// Represents a subscription package within an offering.
///
/// A package contains a product and package type information.
/// It abstracts the RevenueCat Package type to avoid direct dependencies.
@CopyWith()
class Package {
  /// Creates an instance of [Package].
  const Package({
    required this.identifier,
    required this.packageType,
    required this.storeProduct,
    this.entitlementIdentifier,
  });

  /// The unique identifier for this package.
  final String identifier;

  /// The type/period of this package (e.g., monthly, annual).
  final PackageType packageType;

  /// The store product associated with this package.
  final StoreProduct storeProduct;

  /// The entitlement identifier (e.g., "Premium") associated with this package's product.
  final String? entitlementIdentifier;
}
