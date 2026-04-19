// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubscriptionSummaryCWProxy {
  SubscriptionSummary id(String? id);

  SubscriptionSummary userId(String userId);

  SubscriptionSummary status(SubscriptionStatus status);

  SubscriptionSummary startedAt(DateTime? startedAt);

  SubscriptionSummary expiresAt(DateTime? expiresAt);

  SubscriptionSummary isTrial(bool isTrial);

  SubscriptionSummary entitlement(SubscriptionSummaryEntitlement entitlement);

  SubscriptionSummary product(ProductSummary? product);

  SubscriptionSummary limits(SubscriptionSummaryLimits limits);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionSummary(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionSummary(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionSummary call({
    String? id,
    String userId,
    SubscriptionStatus status,
    DateTime? startedAt,
    DateTime? expiresAt,
    bool isTrial,
    SubscriptionSummaryEntitlement entitlement,
    ProductSummary? product,
    SubscriptionSummaryLimits limits,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSubscriptionSummary.copyWith(...)` or call `instanceOfSubscriptionSummary.copyWith.fieldName(value)` for a single field.
class _$SubscriptionSummaryCWProxyImpl implements _$SubscriptionSummaryCWProxy {
  const _$SubscriptionSummaryCWProxyImpl(this._value);

  final SubscriptionSummary _value;

  @override
  SubscriptionSummary id(String? id) => call(id: id);

  @override
  SubscriptionSummary userId(String userId) => call(userId: userId);

  @override
  SubscriptionSummary status(SubscriptionStatus status) => call(status: status);

  @override
  SubscriptionSummary startedAt(DateTime? startedAt) =>
      call(startedAt: startedAt);

  @override
  SubscriptionSummary expiresAt(DateTime? expiresAt) =>
      call(expiresAt: expiresAt);

  @override
  SubscriptionSummary isTrial(bool isTrial) => call(isTrial: isTrial);

  @override
  SubscriptionSummary entitlement(SubscriptionSummaryEntitlement entitlement) =>
      call(entitlement: entitlement);

  @override
  SubscriptionSummary product(ProductSummary? product) =>
      call(product: product);

  @override
  SubscriptionSummary limits(SubscriptionSummaryLimits limits) =>
      call(limits: limits);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionSummary(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionSummary(...).copyWith(id: 12, name: "My name")
  /// ```
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
          : id as String?,
      userId: userId == const $CopyWithPlaceholder() || userId == null
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as SubscriptionStatus,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      isTrial: isTrial == const $CopyWithPlaceholder() || isTrial == null
          ? _value.isTrial
          // ignore: cast_nullable_to_non_nullable
          : isTrial as bool,
      entitlement:
          entitlement == const $CopyWithPlaceholder() || entitlement == null
          ? _value.entitlement
          // ignore: cast_nullable_to_non_nullable
          : entitlement as SubscriptionSummaryEntitlement,
      product: product == const $CopyWithPlaceholder()
          ? _value.product
          // ignore: cast_nullable_to_non_nullable
          : product as ProductSummary?,
      limits: limits == const $CopyWithPlaceholder() || limits == null
          ? _value.limits
          // ignore: cast_nullable_to_non_nullable
          : limits as SubscriptionSummaryLimits,
    );
  }
}

extension $SubscriptionSummaryCopyWith on SubscriptionSummary {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSubscriptionSummary.copyWith(...)` or `instanceOfSubscriptionSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionSummaryCWProxy get copyWith =>
      _$SubscriptionSummaryCWProxyImpl(this);
}

abstract class _$SubscriptionSummaryEntitlementCWProxy {
  SubscriptionSummaryEntitlement id(String id);

  SubscriptionSummaryEntitlement entitlementKey(String entitlementKey);

  SubscriptionSummaryEntitlement name(String name);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionSummaryEntitlement(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionSummaryEntitlement(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionSummaryEntitlement call({
    String id,
    String entitlementKey,
    String name,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSubscriptionSummaryEntitlement.copyWith(...)` or call `instanceOfSubscriptionSummaryEntitlement.copyWith.fieldName(value)` for a single field.
class _$SubscriptionSummaryEntitlementCWProxyImpl
    implements _$SubscriptionSummaryEntitlementCWProxy {
  const _$SubscriptionSummaryEntitlementCWProxyImpl(this._value);

  final SubscriptionSummaryEntitlement _value;

  @override
  SubscriptionSummaryEntitlement id(String id) => call(id: id);

  @override
  SubscriptionSummaryEntitlement entitlementKey(String entitlementKey) =>
      call(entitlementKey: entitlementKey);

  @override
  SubscriptionSummaryEntitlement name(String name) => call(name: name);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionSummaryEntitlement(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionSummaryEntitlement(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionSummaryEntitlement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? entitlementKey = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionSummaryEntitlement(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      entitlementKey:
          entitlementKey == const $CopyWithPlaceholder() ||
              entitlementKey == null
          ? _value.entitlementKey
          // ignore: cast_nullable_to_non_nullable
          : entitlementKey as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $SubscriptionSummaryEntitlementCopyWith
    on SubscriptionSummaryEntitlement {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSubscriptionSummaryEntitlement.copyWith(...)` or `instanceOfSubscriptionSummaryEntitlement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionSummaryEntitlementCWProxy get copyWith =>
      _$SubscriptionSummaryEntitlementCWProxyImpl(this);
}

abstract class _$SubscriptionSummaryLimitsCWProxy {
  SubscriptionSummaryLimits maxPrograms(int? maxPrograms);

  SubscriptionSummaryLimits maxSessionsPerProgram(int? maxSessionsPerProgram);

  SubscriptionSummaryLimits historyDays(int? historyDays);

  SubscriptionSummaryLimits maxExercisesPerSession(int? maxExercisesPerSession);

  SubscriptionSummaryLimits canExportData(bool canExportData);

  SubscriptionSummaryLimits canSharePrograms(bool canSharePrograms);

  SubscriptionSummaryLimits metadata(Map<String, dynamic> metadata);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionSummaryLimits(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionSummaryLimits(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionSummaryLimits call({
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
/// Use as `instanceOfSubscriptionSummaryLimits.copyWith(...)` or call `instanceOfSubscriptionSummaryLimits.copyWith.fieldName(value)` for a single field.
class _$SubscriptionSummaryLimitsCWProxyImpl
    implements _$SubscriptionSummaryLimitsCWProxy {
  const _$SubscriptionSummaryLimitsCWProxyImpl(this._value);

  final SubscriptionSummaryLimits _value;

  @override
  SubscriptionSummaryLimits maxPrograms(int? maxPrograms) =>
      call(maxPrograms: maxPrograms);

  @override
  SubscriptionSummaryLimits maxSessionsPerProgram(int? maxSessionsPerProgram) =>
      call(maxSessionsPerProgram: maxSessionsPerProgram);

  @override
  SubscriptionSummaryLimits historyDays(int? historyDays) =>
      call(historyDays: historyDays);

  @override
  SubscriptionSummaryLimits maxExercisesPerSession(
    int? maxExercisesPerSession,
  ) => call(maxExercisesPerSession: maxExercisesPerSession);

  @override
  SubscriptionSummaryLimits canExportData(bool canExportData) =>
      call(canExportData: canExportData);

  @override
  SubscriptionSummaryLimits canSharePrograms(bool canSharePrograms) =>
      call(canSharePrograms: canSharePrograms);

  @override
  SubscriptionSummaryLimits metadata(Map<String, dynamic> metadata) =>
      call(metadata: metadata);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionSummaryLimits(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionSummaryLimits(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionSummaryLimits call({
    Object? maxPrograms = const $CopyWithPlaceholder(),
    Object? maxSessionsPerProgram = const $CopyWithPlaceholder(),
    Object? historyDays = const $CopyWithPlaceholder(),
    Object? maxExercisesPerSession = const $CopyWithPlaceholder(),
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
      canSharePrograms:
          canSharePrograms == const $CopyWithPlaceholder() ||
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

extension $SubscriptionSummaryLimitsCopyWith on SubscriptionSummaryLimits {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSubscriptionSummaryLimits.copyWith(...)` or `instanceOfSubscriptionSummaryLimits.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionSummaryLimitsCWProxy get copyWith =>
      _$SubscriptionSummaryLimitsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionSummary _$SubscriptionSummaryFromJson(Map<String, dynamic> json) =>
    SubscriptionSummary(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      status: const SubscriptionStatusConverter().fromJson(
        json['status'] as String,
      ),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      isTrial: json['is_trial'] as bool,
      entitlement: SubscriptionSummaryEntitlement.fromJson(
        json['entitlement'] as Map<String, dynamic>,
      ),
      product: json['product'] == null
          ? null
          : ProductSummary.fromJson(json['product'] as Map<String, dynamic>),
      limits: SubscriptionSummaryLimits.fromJson(
        json['limits'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SubscriptionSummaryToJson(
  SubscriptionSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'status': const SubscriptionStatusConverter().toJson(instance.status),
  'started_at': instance.startedAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'is_trial': instance.isTrial,
  'entitlement': instance.entitlement,
  'product': instance.product,
  'limits': instance.limits,
};

SubscriptionSummaryEntitlement _$SubscriptionSummaryEntitlementFromJson(
  Map<String, dynamic> json,
) => SubscriptionSummaryEntitlement(
  id: json['id'] as String,
  entitlementKey: json['entitlement_key'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$SubscriptionSummaryEntitlementToJson(
  SubscriptionSummaryEntitlement instance,
) => <String, dynamic>{
  'id': instance.id,
  'entitlement_key': instance.entitlementKey,
  'name': instance.name,
};

SubscriptionSummaryLimits _$SubscriptionSummaryLimitsFromJson(
  Map<String, dynamic> json,
) => SubscriptionSummaryLimits(
  maxPrograms: (json['max_programs'] as num?)?.toInt(),
  maxSessionsPerProgram: (json['max_sessions_per_program'] as num?)?.toInt(),
  historyDays: (json['history_days'] as num?)?.toInt(),
  maxExercisesPerSession: (json['max_exercises_per_session'] as num?)?.toInt(),
  canExportData: json['can_export_data'] as bool? ?? false,
  canSharePrograms: json['can_share_programs'] as bool? ?? false,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$SubscriptionSummaryLimitsToJson(
  SubscriptionSummaryLimits instance,
) => <String, dynamic>{
  'max_programs': instance.maxPrograms,
  'max_sessions_per_program': instance.maxSessionsPerProgram,
  'history_days': instance.historyDays,
  'max_exercises_per_session': instance.maxExercisesPerSession,
  'can_export_data': instance.canExportData,
  'can_share_programs': instance.canSharePrograms,
  'metadata': instance.metadata,
};
