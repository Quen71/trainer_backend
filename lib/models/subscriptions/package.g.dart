// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PackageCWProxy {
  Package identifier(String identifier);

  Package packageType(PackageType packageType);

  Package storeProduct(StoreProduct storeProduct);

  Package entitlementIdentifier(String? entitlementIdentifier);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Package(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Package(...).copyWith(id: 12, name: "My name")
  /// ```
  Package call({
    String identifier,
    PackageType packageType,
    StoreProduct storeProduct,
    String? entitlementIdentifier,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPackage.copyWith(...)` or call `instanceOfPackage.copyWith.fieldName(value)` for a single field.
class _$PackageCWProxyImpl implements _$PackageCWProxy {
  const _$PackageCWProxyImpl(this._value);

  final Package _value;

  @override
  Package identifier(String identifier) => call(identifier: identifier);

  @override
  Package packageType(PackageType packageType) =>
      call(packageType: packageType);

  @override
  Package storeProduct(StoreProduct storeProduct) =>
      call(storeProduct: storeProduct);

  @override
  Package entitlementIdentifier(String? entitlementIdentifier) =>
      call(entitlementIdentifier: entitlementIdentifier);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Package(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Package(...).copyWith(id: 12, name: "My name")
  /// ```
  Package call({
    Object? identifier = const $CopyWithPlaceholder(),
    Object? packageType = const $CopyWithPlaceholder(),
    Object? storeProduct = const $CopyWithPlaceholder(),
    Object? entitlementIdentifier = const $CopyWithPlaceholder(),
  }) {
    return Package(
      identifier:
          identifier == const $CopyWithPlaceholder() || identifier == null
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      packageType:
          packageType == const $CopyWithPlaceholder() || packageType == null
          ? _value.packageType
          // ignore: cast_nullable_to_non_nullable
          : packageType as PackageType,
      storeProduct:
          storeProduct == const $CopyWithPlaceholder() || storeProduct == null
          ? _value.storeProduct
          // ignore: cast_nullable_to_non_nullable
          : storeProduct as StoreProduct,
      entitlementIdentifier:
          entitlementIdentifier == const $CopyWithPlaceholder()
          ? _value.entitlementIdentifier
          // ignore: cast_nullable_to_non_nullable
          : entitlementIdentifier as String?,
    );
  }
}

extension $PackageCopyWith on Package {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPackage.copyWith(...)` or `instanceOfPackage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PackageCWProxy get copyWith => _$PackageCWProxyImpl(this);
}
