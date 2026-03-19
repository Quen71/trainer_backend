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

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StoreProduct(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StoreProduct(...).copyWith(id: 12, name: "My name")
  /// ```
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

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfStoreProduct.copyWith(...)` or call `instanceOfStoreProduct.copyWith.fieldName(value)` for a single field.
class _$StoreProductCWProxyImpl implements _$StoreProductCWProxy {
  const _$StoreProductCWProxyImpl(this._value);

  final StoreProduct _value;

  @override
  StoreProduct identifier(String identifier) => call(identifier: identifier);

  @override
  StoreProduct title(String title) => call(title: title);

  @override
  StoreProduct description(String description) =>
      call(description: description);

  @override
  StoreProduct price(double price) => call(price: price);

  @override
  StoreProduct priceString(String priceString) =>
      call(priceString: priceString);

  @override
  StoreProduct currencyCode(String currencyCode) =>
      call(currencyCode: currencyCode);

  @override
  StoreProduct introductoryPrice(IntroductoryPrice? introductoryPrice) =>
      call(introductoryPrice: introductoryPrice);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StoreProduct(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StoreProduct(...).copyWith(id: 12, name: "My name")
  /// ```
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
      identifier:
          identifier == const $CopyWithPlaceholder() || identifier == null
              ? _value.identifier
              // ignore: cast_nullable_to_non_nullable
              : identifier as String,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description:
          description == const $CopyWithPlaceholder() || description == null
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String,
      price: price == const $CopyWithPlaceholder() || price == null
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as double,
      priceString:
          priceString == const $CopyWithPlaceholder() || priceString == null
              ? _value.priceString
              // ignore: cast_nullable_to_non_nullable
              : priceString as String,
      currencyCode:
          currencyCode == const $CopyWithPlaceholder() || currencyCode == null
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
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfStoreProduct.copyWith(...)` or `instanceOfStoreProduct.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StoreProductCWProxy get copyWith => _$StoreProductCWProxyImpl(this);
}
