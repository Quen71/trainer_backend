// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementInfoCWProxy {
  EntitlementInfo identifier(String identifier);

  EntitlementInfo isActive(bool isActive);

  EntitlementInfo willRenew(bool willRenew);

  EntitlementInfo periodType(String periodType);

  EntitlementInfo latestPurchaseDate(DateTime latestPurchaseDate);

  EntitlementInfo originalPurchaseDate(DateTime originalPurchaseDate);

  EntitlementInfo expirationDate(DateTime? expirationDate);

  EntitlementInfo store(String store);

  EntitlementInfo productIdentifier(String productIdentifier);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementInfo call({
    String identifier,
    bool isActive,
    bool willRenew,
    String periodType,
    DateTime latestPurchaseDate,
    DateTime originalPurchaseDate,
    DateTime? expirationDate,
    String store,
    String productIdentifier,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlementInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlementInfo.copyWith.fieldName(...)`
class _$EntitlementInfoCWProxyImpl implements _$EntitlementInfoCWProxy {
  const _$EntitlementInfoCWProxyImpl(this._value);

  final EntitlementInfo _value;

  @override
  EntitlementInfo identifier(String identifier) => this(identifier: identifier);

  @override
  EntitlementInfo isActive(bool isActive) => this(isActive: isActive);

  @override
  EntitlementInfo willRenew(bool willRenew) => this(willRenew: willRenew);

  @override
  EntitlementInfo periodType(String periodType) => this(periodType: periodType);

  @override
  EntitlementInfo latestPurchaseDate(DateTime latestPurchaseDate) =>
      this(latestPurchaseDate: latestPurchaseDate);

  @override
  EntitlementInfo originalPurchaseDate(DateTime originalPurchaseDate) =>
      this(originalPurchaseDate: originalPurchaseDate);

  @override
  EntitlementInfo expirationDate(DateTime? expirationDate) =>
      this(expirationDate: expirationDate);

  @override
  EntitlementInfo store(String store) => this(store: store);

  @override
  EntitlementInfo productIdentifier(String productIdentifier) =>
      this(productIdentifier: productIdentifier);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EntitlementInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EntitlementInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  EntitlementInfo call({
    Object? identifier = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
    Object? willRenew = const $CopyWithPlaceholder(),
    Object? periodType = const $CopyWithPlaceholder(),
    Object? latestPurchaseDate = const $CopyWithPlaceholder(),
    Object? originalPurchaseDate = const $CopyWithPlaceholder(),
    Object? expirationDate = const $CopyWithPlaceholder(),
    Object? store = const $CopyWithPlaceholder(),
    Object? productIdentifier = const $CopyWithPlaceholder(),
  }) {
    return EntitlementInfo(
      identifier: identifier == const $CopyWithPlaceholder()
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool,
      willRenew: willRenew == const $CopyWithPlaceholder()
          ? _value.willRenew
          // ignore: cast_nullable_to_non_nullable
          : willRenew as bool,
      periodType: periodType == const $CopyWithPlaceholder()
          ? _value.periodType
          // ignore: cast_nullable_to_non_nullable
          : periodType as String,
      latestPurchaseDate: latestPurchaseDate == const $CopyWithPlaceholder()
          ? _value.latestPurchaseDate
          // ignore: cast_nullable_to_non_nullable
          : latestPurchaseDate as DateTime,
      originalPurchaseDate: originalPurchaseDate == const $CopyWithPlaceholder()
          ? _value.originalPurchaseDate
          // ignore: cast_nullable_to_non_nullable
          : originalPurchaseDate as DateTime,
      expirationDate: expirationDate == const $CopyWithPlaceholder()
          ? _value.expirationDate
          // ignore: cast_nullable_to_non_nullable
          : expirationDate as DateTime?,
      store: store == const $CopyWithPlaceholder()
          ? _value.store
          // ignore: cast_nullable_to_non_nullable
          : store as String,
      productIdentifier: productIdentifier == const $CopyWithPlaceholder()
          ? _value.productIdentifier
          // ignore: cast_nullable_to_non_nullable
          : productIdentifier as String,
    );
  }
}

extension $EntitlementInfoCopyWith on EntitlementInfo {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlementInfo.copyWith(...)` or like so:`instanceOfEntitlementInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementInfoCWProxy get copyWith => _$EntitlementInfoCWProxyImpl(this);
}
