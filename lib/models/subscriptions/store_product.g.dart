// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_product.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StoreProductCWProxy {
  StoreProduct identifier(String identifier);

  StoreProduct title(String title);

  StoreProduct description(String description);

  StoreProduct price(double price);

  StoreProduct priceString(String priceString);

  StoreProduct currencyCode(String currencyCode);

  StoreProduct introductoryPrice(IntroductoryPrice? introductoryPrice);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StoreProduct(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StoreProduct(...).copyWith(id: 12, name: "My name")
  /// ````
  StoreProduct call({
    String identifier,
    String title,
    String description,
    double price,
    String priceString,
    String currencyCode,
    IntroductoryPrice? introductoryPrice,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStoreProduct.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStoreProduct.copyWith.fieldName(...)`
class _$StoreProductCWProxyImpl implements _$StoreProductCWProxy {
  const _$StoreProductCWProxyImpl(this._value);

  final StoreProduct _value;

  @override
  StoreProduct identifier(String identifier) => this(identifier: identifier);

  @override
  StoreProduct title(String title) => this(title: title);

  @override
  StoreProduct description(String description) =>
      this(description: description);

  @override
  StoreProduct price(double price) => this(price: price);

  @override
  StoreProduct priceString(String priceString) =>
      this(priceString: priceString);

  @override
  StoreProduct currencyCode(String currencyCode) =>
      this(currencyCode: currencyCode);

  @override
  StoreProduct introductoryPrice(IntroductoryPrice? introductoryPrice) =>
      this(introductoryPrice: introductoryPrice);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StoreProduct(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StoreProduct(...).copyWith(id: 12, name: "My name")
  /// ````
  StoreProduct call({
    Object? identifier = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? price = const $CopyWithPlaceholder(),
    Object? priceString = const $CopyWithPlaceholder(),
    Object? currencyCode = const $CopyWithPlaceholder(),
    Object? introductoryPrice = const $CopyWithPlaceholder(),
  }) {
    return StoreProduct(
      identifier: identifier == const $CopyWithPlaceholder()
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      price: price == const $CopyWithPlaceholder()
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as double,
      priceString: priceString == const $CopyWithPlaceholder()
          ? _value.priceString
          // ignore: cast_nullable_to_non_nullable
          : priceString as String,
      currencyCode: currencyCode == const $CopyWithPlaceholder()
          ? _value.currencyCode
          // ignore: cast_nullable_to_non_nullable
          : currencyCode as String,
      introductoryPrice: introductoryPrice == const $CopyWithPlaceholder()
          ? _value.introductoryPrice
          // ignore: cast_nullable_to_non_nullable
          : introductoryPrice as IntroductoryPrice?,
    );
  }
}

extension $StoreProductCopyWith on StoreProduct {
  /// Returns a callable class that can be used as follows: `instanceOfStoreProduct.copyWith(...)` or like so:`instanceOfStoreProduct.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StoreProductCWProxy get copyWith => _$StoreProductCWProxyImpl(this);
}
