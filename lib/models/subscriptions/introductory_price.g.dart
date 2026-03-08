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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IntroductoryPrice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IntroductoryPrice(...).copyWith(id: 12, name: "My name")
  /// ````
  IntroductoryPrice call({
    double price,
    String priceString,
    String period,
    int cycles,
    PeriodUnit periodUnit,
    int periodNumberOfUnits,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIntroductoryPrice.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIntroductoryPrice.copyWith.fieldName(...)`
class _$IntroductoryPriceCWProxyImpl implements _$IntroductoryPriceCWProxy {
  const _$IntroductoryPriceCWProxyImpl(this._value);

  final IntroductoryPrice _value;

  @override
  IntroductoryPrice price(double price) => this(price: price);

  @override
  IntroductoryPrice priceString(String priceString) =>
      this(priceString: priceString);

  @override
  IntroductoryPrice period(String period) => this(period: period);

  @override
  IntroductoryPrice cycles(int cycles) => this(cycles: cycles);

  @override
  IntroductoryPrice periodUnit(PeriodUnit periodUnit) =>
      this(periodUnit: periodUnit);

  @override
  IntroductoryPrice periodNumberOfUnits(int periodNumberOfUnits) =>
      this(periodNumberOfUnits: periodNumberOfUnits);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IntroductoryPrice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IntroductoryPrice(...).copyWith(id: 12, name: "My name")
  /// ````
  IntroductoryPrice call({
    Object? price = const $CopyWithPlaceholder(),
    Object? priceString = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? cycles = const $CopyWithPlaceholder(),
    Object? periodUnit = const $CopyWithPlaceholder(),
    Object? periodNumberOfUnits = const $CopyWithPlaceholder(),
  }) {
    return IntroductoryPrice(
      price: price == const $CopyWithPlaceholder()
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as double,
      priceString: priceString == const $CopyWithPlaceholder()
          ? _value.priceString
          // ignore: cast_nullable_to_non_nullable
          : priceString as String,
      period: period == const $CopyWithPlaceholder()
          ? _value.period
          // ignore: cast_nullable_to_non_nullable
          : period as String,
      cycles: cycles == const $CopyWithPlaceholder()
          ? _value.cycles
          // ignore: cast_nullable_to_non_nullable
          : cycles as int,
      periodUnit: periodUnit == const $CopyWithPlaceholder()
          ? _value.periodUnit
          // ignore: cast_nullable_to_non_nullable
          : periodUnit as PeriodUnit,
      periodNumberOfUnits: periodNumberOfUnits == const $CopyWithPlaceholder()
          ? _value.periodNumberOfUnits
          // ignore: cast_nullable_to_non_nullable
          : periodNumberOfUnits as int,
    );
  }
}

extension $IntroductoryPriceCopyWith on IntroductoryPrice {
  /// Returns a callable class that can be used as follows: `instanceOfIntroductoryPrice.copyWith(...)` or like so:`instanceOfIntroductoryPrice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IntroductoryPriceCWProxy get copyWith =>
      _$IntroductoryPriceCWProxyImpl(this);
}
