// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offerings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OfferingsCWProxy {
  Offerings all(Map<String, Offering> all);

  Offerings current(Offering? current);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Offerings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Offerings(...).copyWith(id: 12, name: "My name")
  /// ```
  Offerings call({
    Map<String, Offering> all,
    Offering? current,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfOfferings.copyWith(...)` or call `instanceOfOfferings.copyWith.fieldName(value)` for a single field.
class _$OfferingsCWProxyImpl implements _$OfferingsCWProxy {
  const _$OfferingsCWProxyImpl(this._value);

  final Offerings _value;

  @override
  Offerings all(Map<String, Offering> all) => call(all: all);

  @override
  Offerings current(Offering? current) => call(current: current);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Offerings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Offerings(...).copyWith(id: 12, name: "My name")
  /// ```
  Offerings call({
    Object? all = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
  }) {
    return Offerings(
      all: all == const $CopyWithPlaceholder() || all == null
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
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfOfferings.copyWith(...)` or `instanceOfOfferings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OfferingsCWProxy get copyWith => _$OfferingsCWProxyImpl(this);
}
