// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProgramCWProxy {
  Program id(int id);

  Program userId(String userId);

  Program name(String name);

  Program description(String? description);

  Program sessions(List<Session> sessions);

  Program isFavorite(bool isFavorite);

  Program createdAt(DateTime createdAt);

  Program updatedAt(DateTime updatedAt);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Program(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Program(...).copyWith(id: 12, name: "My name")
  /// ```
  Program call({
    int id,
    String userId,
    String name,
    String? description,
    List<Session> sessions,
    bool isFavorite,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProgram.copyWith(...)` or call `instanceOfProgram.copyWith.fieldName(value)` for a single field.
class _$ProgramCWProxyImpl implements _$ProgramCWProxy {
  const _$ProgramCWProxyImpl(this._value);

  final Program _value;

  @override
  Program id(int id) => call(id: id);

  @override
  Program userId(String userId) => call(userId: userId);

  @override
  Program name(String name) => call(name: name);

  @override
  Program description(String? description) => call(description: description);

  @override
  Program sessions(List<Session> sessions) => call(sessions: sessions);

  @override
  Program isFavorite(bool isFavorite) => call(isFavorite: isFavorite);

  @override
  Program createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  Program updatedAt(DateTime updatedAt) => call(updatedAt: updatedAt);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Program(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Program(...).copyWith(id: 12, name: "My name")
  /// ```
  Program call({
    Object? id = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? sessions = const $CopyWithPlaceholder(),
    Object? isFavorite = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Program(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      userId: userId == const $CopyWithPlaceholder() || userId == null
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      sessions: sessions == const $CopyWithPlaceholder() || sessions == null
          ? _value.sessions
          // ignore: cast_nullable_to_non_nullable
          : sessions as List<Session>,
      isFavorite:
          isFavorite == const $CopyWithPlaceholder() || isFavorite == null
              ? _value.isFavorite
              // ignore: cast_nullable_to_non_nullable
              : isFavorite as bool,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $ProgramCopyWith on Program {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProgram.copyWith(...)` or `instanceOfProgram.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProgramCWProxy get copyWith => _$ProgramCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Program _$ProgramFromJson(Map<String, dynamic> json) => Program(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Session>[],
      isFavorite: json['is_favorite'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProgramToJson(Program instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'sessions': instance.sessions,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
