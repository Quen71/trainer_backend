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

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Entitlement(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Entitlement(...).copyWith(id: 12, name: "My name")
  /// ```
  Entitlement call({
    String id,
    String entitlementKey,
    String name,
    DateTime createdAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEntitlement.copyWith(...)` or call `instanceOfEntitlement.copyWith.fieldName(value)` for a single field.
class _$EntitlementCWProxyImpl implements _$EntitlementCWProxy {
  const _$EntitlementCWProxyImpl(this._value);

  final Entitlement _value;

  @override
  Entitlement id(String id) => call(id: id);

  @override
  Entitlement entitlementKey(String entitlementKey) =>
      call(entitlementKey: entitlementKey);

  @override
  Entitlement name(String name) => call(name: name);

  @override
  Entitlement createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Entitlement(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Entitlement(...).copyWith(id: 12, name: "My name")
  /// ```
  Entitlement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? entitlementKey = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Entitlement(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      entitlementKey: entitlementKey == const $CopyWithPlaceholder() ||
              entitlementKey == null
          ? _value.entitlementKey
          // ignore: cast_nullable_to_non_nullable
          : entitlementKey as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $EntitlementCopyWith on Entitlement {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEntitlement.copyWith(...)` or `instanceOfEntitlement.copyWith.fieldName(...)`.
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
