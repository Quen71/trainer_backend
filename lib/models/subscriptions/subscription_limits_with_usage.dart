import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/subscriptions/converters/sessions_count_map_converter.dart';
import 'package:trainer_backend/models/subscriptions/converters/subscription_status_converter.dart';
import 'package:trainer_backend/models/subscriptions/enums/subscription_status.dart';
import 'package:trainer_backend/models/subscriptions/product_summary.dart';
import 'package:trainer_backend/models/subscriptions/subscription_summary.dart';

part 'subscription_limits_with_usage.g.dart';

/// Represents subscription limits with current usage counts for a user.
///
/// This model is returned by the `get_user_limits_with_usage` RPC function
/// and contains subscription summary information plus current usage statistics.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SubscriptionLimitsWithUsage {
  /// Creates an instance of [SubscriptionLimitsWithUsage].
  const SubscriptionLimitsWithUsage({
    this.id,
    required this.userId,
    required this.status,
    this.startedAt,
    this.expiresAt,
    required this.isTrial,
    required this.entitlement,
    this.product,
    required this.limits,
    required this.usage,
  });

  /// Creates a [SubscriptionLimitsWithUsage] from a JSON object.
  factory SubscriptionLimitsWithUsage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionLimitsWithUsageFromJson(json);

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

  /// Current usage statistics for the user.
  final SubscriptionUsage usage;

  /// Converts this [SubscriptionLimitsWithUsage] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionLimitsWithUsageToJson(this);
}

/// Represents current usage statistics for a user's subscription.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SubscriptionUsage {
  /// Creates an instance of [SubscriptionUsage].
  const SubscriptionUsage({
    required this.programsCount,
    required this.sessionsCountByProgram,
  });

  /// Creates a [SubscriptionUsage] from a JSON object.
  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUsageFromJson(json);

  /// Current number of programs created by the user.
  @JsonKey(name: 'programs_count')
  final int programsCount;

  /// Map of program IDs to their session counts.
  /// Keys are program IDs as strings, values are session counts.
  /// Note: The database may return values as strings or integers, so a converter handles both cases.
  @SessionsCountMapConverter()
  @JsonKey(name: 'sessions_count_by_program')
  final Map<String, int> sessionsCountByProgram;

  /// Converts this [SubscriptionUsage] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionUsageToJson(this);
}
