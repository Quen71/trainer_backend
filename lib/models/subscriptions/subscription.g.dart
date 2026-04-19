// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubscriptionCWProxy {
  Subscription id(String id);

  Subscription userId(String userId);

  Subscription entitlementId(String entitlementId);

  Subscription productId(String? productId);

  Subscription vendorTransactionId(String? vendorTransactionId);

  Subscription status(SubscriptionStatus status);

  Subscription startedAt(DateTime startedAt);

  Subscription expiresAt(DateTime? expiresAt);

  Subscription isTrial(bool isTrial);

  Subscription rawReceipt(Map<String, dynamic>? rawReceipt);

  Subscription metadata(Map<String, dynamic> metadata);

  Subscription createdAt(DateTime createdAt);

  Subscription updatedAt(DateTime updatedAt);

  Subscription entitlement(Entitlement? entitlement);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Subscription(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Subscription(...).copyWith(id: 12, name: "My name")
  /// ```
  Subscription call({
    String id,
    String userId,
    String entitlementId,
    String? productId,
    String? vendorTransactionId,
    SubscriptionStatus status,
    DateTime startedAt,
    DateTime? expiresAt,
    bool isTrial,
    Map<String, dynamic>? rawReceipt,
    Map<String, dynamic> metadata,
    DateTime createdAt,
    DateTime updatedAt,
    Entitlement? entitlement,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSubscription.copyWith(...)` or call `instanceOfSubscription.copyWith.fieldName(value)` for a single field.
class _$SubscriptionCWProxyImpl implements _$SubscriptionCWProxy {
  const _$SubscriptionCWProxyImpl(this._value);

  final Subscription _value;

  @override
  Subscription id(String id) => call(id: id);

  @override
  Subscription userId(String userId) => call(userId: userId);

  @override
  Subscription entitlementId(String entitlementId) =>
      call(entitlementId: entitlementId);

  @override
  Subscription productId(String? productId) => call(productId: productId);

  @override
  Subscription vendorTransactionId(String? vendorTransactionId) =>
      call(vendorTransactionId: vendorTransactionId);

  @override
  Subscription status(SubscriptionStatus status) => call(status: status);

  @override
  Subscription startedAt(DateTime startedAt) => call(startedAt: startedAt);

  @override
  Subscription expiresAt(DateTime? expiresAt) => call(expiresAt: expiresAt);

  @override
  Subscription isTrial(bool isTrial) => call(isTrial: isTrial);

  @override
  Subscription rawReceipt(Map<String, dynamic>? rawReceipt) =>
      call(rawReceipt: rawReceipt);

  @override
  Subscription metadata(Map<String, dynamic> metadata) =>
      call(metadata: metadata);

  @override
  Subscription createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  Subscription updatedAt(DateTime updatedAt) => call(updatedAt: updatedAt);

  @override
  Subscription entitlement(Entitlement? entitlement) =>
      call(entitlement: entitlement);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Subscription(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Subscription(...).copyWith(id: 12, name: "My name")
  /// ```
  Subscription call({
    Object? id = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? entitlementId = const $CopyWithPlaceholder(),
    Object? productId = const $CopyWithPlaceholder(),
    Object? vendorTransactionId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? isTrial = const $CopyWithPlaceholder(),
    Object? rawReceipt = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? entitlement = const $CopyWithPlaceholder(),
  }) {
    return Subscription(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      userId: userId == const $CopyWithPlaceholder() || userId == null
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      entitlementId:
          entitlementId == const $CopyWithPlaceholder() || entitlementId == null
          ? _value.entitlementId
          // ignore: cast_nullable_to_non_nullable
          : entitlementId as String,
      productId: productId == const $CopyWithPlaceholder()
          ? _value.productId
          // ignore: cast_nullable_to_non_nullable
          : productId as String?,
      vendorTransactionId: vendorTransactionId == const $CopyWithPlaceholder()
          ? _value.vendorTransactionId
          // ignore: cast_nullable_to_non_nullable
          : vendorTransactionId as String?,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as SubscriptionStatus,
      startedAt: startedAt == const $CopyWithPlaceholder() || startedAt == null
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      isTrial: isTrial == const $CopyWithPlaceholder() || isTrial == null
          ? _value.isTrial
          // ignore: cast_nullable_to_non_nullable
          : isTrial as bool,
      rawReceipt: rawReceipt == const $CopyWithPlaceholder()
          ? _value.rawReceipt
          // ignore: cast_nullable_to_non_nullable
          : rawReceipt as Map<String, dynamic>?,
      metadata: metadata == const $CopyWithPlaceholder() || metadata == null
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Map<String, dynamic>,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      entitlement: entitlement == const $CopyWithPlaceholder()
          ? _value.entitlement
          // ignore: cast_nullable_to_non_nullable
          : entitlement as Entitlement?,
    );
  }
}

extension $SubscriptionCopyWith on Subscription {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSubscription.copyWith(...)` or `instanceOfSubscription.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionCWProxy get copyWith => _$SubscriptionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  entitlementId: json['entitlement_id'] as String,
  productId: json['product_id'] as String?,
  vendorTransactionId: json['vendor_transaction_id'] as String?,
  status: const SubscriptionStatusConverter().fromJson(
    json['status'] as String,
  ),
  startedAt: DateTime.parse(json['started_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  isTrial: json['is_trial'] as bool? ?? false,
  rawReceipt: json['raw_receipt'] as Map<String, dynamic>?,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  entitlement: json['entitlement'] == null
      ? null
      : Entitlement.fromJson(json['entitlement'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'entitlement_id': instance.entitlementId,
      'product_id': instance.productId,
      'vendor_transaction_id': instance.vendorTransactionId,
      'status': const SubscriptionStatusConverter().toJson(instance.status),
      'started_at': instance.startedAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_trial': instance.isTrial,
      'raw_receipt': instance.rawReceipt,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
