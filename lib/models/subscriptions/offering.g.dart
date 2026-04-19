// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offering.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OfferingCWProxy {
  Offering identifier(String identifier);

  Offering serverDescription(String? serverDescription);

  Offering availablePackages(List<Package> availablePackages);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Offering(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Offering(...).copyWith(id: 12, name: "My name")
  /// ```
  Offering call({
    String identifier,
    String? serverDescription,
    List<Package> availablePackages,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfOffering.copyWith(...)` or call `instanceOfOffering.copyWith.fieldName(value)` for a single field.
class _$OfferingCWProxyImpl implements _$OfferingCWProxy {
  const _$OfferingCWProxyImpl(this._value);

  final Offering _value;

  @override
  Offering identifier(String identifier) => call(identifier: identifier);

  @override
  Offering serverDescription(String? serverDescription) =>
      call(serverDescription: serverDescription);

  @override
  Offering availablePackages(List<Package> availablePackages) =>
      call(availablePackages: availablePackages);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Offering(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Offering(...).copyWith(id: 12, name: "My name")
  /// ```
  Offering call({
    Object? identifier = const $CopyWithPlaceholder(),
    Object? serverDescription = const $CopyWithPlaceholder(),
    Object? availablePackages = const $CopyWithPlaceholder(),
  }) {
    return Offering(
      identifier:
          identifier == const $CopyWithPlaceholder() || identifier == null
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      serverDescription: serverDescription == const $CopyWithPlaceholder()
          ? _value.serverDescription
          // ignore: cast_nullable_to_non_nullable
          : serverDescription as String?,
      availablePackages:
          availablePackages == const $CopyWithPlaceholder() ||
              availablePackages == null
          ? _value.availablePackages
          // ignore: cast_nullable_to_non_nullable
          : availablePackages as List<Package>,
    );
  }
}

extension $OfferingCopyWith on Offering {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfOffering.copyWith(...)` or `instanceOfOffering.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OfferingCWProxy get copyWith => _$OfferingCWProxyImpl(this);
}
