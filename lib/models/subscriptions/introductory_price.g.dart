// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introductory_price.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IntroductoryPriceCWProxy {
  IntroductoryPrice price(double price);

  IntroductoryPrice priceString(String priceString);

  IntroductoryPrice period(String period);

  IntroductoryPrice cycles(int cycles);

  IntroductoryPrice periodUnit(PeriodUnit periodUnit);

  IntroductoryPrice periodNumberOfUnits(int periodNumberOfUnits);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `IntroductoryPrice(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// IntroductoryPrice(...).copyWith(id: 12, name: "My name")
  /// ```
  IntroductoryPrice call({
    double price,
    String priceString,
    String period,
    int cycles,
    PeriodUnit periodUnit,
    int periodNumberOfUnits,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfIntroductoryPrice.copyWith(...)` or call `instanceOfIntroductoryPrice.copyWith.fieldName(value)` for a single field.
class _$IntroductoryPriceCWProxyImpl implements _$IntroductoryPriceCWProxy {
  const _$IntroductoryPriceCWProxyImpl(this._value);

  final IntroductoryPrice _value;

  @override
  IntroductoryPrice price(double price) => call(price: price);

  @override
  IntroductoryPrice priceString(String priceString) =>
      call(priceString: priceString);

  @override
  IntroductoryPrice period(String period) => call(period: period);

  @override
  IntroductoryPrice cycles(int cycles) => call(cycles: cycles);

  @override
  IntroductoryPrice periodUnit(PeriodUnit periodUnit) =>
      call(periodUnit: periodUnit);

  @override
  IntroductoryPrice periodNumberOfUnits(int periodNumberOfUnits) =>
      call(periodNumberOfUnits: periodNumberOfUnits);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `IntroductoryPrice(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// IntroductoryPrice(...).copyWith(id: 12, name: "My name")
  /// ```
  IntroductoryPrice call({
    Object? price = const $CopyWithPlaceholder(),
    Object? priceString = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? cycles = const $CopyWithPlaceholder(),
    Object? periodUnit = const $CopyWithPlaceholder(),
    Object? periodNumberOfUnits = const $CopyWithPlaceholder(),
  }) {
    return IntroductoryPrice(
      price: price == const $CopyWithPlaceholder() || price == null
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as double,
      priceString:
          priceString == const $CopyWithPlaceholder() || priceString == null
              ? _value.priceString
              // ignore: cast_nullable_to_non_nullable
              : priceString as String,
      period: period == const $CopyWithPlaceholder() || period == null
          ? _value.period
          // ignore: cast_nullable_to_non_nullable
          : period as String,
      cycles: cycles == const $CopyWithPlaceholder() || cycles == null
          ? _value.cycles
          // ignore: cast_nullable_to_non_nullable
          : cycles as int,
      periodUnit:
          periodUnit == const $CopyWithPlaceholder() || periodUnit == null
              ? _value.periodUnit
              // ignore: cast_nullable_to_non_nullable
              : periodUnit as PeriodUnit,
      periodNumberOfUnits:
          periodNumberOfUnits == const $CopyWithPlaceholder() ||
                  periodNumberOfUnits == null
              ? _value.periodNumberOfUnits
              // ignore: cast_nullable_to_non_nullable
              : periodNumberOfUnits as int,
    );
  }
}

extension $IntroductoryPriceCopyWith on IntroductoryPrice {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfIntroductoryPrice.copyWith(...)` or `instanceOfIntroductoryPrice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IntroductoryPriceCWProxy get copyWith =>
      _$IntroductoryPriceCWProxyImpl(this);
}
