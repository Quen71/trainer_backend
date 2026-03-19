// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProfileCWProxy {
  Profile id(String id);

  Profile username(String username);

  Profile createdAt(DateTime createdAt);

  Profile updatedAt(DateTime updatedAt);

  Profile fullName(String? fullName);

  Profile role(UserRole role);

  Profile programs(List<Program> programs);

  Profile sessionLogs(List<SessionLog> sessionLogs);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Profile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ```
  Profile call({
    String id,
    String username,
    DateTime createdAt,
    DateTime updatedAt,
    String? fullName,
    UserRole role,
    List<Program> programs,
    List<SessionLog> sessionLogs,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProfile.copyWith(...)` or call `instanceOfProfile.copyWith.fieldName(value)` for a single field.
class _$ProfileCWProxyImpl implements _$ProfileCWProxy {
  const _$ProfileCWProxyImpl(this._value);

  final Profile _value;

  @override
  Profile id(String id) => call(id: id);

  @override
  Profile username(String username) => call(username: username);

  @override
  Profile createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  Profile updatedAt(DateTime updatedAt) => call(updatedAt: updatedAt);

  @override
  Profile fullName(String? fullName) => call(fullName: fullName);

  @override
  Profile role(UserRole role) => call(role: role);

  @override
  Profile programs(List<Program> programs) => call(programs: programs);

  @override
  Profile sessionLogs(List<SessionLog> sessionLogs) =>
      call(sessionLogs: sessionLogs);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Profile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ```
  Profile call({
    Object? id = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? fullName = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? programs = const $CopyWithPlaceholder(),
    Object? sessionLogs = const $CopyWithPlaceholder(),
  }) {
    return Profile(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      username: username == const $CopyWithPlaceholder() || username == null
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      fullName: fullName == const $CopyWithPlaceholder()
          ? _value.fullName
          // ignore: cast_nullable_to_non_nullable
          : fullName as String?,
      role: role == const $CopyWithPlaceholder() || role == null
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as UserRole,
      programs: programs == const $CopyWithPlaceholder() || programs == null
          ? _value.programs
          // ignore: cast_nullable_to_non_nullable
          : programs as List<Program>,
      sessionLogs:
          sessionLogs == const $CopyWithPlaceholder() || sessionLogs == null
              ? _value.sessionLogs
              // ignore: cast_nullable_to_non_nullable
              : sessionLogs as List<SessionLog>,
    );
  }
}

extension $ProfileCopyWith on Profile {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProfile.copyWith(...)` or `instanceOfProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProfileCWProxy get copyWith => _$ProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      fullName: json['full_name'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.standard,
      programs: (json['programs'] as List<dynamic>?)
              ?.map((e) => Program.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Program>[],
      sessionLogs: (json['session_logs'] as List<dynamic>?)
              ?.map((e) => SessionLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SessionLog>[],
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'full_name': instance.fullName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'programs': instance.programs,
      'session_logs': instance.sessionLogs,
    };

const _$UserRoleEnumMap = {
  UserRole.standard: 'standard',
  UserRole.coach: 'coach',
};
