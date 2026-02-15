import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/subscriptions/converters/subscription_status_converter.dart';
import 'package:trainer_backend/models/subscriptions/enums/subscription_status.dart';
import 'package:trainer_backend/models/subscriptions/product_summary.dart';

part 'subscription_summary.g.dart';

/// Represents a subscription summary with entitlement, product, and limits information.
///
/// This model is returned by the `get_user_subscription_summary` RPC function
/// and contains all relevant subscription data in a single response.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SubscriptionSummary {
  /// Creates an instance of [SubscriptionSummary].
  const SubscriptionSummary({
    this.id,
    required this.userId,
    required this.status,
    this.startedAt,
    this.expiresAt,
    required this.isTrial,
    required this.entitlement,
    this.product,
    required this.limits,
  });

  /// Creates a [SubscriptionSummary] from a JSON object.
  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) => _$SubscriptionSummaryFromJson(json);

  /// The unique identifier for the subscription.
  /// Can be null for free plan users who don't have an active subscription.
  final String? id;

  /// The ID of the user who owns this subscription.
  @JsonKey(name: 'user_id')
  final String userId;

  /// The current status of the subscription.
  @SubscriptionStatusConverter()
  final SubscriptionStatus status;

  /// The timestamp when the subscription started.
  /// Can be null for free plan users who don't have an active subscription.
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;

  /// The timestamp when the subscription expires.
  /// Can be null for lifetime subscriptions or subscriptions without expiration.
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  /// Whether this subscription is in trial period.
  @JsonKey(name: 'is_trial')
  final bool isTrial;

  /// The entitlement information associated with this subscription.
  /// Contains id, entitlement_key, and name.
  final SubscriptionSummaryEntitlement entitlement;

  /// The product information associated with this subscription.
  /// Can be null if no product is linked.
  final ProductSummary? product;

  /// The subscription limits for this entitlement.
  final SubscriptionSummaryLimits limits;

  /// Converts this [SubscriptionSummary] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionSummaryToJson(this);
}

/// Represents entitlement information within a subscription summary.
///
/// This is a simplified version of the Entitlement model used in
/// subscription summary responses.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SubscriptionSummaryEntitlement {
  /// Creates an instance of [SubscriptionSummaryEntitlement].
  const SubscriptionSummaryEntitlement({
    required this.id,
    required this.entitlementKey,
    required this.name,
  });

  /// Creates a [SubscriptionSummaryEntitlement] from a JSON object.
  factory SubscriptionSummaryEntitlement.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionSummaryEntitlementFromJson(json);

  /// The unique identifier for the entitlement.
  final String id;

  /// The unique key that identifies this entitlement (e.g., 'Premium', 'Pro').
  @JsonKey(name: 'entitlement_key')
  final String entitlementKey;

  /// The display name of the entitlement.
  final String name;

  /// Converts this [SubscriptionSummaryEntitlement] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionSummaryEntitlementToJson(this);
}

/// Represents subscription limits within a subscription summary.
///
/// This is a simplified version of the SubscriptionLimits model used in
/// subscription summary responses, without the entitlement_id field.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SubscriptionSummaryLimits {
  /// Creates an instance of [SubscriptionSummaryLimits].
  const SubscriptionSummaryLimits({
    this.maxPrograms,
    this.maxSessionsPerProgram,
    this.historyDays,
    this.maxExercisesPerSession,
    this.canExportData = false,
    this.canSharePrograms = false,
    this.metadata = const <String, dynamic>{},
  });

  /// Creates a [SubscriptionSummaryLimits] from a JSON object.
  factory SubscriptionSummaryLimits.fromJson(Map<String, dynamic> json) => _$SubscriptionSummaryLimitsFromJson(json);

  /// Maximum number of programs the user can create.
  @JsonKey(name: 'max_programs')
  final int? maxPrograms;

  /// Maximum number of sessions per program.
  @JsonKey(name: 'max_sessions_per_program')
  final int? maxSessionsPerProgram;

  /// Number of days to retain session history.
  @JsonKey(name: 'history_days')
  final int? historyDays;

  /// Maximum number of exercises per session.
  @JsonKey(name: 'max_exercises_per_session')
  final int? maxExercisesPerSession;

  /// Whether the user can export their data.
  @JsonKey(name: 'can_export_data')
  final bool canExportData;

  /// Whether the user can share programs with others.
  @JsonKey(name: 'can_share_programs')
  final bool canSharePrograms;

  /// Additional metadata stored as JSON.
  final Map<String, dynamic> metadata;

  /// Converts this [SubscriptionSummaryLimits] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionSummaryLimitsToJson(this);
}
