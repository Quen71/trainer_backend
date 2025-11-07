// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EntitlementCWProxy {
  Entitlement id(String id);

  Entitlement entitlementKey(String entitlementKey);

  Entitlement name(String name);

  Entitlement createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Entitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Entitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  Entitlement call({
    String id,
    String entitlementKey,
    String name,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEntitlement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEntitlement.copyWith.fieldName(...)`
class _$EntitlementCWProxyImpl implements _$EntitlementCWProxy {
  const _$EntitlementCWProxyImpl(this._value);

  final Entitlement _value;

  @override
  Entitlement id(String id) => this(id: id);

  @override
  Entitlement entitlementKey(String entitlementKey) =>
      this(entitlementKey: entitlementKey);

  @override
  Entitlement name(String name) => this(name: name);

  @override
  Entitlement createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Entitlement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Entitlement(...).copyWith(id: 12, name: "My name")
  /// ````
  Entitlement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? entitlementKey = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Entitlement(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      entitlementKey: entitlementKey == const $CopyWithPlaceholder()
          ? _value.entitlementKey
          // ignore: cast_nullable_to_non_nullable
          : entitlementKey as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $EntitlementCopyWith on Entitlement {
  /// Returns a callable class that can be used as follows: `instanceOfEntitlement.copyWith(...)` or like so:`instanceOfEntitlement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EntitlementCWProxy get copyWith => _$EntitlementCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entitlement _$EntitlementFromJson(Map<String, dynamic> json) => Entitlement(
      id: json['id'] as String,
      entitlementKey: json['entitlement_key'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$EntitlementToJson(Entitlement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entitlement_key': instance.entitlementKey,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };
