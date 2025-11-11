// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offerings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OfferingsCWProxy {
  Offerings all(Map<String, Offering> all);

  Offerings current(Offering? current);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Offerings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Offerings(...).copyWith(id: 12, name: "My name")
  /// ````
  Offerings call({
    Map<String, Offering> all,
    Offering? current,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOfferings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOfferings.copyWith.fieldName(...)`
class _$OfferingsCWProxyImpl implements _$OfferingsCWProxy {
  const _$OfferingsCWProxyImpl(this._value);

  final Offerings _value;

  @override
  Offerings all(Map<String, Offering> all) => this(all: all);

  @override
  Offerings current(Offering? current) => this(current: current);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Offerings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Offerings(...).copyWith(id: 12, name: "My name")
  /// ````
  Offerings call({
    Object? all = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
  }) {
    return Offerings(
      all: all == const $CopyWithPlaceholder()
          ? _value.all
          // ignore: cast_nullable_to_non_nullable
          : all as Map<String, Offering>,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as Offering?,
    );
  }
}

extension $OfferingsCopyWith on Offerings {
  /// Returns a callable class that can be used as follows: `instanceOfOfferings.copyWith(...)` or like so:`instanceOfOfferings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OfferingsCWProxy get copyWith => _$OfferingsCWProxyImpl(this);
}
