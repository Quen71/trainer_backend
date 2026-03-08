import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:trainer_backend/models/subscriptions/entitlement_info.dart';

part 'customer_info.g.dart';

/// Represents customer information from RevenueCat.
///
/// This model contains all information about a customer's purchases,
/// entitlements, and subscription status.
/// It abstracts the RevenueCat CustomerInfo type to avoid direct dependencies.
@CopyWith()
class CustomerInfo {
  /// Creates an instance of [CustomerInfo].
  const CustomerInfo({
    required this.entitlements,
    required this.activeSubscriptions,
    required this.allPurchasedProductIdentifiers,
    required this.firstSeen,
    required this.requestDate,
    required this.originalAppUserId,
    this.managementURL,
  });

  /// Map of active entitlements, keyed by entitlement identifier.
  final Map<String, EntitlementInfo> entitlements;

  /// List of active subscription identifiers.
  final List<String> activeSubscriptions;

  /// List of all purchased product identifiers (active and inactive).
  final List<String> allPurchasedProductIdentifiers;

  /// The date when the customer was first seen.
  final DateTime firstSeen;

  /// The date of this request.
  final DateTime requestDate;

  /// The original app user ID.
  final String originalAppUserId;

  /// The URL to manage the customer's subscriptions.
  ///
  /// This URL can be used to redirect users to their platform's
  /// subscription management page (App Store or Play Store).
  /// May be null if not available.
  final String? managementURL;
}
