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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Program(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Program(...).copyWith(id: 12, name: "My name")
  /// ````
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

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProgram.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProgram.copyWith.fieldName(...)`
class _$ProgramCWProxyImpl implements _$ProgramCWProxy {
  const _$ProgramCWProxyImpl(this._value);

  final Program _value;

  @override
  Program id(int id) => this(id: id);

  @override
  Program userId(String userId) => this(userId: userId);

  @override
  Program name(String name) => this(name: name);

  @override
  Program description(String? description) => this(description: description);

  @override
  Program sessions(List<Session> sessions) => this(sessions: sessions);

  @override
  Program isFavorite(bool isFavorite) => this(isFavorite: isFavorite);

  @override
  Program createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Program updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Program(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Program(...).copyWith(id: 12, name: "My name")
  /// ````
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
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      sessions: sessions == const $CopyWithPlaceholder()
          ? _value.sessions
          // ignore: cast_nullable_to_non_nullable
          : sessions as List<Session>,
      isFavorite: isFavorite == const $CopyWithPlaceholder()
          ? _value.isFavorite
          // ignore: cast_nullable_to_non_nullable
          : isFavorite as bool,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $ProgramCopyWith on Program {
  /// Returns a callable class that can be used as follows: `instanceOfProgram.copyWith(...)` or like so:`instanceOfProgram.copyWith.fieldName(...)`.
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
