import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/subscriptions/converters/subscription_status_converter.dart';
import 'package:trainer_backend/models/subscriptions/entitlement.dart';
import 'package:trainer_backend/models/subscriptions/enums/subscription_status.dart';

part 'subscription.g.dart';

/// Represents a user's subscription to an entitlement.
///
/// A subscription grants a user access to specific features through an entitlement.
/// Multiple subscriptions can exist for the same user if they have different entitlements.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class Subscription {
  /// Creates an instance of [Subscription].
  const Subscription({
    required this.id,
    required this.userId,
    required this.entitlementId,
    this.productId,
    this.vendorTransactionId,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    this.isTrial = false,
    this.rawReceipt,
    this.metadata = const <String, dynamic>{},
    required this.createdAt,
    required this.updatedAt,
    this.entitlement,
  });

  /// Creates a [Subscription] from a JSON object.
  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);

  /// The unique identifier for the subscription.
  final String id;

  /// The ID of the user who owns this subscription.
  @JsonKey(name: 'user_id')
  final String userId;

  /// The ID of the entitlement this subscription grants access to.
  @JsonKey(name: 'entitlement_id')
  final String entitlementId;

  /// The ID of the product that was purchased.
  /// Can be null if the subscription was created manually or through other means.
  @JsonKey(name: 'product_id')
  final String? productId;

  /// The transaction ID from the vendor (App Store, Play Store, etc.).
  /// Used for reconciliation and idempotence.
  @JsonKey(name: 'vendor_transaction_id')
  final String? vendorTransactionId;

  /// The current status of the subscription.
  @SubscriptionStatusConverter()
  final SubscriptionStatus status;

  /// The timestamp when the subscription started.
  @JsonKey(name: 'started_at')
  final DateTime startedAt;

  /// The timestamp when the subscription expires.
  /// Can be null for lifetime subscriptions or subscriptions without expiration.
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  /// Whether this subscription is in trial period.
  @JsonKey(name: 'is_trial')
  final bool isTrial;

  /// The raw receipt data from RevenueCat.
  /// Contains the full webhook payload for debugging and reconciliation.
  @JsonKey(name: 'raw_receipt')
  final Map<String, dynamic>? rawReceipt;

  /// Additional metadata stored as JSON.
  final Map<String, dynamic> metadata;

  /// The timestamp when the subscription was created.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// The timestamp when the subscription was last updated.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// The entitlement object associated with this subscription.
  /// This field is populated when fetching subscription with related data.
  @JsonKey(includeToJson: false)
  final Entitlement? entitlement;

  /// Converts this [Subscription] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}
