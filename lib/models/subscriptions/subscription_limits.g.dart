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

  SubscriptionLimits maxExercises(int? maxExercises);

  SubscriptionLimits canExportData(bool canExportData);

  SubscriptionLimits canSharePrograms(bool canSharePrograms);

  SubscriptionLimits metadata(Map<String, dynamic> metadata);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionLimits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionLimits(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionLimits call({
    String entitlementId,
    int? maxPrograms,
    int? maxSessionsPerProgram,
    int? historyDays,
    int? maxExercises,
    bool canExportData,
    bool canSharePrograms,
    Map<String, dynamic> metadata,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubscriptionLimits.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubscriptionLimits.copyWith.fieldName(...)`
class _$SubscriptionLimitsCWProxyImpl implements _$SubscriptionLimitsCWProxy {
  const _$SubscriptionLimitsCWProxyImpl(this._value);

  final SubscriptionLimits _value;

  @override
  SubscriptionLimits entitlementId(String entitlementId) =>
      this(entitlementId: entitlementId);

  @override
  SubscriptionLimits maxPrograms(int? maxPrograms) =>
      this(maxPrograms: maxPrograms);

  @override
  SubscriptionLimits maxSessionsPerProgram(int? maxSessionsPerProgram) =>
      this(maxSessionsPerProgram: maxSessionsPerProgram);

  @override
  SubscriptionLimits historyDays(int? historyDays) =>
      this(historyDays: historyDays);

  @override
  SubscriptionLimits maxExercises(int? maxExercises) =>
      this(maxExercises: maxExercises);

  @override
  SubscriptionLimits canExportData(bool canExportData) =>
      this(canExportData: canExportData);

  @override
  SubscriptionLimits canSharePrograms(bool canSharePrograms) =>
      this(canSharePrograms: canSharePrograms);

  @override
  SubscriptionLimits metadata(Map<String, dynamic> metadata) =>
      this(metadata: metadata);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionLimits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionLimits(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionLimits call({
    Object? entitlementId = const $CopyWithPlaceholder(),
    Object? maxPrograms = const $CopyWithPlaceholder(),
    Object? maxSessionsPerProgram = const $CopyWithPlaceholder(),
    Object? historyDays = const $CopyWithPlaceholder(),
    Object? maxExercises = const $CopyWithPlaceholder(),
    Object? canExportData = const $CopyWithPlaceholder(),
    Object? canSharePrograms = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionLimits(
      entitlementId: entitlementId == const $CopyWithPlaceholder()
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
      maxExercises: maxExercises == const $CopyWithPlaceholder()
          ? _value.maxExercises
          // ignore: cast_nullable_to_non_nullable
          : maxExercises as int?,
      canExportData: canExportData == const $CopyWithPlaceholder()
          ? _value.canExportData
          // ignore: cast_nullable_to_non_nullable
          : canExportData as bool,
      canSharePrograms: canSharePrograms == const $CopyWithPlaceholder()
          ? _value.canSharePrograms
          // ignore: cast_nullable_to_non_nullable
          : canSharePrograms as bool,
      metadata: metadata == const $CopyWithPlaceholder()
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
    );
  }
}

extension $SubscriptionLimitsCopyWith on SubscriptionLimits {
  /// Returns a callable class that can be used as follows: `instanceOfSubscriptionLimits.copyWith(...)` or like so:`instanceOfSubscriptionLimits.copyWith.fieldName(...)`.
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
      maxExercises: (json['max_exercises'] as num?)?.toInt(),
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
      'max_exercises': instance.maxExercises,
      'can_export_data': instance.canExportData,
      'can_share_programs': instance.canSharePrograms,
      'metadata': instance.metadata,
    };
