// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubscriptionSummaryCWProxy {
  SubscriptionSummary id(String id);

  SubscriptionSummary userId(String userId);

  SubscriptionSummary status(SubscriptionStatus status);

  SubscriptionSummary startedAt(DateTime startedAt);

  SubscriptionSummary expiresAt(DateTime? expiresAt);

  SubscriptionSummary isTrial(bool isTrial);

  SubscriptionSummary entitlement(SubscriptionSummaryEntitlement entitlement);

  SubscriptionSummary product(ProductSummary? product);

  SubscriptionSummary limits(SubscriptionSummaryLimits limits);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionSummary call({
    String id,
    String userId,
    SubscriptionStatus status,
    DateTime startedAt,
    DateTime? expiresAt,
    bool isTrial,
    SubscriptionSummaryEntitlement entitlement,
    ProductSummary? product,
    SubscriptionSummaryLimits limits,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubscriptionSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubscriptionSummary.copyWith.fieldName(...)`
class _$SubscriptionSummaryCWProxyImpl implements _$SubscriptionSummaryCWProxy {
  const _$SubscriptionSummaryCWProxyImpl(this._value);

  final SubscriptionSummary _value;

  @override
  SubscriptionSummary id(String id) => this(id: id);

  @override
  SubscriptionSummary userId(String userId) => this(userId: userId);

  @override
  SubscriptionSummary status(SubscriptionStatus status) => this(status: status);

  @override
  SubscriptionSummary startedAt(DateTime startedAt) =>
      this(startedAt: startedAt);

  @override
  SubscriptionSummary expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  SubscriptionSummary isTrial(bool isTrial) => this(isTrial: isTrial);

  @override
  SubscriptionSummary entitlement(SubscriptionSummaryEntitlement entitlement) =>
      this(entitlement: entitlement);

  @override
  SubscriptionSummary product(ProductSummary? product) =>
      this(product: product);

  @override
  SubscriptionSummary limits(SubscriptionSummaryLimits limits) =>
      this(limits: limits);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? isTrial = const $CopyWithPlaceholder(),
    Object? entitlement = const $CopyWithPlaceholder(),
    Object? product = const $CopyWithPlaceholder(),
    Object? limits = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionSummary(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as SubscriptionStatus,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      isTrial: isTrial == const $CopyWithPlaceholder()
          ? _value.isTrial
          // ignore: cast_nullable_to_non_nullable
          : isTrial as bool,
      entitlement: entitlement == const $CopyWithPlaceholder()
          ? _value.entitlement
          // ignore: cast_nullable_to_non_nullable
          : entitlement as SubscriptionSummaryEntitlement,
      product: product == const $CopyWithPlaceholder()
          ? _value.product
          // ignore: cast_nullable_to_non_nullable
          : product as ProductSummary?,
      limits: limits == const $CopyWithPlaceholder()
          ? _value.limits
          // ignore: cast_nullable_to_non_nullable
          : limits as SubscriptionSummaryLimits,
    );
  }
}

extension $SubscriptionSummaryCopyWith on SubscriptionSummary {
  /// Returns a callable class that can be used as follows: `instanceOfSubscriptionSummary.copyWith(...)` or like so:`instanceOfSubscriptionSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionSummaryCWProxy get copyWith =>
      _$SubscriptionSummaryCWProxyImpl(this);
}

abstract class _$SubscriptionSummaryEntitlementCWProxy {
  SubscriptionSummaryEntitlement id(String id);

  SubscriptionSummaryEntitlement entitlementKey(String entitlementKey);

  SubscriptionSummaryEntitlement name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionSummaryEntitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionSummaryEntitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionSummaryEntitlement call({
    String id,
    String entitlementKey,
    String name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubscriptionSummaryEntitlement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubscriptionSummaryEntitlement.copyWith.fieldName(...)`
class _$SubscriptionSummaryEntitlementCWProxyImpl
    implements _$SubscriptionSummaryEntitlementCWProxy {
  const _$SubscriptionSummaryEntitlementCWProxyImpl(this._value);

  final SubscriptionSummaryEntitlement _value;

  @override
  SubscriptionSummaryEntitlement id(String id) => this(id: id);

  @override
  SubscriptionSummaryEntitlement entitlementKey(String entitlementKey) =>
      this(entitlementKey: entitlementKey);

  @override
  SubscriptionSummaryEntitlement name(String name) => this(name: name);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionSummaryEntitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionSummaryEntitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionSummaryEntitlement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? entitlementKey = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionSummaryEntitlement(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      entitlementKey: entitlementKey == const $CopyWithPlaceholder()
          ? _value.entitlementKey
          // ignore: cast_nullable_to_non_nullable
          : entitlementKey as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $SubscriptionSummaryEntitlementCopyWith
    on SubscriptionSummaryEntitlement {
  /// Returns a callable class that can be used as follows: `instanceOfSubscriptionSummaryEntitlement.copyWith(...)` or like so:`instanceOfSubscriptionSummaryEntitlement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionSummaryEntitlementCWProxy get copyWith =>
      _$SubscriptionSummaryEntitlementCWProxyImpl(this);
}

abstract class _$SubscriptionSummaryLimitsCWProxy {
  SubscriptionSummaryLimits maxPrograms(int? maxPrograms);

  SubscriptionSummaryLimits maxSessionsPerProgram(int? maxSessionsPerProgram);

  SubscriptionSummaryLimits historyDays(int? historyDays);

  SubscriptionSummaryLimits maxExercises(int? maxExercises);

  SubscriptionSummaryLimits canExportData(bool canExportData);

  SubscriptionSummaryLimits canSharePrograms(bool canSharePrograms);

  SubscriptionSummaryLimits metadata(Map<String, dynamic> metadata);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionSummaryLimits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionSummaryLimits(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionSummaryLimits call({
    int? maxPrograms,
    int? maxSessionsPerProgram,
    int? historyDays,
    int? maxExercises,
    bool canExportData,
    bool canSharePrograms,
    Map<String, dynamic> metadata,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubscriptionSummaryLimits.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubscriptionSummaryLimits.copyWith.fieldName(...)`
class _$SubscriptionSummaryLimitsCWProxyImpl
    implements _$SubscriptionSummaryLimitsCWProxy {
  const _$SubscriptionSummaryLimitsCWProxyImpl(this._value);

  final SubscriptionSummaryLimits _value;

  @override
  SubscriptionSummaryLimits maxPrograms(int? maxPrograms) =>
      this(maxPrograms: maxPrograms);

  @override
  SubscriptionSummaryLimits maxSessionsPerProgram(int? maxSessionsPerProgram) =>
      this(maxSessionsPerProgram: maxSessionsPerProgram);

  @override
  SubscriptionSummaryLimits historyDays(int? historyDays) =>
      this(historyDays: historyDays);

  @override
  SubscriptionSummaryLimits maxExercises(int? maxExercises) =>
      this(maxExercises: maxExercises);

  @override
  SubscriptionSummaryLimits canExportData(bool canExportData) =>
      this(canExportData: canExportData);

  @override
  SubscriptionSummaryLimits canSharePrograms(bool canSharePrograms) =>
      this(canSharePrograms: canSharePrograms);

  @override
  SubscriptionSummaryLimits metadata(Map<String, dynamic> metadata) =>
      this(metadata: metadata);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionSummaryLimits(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionSummaryLimits(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionSummaryLimits call({
    Object? maxPrograms = const $CopyWithPlaceholder(),
    Object? maxSessionsPerProgram = const $CopyWithPlaceholder(),
    Object? historyDays = const $CopyWithPlaceholder(),
    Object? maxExercises = const $CopyWithPlaceholder(),
    Object? canExportData = const $CopyWithPlaceholder(),
    Object? canSharePrograms = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionSummaryLimits(
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

extension $SubscriptionSummaryLimitsCopyWith on SubscriptionSummaryLimits {
  /// Returns a callable class that can be used as follows: `instanceOfSubscriptionSummaryLimits.copyWith(...)` or like so:`instanceOfSubscriptionSummaryLimits.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionSummaryLimitsCWProxy get copyWith =>
      _$SubscriptionSummaryLimitsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionSummary _$SubscriptionSummaryFromJson(Map<String, dynamic> json) =>
    SubscriptionSummary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: const SubscriptionStatusConverter()
          .fromJson(json['status'] as String),
      startedAt: DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      isTrial: json['is_trial'] as bool,
      entitlement: SubscriptionSummaryEntitlement.fromJson(
          json['entitlement'] as Map<String, dynamic>),
      product: json['product'] == null
          ? null
          : ProductSummary.fromJson(json['product'] as Map<String, dynamic>),
      limits: SubscriptionSummaryLimits.fromJson(
          json['limits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionSummaryToJson(
        SubscriptionSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'status': const SubscriptionStatusConverter().toJson(instance.status),
      'started_at': instance.startedAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_trial': instance.isTrial,
      'entitlement': instance.entitlement,
      'product': instance.product,
      'limits': instance.limits,
    };

SubscriptionSummaryEntitlement _$SubscriptionSummaryEntitlementFromJson(
        Map<String, dynamic> json) =>
    SubscriptionSummaryEntitlement(
      id: json['id'] as String,
      entitlementKey: json['entitlement_key'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SubscriptionSummaryEntitlementToJson(
        SubscriptionSummaryEntitlement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entitlement_key': instance.entitlementKey,
      'name': instance.name,
    };

SubscriptionSummaryLimits _$SubscriptionSummaryLimitsFromJson(
        Map<String, dynamic> json) =>
    SubscriptionSummaryLimits(
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

Map<String, dynamic> _$SubscriptionSummaryLimitsToJson(
        SubscriptionSummaryLimits instance) =>
    <String, dynamic>{
      'max_programs': instance.maxPrograms,
      'max_sessions_per_program': instance.maxSessionsPerProgram,
      'history_days': instance.historyDays,
      'max_exercises': instance.maxExercises,
      'can_export_data': instance.canExportData,
      'can_share_programs': instance.canSharePrograms,
      'metadata': instance.metadata,
    };
