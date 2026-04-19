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

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EntitlementInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EntitlementInfo(...).copyWith(id: 12, name: "My name")
  /// ```
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

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEntitlementInfo.copyWith(...)` or call `instanceOfEntitlementInfo.copyWith.fieldName(value)` for a single field.
class _$EntitlementInfoCWProxyImpl implements _$EntitlementInfoCWProxy {
  const _$EntitlementInfoCWProxyImpl(this._value);

  final EntitlementInfo _value;

  @override
  EntitlementInfo identifier(String identifier) => call(identifier: identifier);

  @override
  EntitlementInfo isActive(bool isActive) => call(isActive: isActive);

  @override
  EntitlementInfo willRenew(bool willRenew) => call(willRenew: willRenew);

  @override
  EntitlementInfo periodType(String periodType) => call(periodType: periodType);

  @override
  EntitlementInfo latestPurchaseDate(DateTime latestPurchaseDate) =>
      call(latestPurchaseDate: latestPurchaseDate);

  @override
  EntitlementInfo originalPurchaseDate(DateTime originalPurchaseDate) =>
      call(originalPurchaseDate: originalPurchaseDate);

  @override
  EntitlementInfo expirationDate(DateTime? expirationDate) =>
      call(expirationDate: expirationDate);

  @override
  EntitlementInfo store(String store) => call(store: store);

  @override
  EntitlementInfo productIdentifier(String productIdentifier) =>
      call(productIdentifier: productIdentifier);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EntitlementInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EntitlementInfo(...).copyWith(id: 12, name: "My name")
  /// ```
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
      identifier:
          identifier == const $CopyWithPlaceholder() || identifier == null
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      isActive: isActive == const $CopyWithPlaceholder() || isActive == null
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool,
      willRenew: willRenew == const $CopyWithPlaceholder() || willRenew == null
          ? _value.willRenew
          // ignore: cast_nullable_to_non_nullable
          : willRenew as bool,
      periodType:
          periodType == const $CopyWithPlaceholder() || periodType == null
          ? _value.periodType
          // ignore: cast_nullable_to_non_nullable
          : periodType as String,
      latestPurchaseDate:
          latestPurchaseDate == const $CopyWithPlaceholder() ||
              latestPurchaseDate == null
          ? _value.latestPurchaseDate
          // ignore: cast_nullable_to_non_nullable
          : latestPurchaseDate as DateTime,
      originalPurchaseDate:
          originalPurchaseDate == const $CopyWithPlaceholder() ||
              originalPurchaseDate == null
          ? _value.originalPurchaseDate
          // ignore: cast_nullable_to_non_nullable
          : originalPurchaseDate as DateTime,
      expirationDate: expirationDate == const $CopyWithPlaceholder()
          ? _value.expirationDate
          // ignore: cast_nullable_to_non_nullable
          : expirationDate as DateTime?,
      store: store == const $CopyWithPlaceholder() || store == null
          ? _value.store
          // ignore: cast_nullable_to_non_nullable
          : store as String,
      productIdentifier:
          productIdentifier == const $CopyWithPlaceholder() ||
              productIdentifier == null
          ? _value.productIdentifier
          // ignore: cast_nullable_to_non_nullable
          : productIdentifier as String,
    );
  }
}

extension $EntitlementInfoCopyWith on EntitlementInfo {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEntitlementInfo.copyWith(...)` or `instanceOfEntitlementInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementInfoCWProxy get copyWith => _$EntitlementInfoCWProxyImpl(this);
}
