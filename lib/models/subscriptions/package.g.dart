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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Package(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Package(...).copyWith(id: 12, name: "My name")
  /// ````
  Package call({
    String identifier,
    PackageType packageType,
    StoreProduct storeProduct,
    String? entitlementIdentifier,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPackage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPackage.copyWith.fieldName(...)`
class _$PackageCWProxyImpl implements _$PackageCWProxy {
  const _$PackageCWProxyImpl(this._value);

  final Package _value;

  @override
  Package identifier(String identifier) => this(identifier: identifier);

  @override
  Package packageType(PackageType packageType) =>
      this(packageType: packageType);

  @override
  Package storeProduct(StoreProduct storeProduct) =>
      this(storeProduct: storeProduct);

  @override
  Package entitlementIdentifier(String? entitlementIdentifier) =>
      this(entitlementIdentifier: entitlementIdentifier);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Package(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Package(...).copyWith(id: 12, name: "My name")
  /// ````
  Package call({
    Object? identifier = const $CopyWithPlaceholder(),
    Object? packageType = const $CopyWithPlaceholder(),
    Object? storeProduct = const $CopyWithPlaceholder(),
    Object? entitlementIdentifier = const $CopyWithPlaceholder(),
  }) {
    return Package(
      identifier: identifier == const $CopyWithPlaceholder()
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      packageType: packageType == const $CopyWithPlaceholder()
          ? _value.packageType
          // ignore: cast_nullable_to_non_nullable
          : packageType as PackageType,
      storeProduct: storeProduct == const $CopyWithPlaceholder()
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
  /// Returns a callable class that can be used as follows: `instanceOfPackage.copyWith(...)` or like so:`instanceOfPackage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PackageCWProxy get copyWith => _$PackageCWProxyImpl(this);
}
