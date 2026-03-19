// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_limits.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubscriptionLimitsCWProxy {
  SubscriptionLimits entitlementId(String entitlementId);

  SubscriptionLimits maxPrograms(int? maxPrograms);

  SubscriptionLimits maxSessionsPerProgram(int? maxSessionsPerProgram);

  SubscriptionLimits historyDays(int? historyDays);

  SubscriptionLimits maxExercisesPerSession(int? maxExercisesPerSession);

  SubscriptionLimits canExportData(bool canExportData);

  SubscriptionLimits canSharePrograms(bool canSharePrograms);

  SubscriptionLimits metadata(Map<String, dynamic> metadata);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionLimits(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionLimits(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionLimits call({
    String entitlementId,
    int? maxPrograms,
    int? maxSessionsPerProgram,
    int? historyDays,
    int? maxExercisesPerSession,
    bool canExportData,
    bool canSharePrograms,
    Map<String, dynamic> metadata,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSubscriptionLimits.copyWith(...)` or call `instanceOfSubscriptionLimits.copyWith.fieldName(value)` for a single field.
class _$SubscriptionLimitsCWProxyImpl implements _$SubscriptionLimitsCWProxy {
  const _$SubscriptionLimitsCWProxyImpl(this._value);

  final SubscriptionLimits _value;

  @override
  SubscriptionLimits entitlementId(String entitlementId) =>
      call(entitlementId: entitlementId);

  @override
  SubscriptionLimits maxPrograms(int? maxPrograms) =>
      call(maxPrograms: maxPrograms);

  @override
  SubscriptionLimits maxSessionsPerProgram(int? maxSessionsPerProgram) =>
      call(maxSessionsPerProgram: maxSessionsPerProgram);

  @override
  SubscriptionLimits historyDays(int? historyDays) =>
      call(historyDays: historyDays);

  @override
  SubscriptionLimits maxExercisesPerSession(int? maxExercisesPerSession) =>
      call(maxExercisesPerSession: maxExercisesPerSession);

  @override
  SubscriptionLimits canExportData(bool canExportData) =>
      call(canExportData: canExportData);

  @override
  SubscriptionLimits canSharePrograms(bool canSharePrograms) =>
      call(canSharePrograms: canSharePrograms);

  @override
  SubscriptionLimits metadata(Map<String, dynamic> metadata) =>
      call(metadata: metadata);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionLimits(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionLimits(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionLimits call({
    Object? entitlementId = const $CopyWithPlaceholder(),
    Object? maxPrograms = const $CopyWithPlaceholder(),
    Object? maxSessionsPerProgram = const $CopyWithPlaceholder(),
    Object? historyDays = const $CopyWithPlaceholder(),
    Object? maxExercisesPerSession = const $CopyWithPlaceholder(),
    Object? canExportData = const $CopyWithPlaceholder(),
    Object? canSharePrograms = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionLimits(
      entitlementId:
          entitlementId == const $CopyWithPlaceholder() || entitlementId == null
              ? _value.entitlementId
              // ignore: cast_nullable_to_non_nullable
              : entitlementId as String,
      maxPrograms: maxPrograms == const $CopyWithPlaceholder()
          ? _value.maxPrograms
          // ignore: cast_nullable_to_non_nullable
          : maxPrograms as int?,
      maxSessionsPerProgram:
          maxSessionsPerProgram == const $CopyWithPlaceholder()
              ? _value.maxSessionsPerProgram
              // ignore: cast_nullable_to_non_nullable
              : maxSessionsPerProgram as int?,
      historyDays: historyDays == const $CopyWithPlaceholder()
          ? _value.historyDays
          // ignore: cast_nullable_to_non_nullable
          : historyDays as int?,
      maxExercisesPerSession:
          maxExercisesPerSession == const $CopyWithPlaceholder()
              ? _value.maxExercisesPerSession
              // ignore: cast_nullable_to_non_nullable
              : maxExercisesPerSession as int?,
      canExportData:
          canExportData == const $CopyWithPlaceholder() || canExportData == null
              ? _value.canExportData
              // ignore: cast_nullable_to_non_nullable
              : canExportData as bool,
      canSharePrograms: canSharePrograms == const $CopyWithPlaceholder() ||
              canSharePrograms == null
          ? _value.canSharePrograms
          // ignore: cast_nullable_to_non_nullable
          : canSharePrograms as bool,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
    );
  }
}

extension $SubscriptionLimitsCopyWith on SubscriptionLimits {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSubscriptionLimits.copyWith(...)` or `instanceOfSubscriptionLimits.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionLimitsCWProxy get copyWith =>
      _$SubscriptionLimitsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionLimits _$SubscriptionLimitsFromJson(Map<String, dynamic> json) =>
    SubscriptionLimits(
      entitlementId: json['entitlement_id'] as String,
      maxPrograms: (json['max_programs'] as num?)?.toInt(),
      maxSessionsPerProgram:
          (json['max_sessions_per_program'] as num?)?.toInt(),
      historyDays: (json['history_days'] as num?)?.toInt(),
      maxExercisesPerSession:
          (json['max_exercises_per_session'] as num?)?.toInt(),
      canExportData: json['can_export_data'] as bool? ?? false,
      canSharePrograms: json['can_share_programs'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$SubscriptionLimitsToJson(SubscriptionLimits instance) =>
    <String, dynamic>{
      'entitlement_id': instance.entitlementId,
      'max_programs': instance.maxPrograms,
      'max_sessions_per_program': instance.maxSessionsPerProgram,
      'history_days': instance.historyDays,
      'max_exercises_per_session': instance.maxExercisesPerSession,
      'can_export_data': instance.canExportData,
      'can_share_programs': instance.canSharePrograms,
      'metadata': instance.metadata,
    };
