import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_limits.g.dart';

/// Represents the feature limits associated with an entitlement.
///
/// Each entitlement can have different limits for various features,
/// such as maximum number of programs, history retention, etc.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SubscriptionLimits {
  /// Creates an instance of [SubscriptionLimits].
  const SubscriptionLimits({
    required this.entitlementId,
    this.maxPrograms,
    this.maxSessionsPerProgram,
    this.historyDays,
    this.maxExercisesPerSession,
    this.canExportData = false,
    this.canSharePrograms = false,
    this.metadata = const <String, dynamic>{},
  });

  /// Creates a [SubscriptionLimits] from a JSON object.
  factory SubscriptionLimits.fromJson(Map<String, dynamic> json) => _$SubscriptionLimitsFromJson(json);

  /// The ID of the entitlement these limits apply to.
  @JsonKey(name: 'entitlement_id')
  final String entitlementId;

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

  /// Converts this [SubscriptionLimits] to a JSON object.
  Map<String, dynamic> toJson() => _$SubscriptionLimitsToJson(this);
}
