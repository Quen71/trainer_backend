import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/subscriptions/subscription_summary.dart';

part 'feature_access.g.dart';

/// Represents the result of checking feature access for a user.
///
/// This model is returned by the `check_feature_access` RPC function
/// and indicates whether the user has access to a specific feature
/// along with any associated limits.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class FeatureAccess {
  /// Creates an instance of [FeatureAccess].
  const FeatureAccess({
    required this.hasAccess,
    required this.featureKey,
    this.limits,
  });

  /// Creates a [FeatureAccess] from a JSON object.
  factory FeatureAccess.fromJson(Map<String, dynamic> json) => _$FeatureAccessFromJson(json);

  /// Whether the user has access to the requested feature.
  @JsonKey(name: 'has_access')
  final bool hasAccess;

  /// The feature key that was checked.
  @JsonKey(name: 'feature_key')
  final String featureKey;

  /// The subscription limits if access is granted.
  /// Can be null if access is denied or if limits are not available.
  final SubscriptionSummaryLimits? limits;

  /// Converts this [FeatureAccess] to a JSON object.
  Map<String, dynamic> toJson() => _$FeatureAccessToJson(this);
}
