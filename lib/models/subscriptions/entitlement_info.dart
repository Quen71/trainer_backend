import 'package:copy_with_extension/copy_with_extension.dart';

part 'entitlement_info.g.dart';

/// Represents entitlement information from RevenueCat.
///
/// This model contains details about a user's entitlement status,
/// including purchase dates, expiration, and renewal information.
/// It abstracts the RevenueCat EntitlementInfo type to avoid direct dependencies.
@CopyWith()
class EntitlementInfo {
  /// Creates an instance of [EntitlementInfo].
  const EntitlementInfo({
    required this.identifier,
    required this.isActive,
    required this.willRenew,
    required this.periodType,
    required this.latestPurchaseDate,
    required this.originalPurchaseDate,
    this.expirationDate,
    required this.store,
    required this.productIdentifier,
  });

  /// The unique identifier for this entitlement.
  final String identifier;

  /// Whether the entitlement is currently active.
  final bool isActive;

  /// Whether the entitlement will renew automatically.
  final bool willRenew;

  /// The period type (e.g., "NORMAL", "TRIAL", "INTRO").
  final String periodType;

  /// The date of the latest purchase.
  final DateTime latestPurchaseDate;

  /// The date of the original purchase.
  final DateTime originalPurchaseDate;

  /// The expiration date, if applicable.
  final DateTime? expirationDate;

  /// The store where the purchase was made (e.g., "APP_STORE", "PLAY_STORE").
  final String store;

  /// The product identifier associated with this entitlement.
  final String productIdentifier;
}
