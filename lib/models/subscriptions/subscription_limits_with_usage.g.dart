// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_limits_with_usage.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubscriptionLimitsWithUsageCWProxy {
  SubscriptionLimitsWithUsage id(String? id);

  SubscriptionLimitsWithUsage userId(String userId);

  SubscriptionLimitsWithUsage status(SubscriptionStatus status);

  SubscriptionLimitsWithUsage startedAt(DateTime? startedAt);

  SubscriptionLimitsWithUsage expiresAt(DateTime? expiresAt);

  SubscriptionLimitsWithUsage isTrial(bool isTrial);

  SubscriptionLimitsWithUsage entitlement(
      SubscriptionSummaryEntitlement entitlement);

  SubscriptionLimitsWithUsage product(ProductSummary? product);

  SubscriptionLimitsWithUsage limits(SubscriptionSummaryLimits limits);

  SubscriptionLimitsWithUsage usage(SubscriptionUsage usage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionLimitsWithUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionLimitsWithUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionLimitsWithUsage call({
    String? id,
    String userId,
    SubscriptionStatus status,
    DateTime? startedAt,
    DateTime? expiresAt,
    bool isTrial,
    SubscriptionSummaryEntitlement entitlement,
    ProductSummary? product,
    SubscriptionSummaryLimits limits,
    SubscriptionUsage usage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubscriptionLimitsWithUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubscriptionLimitsWithUsage.copyWith.fieldName(...)`
class _$SubscriptionLimitsWithUsageCWProxyImpl
    implements _$SubscriptionLimitsWithUsageCWProxy {
  const _$SubscriptionLimitsWithUsageCWProxyImpl(this._value);

  final SubscriptionLimitsWithUsage _value;

  @override
  SubscriptionLimitsWithUsage id(String? id) => this(id: id);

  @override
  SubscriptionLimitsWithUsage userId(String userId) => this(userId: userId);

  @override
  SubscriptionLimitsWithUsage status(SubscriptionStatus status) =>
      this(status: status);

  @override
  SubscriptionLimitsWithUsage startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  SubscriptionLimitsWithUsage expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  SubscriptionLimitsWithUsage isTrial(bool isTrial) => this(isTrial: isTrial);

  @override
  SubscriptionLimitsWithUsage entitlement(
          SubscriptionSummaryEntitlement entitlement) =>
      this(entitlement: entitlement);

  @override
  SubscriptionLimitsWithUsage product(ProductSummary? product) =>
      this(product: product);

  @override
  SubscriptionLimitsWithUsage limits(SubscriptionSummaryLimits limits) =>
      this(limits: limits);

  @override
  SubscriptionLimitsWithUsage usage(SubscriptionUsage usage) =>
      this(usage: usage);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionLimitsWithUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionLimitsWithUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionLimitsWithUsage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? isTrial = const $CopyWithPlaceholder(),
    Object? entitlement = const $CopyWithPlaceholder(),
    Object? product = const $CopyWithPlaceholder(),
    Object? limits = const $CopyWithPlaceholder(),
    Object? usage = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionLimitsWithUsage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
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
          : startedAt as DateTime?,
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
      usage: usage == const $CopyWithPlaceholder()
          ? _value.usage
          // ignore: cast_nullable_to_non_nullable
          : usage as SubscriptionUsage,
    );
  }
}

extension $SubscriptionLimitsWithUsageCopyWith on SubscriptionLimitsWithUsage {
  /// Returns a callable class that can be used as follows: `instanceOfSubscriptionLimitsWithUsage.copyWith(...)` or like so:`instanceOfSubscriptionLimitsWithUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionLimitsWithUsageCWProxy get copyWith =>
      _$SubscriptionLimitsWithUsageCWProxyImpl(this);
}

abstract class _$SubscriptionUsageCWProxy {
  SubscriptionUsage programsCount(int programsCount);

  SubscriptionUsage sessionsCountByProgram(
      Map<String, int> sessionsCountByProgram);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionUsage call({
    int programsCount,
    Map<String, int> sessionsCountByProgram,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubscriptionUsage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubscriptionUsage.copyWith.fieldName(...)`
class _$SubscriptionUsageCWProxyImpl implements _$SubscriptionUsageCWProxy {
  const _$SubscriptionUsageCWProxyImpl(this._value);

  final SubscriptionUsage _value;

  @override
  SubscriptionUsage programsCount(int programsCount) =>
      this(programsCount: programsCount);

  @override
  SubscriptionUsage sessionsCountByProgram(
          Map<String, int> sessionsCountByProgram) =>
      this(sessionsCountByProgram: sessionsCountByProgram);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubscriptionUsage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubscriptionUsage(...).copyWith(id: 12, name: "My name")
  /// ````
  SubscriptionUsage call({
    Object? programsCount = const $CopyWithPlaceholder(),
    Object? sessionsCountByProgram = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionUsage(
      programsCount: programsCount == const $CopyWithPlaceholder()
          ? _value.programsCount
          // ignore: cast_nullable_to_non_nullable
          : programsCount as int,
      sessionsCountByProgram:
          sessionsCountByProgram == const $CopyWithPlaceholder()
              ? _value.sessionsCountByProgram
              // ignore: cast_nullable_to_non_nullable
              : sessionsCountByProgram as Map<String, int>,
    );
  }
}

extension $SubscriptionUsageCopyWith on SubscriptionUsage {
  /// Returns a callable class that can be used as follows: `instanceOfSubscriptionUsage.copyWith(...)` or like so:`instanceOfSubscriptionUsage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionUsageCWProxy get copyWith =>
      _$SubscriptionUsageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionLimitsWithUsage _$SubscriptionLimitsWithUsageFromJson(
        Map<String, dynamic> json) =>
    SubscriptionLimitsWithUsage(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      status: const SubscriptionStatusConverter()
          .fromJson(json['status'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
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
      usage: SubscriptionUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionLimitsWithUsageToJson(
        SubscriptionLimitsWithUsage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'status': const SubscriptionStatusConverter().toJson(instance.status),
      'started_at': instance.startedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_trial': instance.isTrial,
      'entitlement': instance.entitlement,
      'product': instance.product,
      'limits': instance.limits,
      'usage': instance.usage,
    };

SubscriptionUsage _$SubscriptionUsageFromJson(Map<String, dynamic> json) =>
    SubscriptionUsage(
      programsCount: (json['programs_count'] as num).toInt(),
      sessionsCountByProgram: const SessionsCountMapConverter()
          .fromJson(json['sessions_count_by_program'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionUsageToJson(SubscriptionUsage instance) =>
    <String, dynamic>{
      'programs_count': instance.programsCount,
      'sessions_count_by_program': const SessionsCountMapConverter()
          .toJson(instance.sessionsCountByProgram),
    };
