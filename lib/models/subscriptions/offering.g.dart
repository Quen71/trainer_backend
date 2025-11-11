// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offering.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OfferingCWProxy {
  Offering identifier(String identifier);

  Offering serverDescription(String? serverDescription);

  Offering availablePackages(List<Package> availablePackages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Offering(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Offering(...).copyWith(id: 12, name: "My name")
  /// ````
  Offering call({
    String identifier,
    String? serverDescription,
    List<Package> availablePackages,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOffering.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOffering.copyWith.fieldName(...)`
class _$OfferingCWProxyImpl implements _$OfferingCWProxy {
  const _$OfferingCWProxyImpl(this._value);

  final Offering _value;

  @override
  Offering identifier(String identifier) => this(identifier: identifier);

  @override
  Offering serverDescription(String? serverDescription) =>
      this(serverDescription: serverDescription);

  @override
  Offering availablePackages(List<Package> availablePackages) =>
      this(availablePackages: availablePackages);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Offering(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Offering(...).copyWith(id: 12, name: "My name")
  /// ````
  Offering call({
    Object? identifier = const $CopyWithPlaceholder(),
    Object? serverDescription = const $CopyWithPlaceholder(),
    Object? availablePackages = const $CopyWithPlaceholder(),
  }) {
    return Offering(
      identifier: identifier == const $CopyWithPlaceholder()
          ? _value.identifier
          // ignore: cast_nullable_to_non_nullable
          : identifier as String,
      serverDescription: serverDescription == const $CopyWithPlaceholder()
          ? _value.serverDescription
          // ignore: cast_nullable_to_non_nullable
          : serverDescription as String?,
      availablePackages: availablePackages == const $CopyWithPlaceholder()
          ? _value.availablePackages
          // ignore: cast_nullable_to_non_nullable
          : availablePackages as List<Package>,
    );
  }
}

extension $OfferingCopyWith on Offering {
  /// Returns a callable class that can be used as follows: `instanceOfOffering.copyWith(...)` or like so:`instanceOfOffering.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OfferingCWProxy get copyWith => _$OfferingCWProxyImpl(this);
}
