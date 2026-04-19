// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ClassicSessionCWProxy {
  ClassicSession id(int id);

  ClassicSession name(String name);

  ClassicSession orderInProgram(int orderInProgram);

  ClassicSession style(SessionStyle style);

  ClassicSession exercises(List<ClassicExercise> exercises);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ClassicSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ClassicSession(...).copyWith(id: 12, name: "My name")
  /// ```
  ClassicSession call({
    int id,
    String name,
    int orderInProgram,
    SessionStyle style,
    List<ClassicExercise> exercises,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfClassicSession.copyWith(...)` or call `instanceOfClassicSession.copyWith.fieldName(value)` for a single field.
class _$ClassicSessionCWProxyImpl implements _$ClassicSessionCWProxy {
  const _$ClassicSessionCWProxyImpl(this._value);

  final ClassicSession _value;

  @override
  ClassicSession id(int id) => call(id: id);

  @override
  ClassicSession name(String name) => call(name: name);

  @override
  ClassicSession orderInProgram(int orderInProgram) =>
      call(orderInProgram: orderInProgram);

  @override
  ClassicSession style(SessionStyle style) => call(style: style);

  @override
  ClassicSession exercises(List<ClassicExercise> exercises) =>
      call(exercises: exercises);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ClassicSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ClassicSession(...).copyWith(id: 12, name: "My name")
  /// ```
  ClassicSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? orderInProgram = const $CopyWithPlaceholder(),
    Object? style = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return ClassicSession(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      orderInProgram:
          orderInProgram == const $CopyWithPlaceholder() ||
              orderInProgram == null
          ? _value.orderInProgram
          // ignore: cast_nullable_to_non_nullable
          : orderInProgram as int,
      style: style == const $CopyWithPlaceholder() || style == null
          ? _value.style
          // ignore: cast_nullable_to_non_nullable
          : style as SessionStyle,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<ClassicExercise>,
    );
  }
}

extension $ClassicSessionCopyWith on ClassicSession {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfClassicSession.copyWith(...)` or `instanceOfClassicSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ClassicSessionCWProxy get copyWith => _$ClassicSessionCWProxyImpl(this);
}

abstract class _$AmrapSessionCWProxy {
  AmrapSession id(int id);

  AmrapSession name(String name);

  AmrapSession orderInProgram(int orderInProgram);

  AmrapSession style(SessionStyle style);

  AmrapSession exercises(List<AmrapExercise> exercises);

  AmrapSession duration(Duration duration);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AmrapSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AmrapSession(...).copyWith(id: 12, name: "My name")
  /// ```
  AmrapSession call({
    int id,
    String name,
    int orderInProgram,
    SessionStyle style,
    List<AmrapExercise> exercises,
    Duration duration,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAmrapSession.copyWith(...)` or call `instanceOfAmrapSession.copyWith.fieldName(value)` for a single field.
class _$AmrapSessionCWProxyImpl implements _$AmrapSessionCWProxy {
  const _$AmrapSessionCWProxyImpl(this._value);

  final AmrapSession _value;

  @override
  AmrapSession id(int id) => call(id: id);

  @override
  AmrapSession name(String name) => call(name: name);

  @override
  AmrapSession orderInProgram(int orderInProgram) =>
      call(orderInProgram: orderInProgram);

  @override
  AmrapSession style(SessionStyle style) => call(style: style);

  @override
  AmrapSession exercises(List<AmrapExercise> exercises) =>
      call(exercises: exercises);

  @override
  AmrapSession duration(Duration duration) => call(duration: duration);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AmrapSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AmrapSession(...).copyWith(id: 12, name: "My name")
  /// ```
  AmrapSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? orderInProgram = const $CopyWithPlaceholder(),
    Object? style = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
  }) {
    return AmrapSession(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      orderInProgram:
          orderInProgram == const $CopyWithPlaceholder() ||
              orderInProgram == null
          ? _value.orderInProgram
          // ignore: cast_nullable_to_non_nullable
          : orderInProgram as int,
      style: style == const $CopyWithPlaceholder() || style == null
          ? _value.style
          // ignore: cast_nullable_to_non_nullable
          : style as SessionStyle,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<AmrapExercise>,
      duration: duration == const $CopyWithPlaceholder() || duration == null
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as Duration,
    );
  }
}

extension $AmrapSessionCopyWith on AmrapSession {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAmrapSession.copyWith(...)` or `instanceOfAmrapSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AmrapSessionCWProxy get copyWith => _$AmrapSessionCWProxyImpl(this);
}

abstract class _$EmomSessionCWProxy {
  EmomSession id(int id);

  EmomSession name(String name);

  EmomSession orderInProgram(int orderInProgram);

  EmomSession style(SessionStyle style);

  EmomSession exercises(List<EmomExercise> exercises);

  EmomSession roundNumber(int roundNumber);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EmomSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EmomSession(...).copyWith(id: 12, name: "My name")
  /// ```
  EmomSession call({
    int id,
    String name,
    int orderInProgram,
    SessionStyle style,
    List<EmomExercise> exercises,
    int roundNumber,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEmomSession.copyWith(...)` or call `instanceOfEmomSession.copyWith.fieldName(value)` for a single field.
class _$EmomSessionCWProxyImpl implements _$EmomSessionCWProxy {
  const _$EmomSessionCWProxyImpl(this._value);

  final EmomSession _value;

  @override
  EmomSession id(int id) => call(id: id);

  @override
  EmomSession name(String name) => call(name: name);

  @override
  EmomSession orderInProgram(int orderInProgram) =>
      call(orderInProgram: orderInProgram);

  @override
  EmomSession style(SessionStyle style) => call(style: style);

  @override
  EmomSession exercises(List<EmomExercise> exercises) =>
      call(exercises: exercises);

  @override
  EmomSession roundNumber(int roundNumber) => call(roundNumber: roundNumber);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EmomSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EmomSession(...).copyWith(id: 12, name: "My name")
  /// ```
  EmomSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? orderInProgram = const $CopyWithPlaceholder(),
    Object? style = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? roundNumber = const $CopyWithPlaceholder(),
  }) {
    return EmomSession(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      orderInProgram:
          orderInProgram == const $CopyWithPlaceholder() ||
              orderInProgram == null
          ? _value.orderInProgram
          // ignore: cast_nullable_to_non_nullable
          : orderInProgram as int,
      style: style == const $CopyWithPlaceholder() || style == null
          ? _value.style
          // ignore: cast_nullable_to_non_nullable
          : style as SessionStyle,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<EmomExercise>,
      roundNumber:
          roundNumber == const $CopyWithPlaceholder() || roundNumber == null
          ? _value.roundNumber
          // ignore: cast_nullable_to_non_nullable
          : roundNumber as int,
    );
  }
}

extension $EmomSessionCopyWith on EmomSession {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEmomSession.copyWith(...)` or `instanceOfEmomSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EmomSessionCWProxy get copyWith => _$EmomSessionCWProxyImpl(this);
}

abstract class _$HiitSessionCWProxy {
  HiitSession id(int id);

  HiitSession name(String name);

  HiitSession orderInProgram(int orderInProgram);

  HiitSession style(SessionStyle style);

  HiitSession exercises(List<HiitExercise> exercises);

  HiitSession roundNumber(int roundNumber);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HiitSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HiitSession(...).copyWith(id: 12, name: "My name")
  /// ```
  HiitSession call({
    int id,
    String name,
    int orderInProgram,
    SessionStyle style,
    List<HiitExercise> exercises,
    int roundNumber,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHiitSession.copyWith(...)` or call `instanceOfHiitSession.copyWith.fieldName(value)` for a single field.
class _$HiitSessionCWProxyImpl implements _$HiitSessionCWProxy {
  const _$HiitSessionCWProxyImpl(this._value);

  final HiitSession _value;

  @override
  HiitSession id(int id) => call(id: id);

  @override
  HiitSession name(String name) => call(name: name);

  @override
  HiitSession orderInProgram(int orderInProgram) =>
      call(orderInProgram: orderInProgram);

  @override
  HiitSession style(SessionStyle style) => call(style: style);

  @override
  HiitSession exercises(List<HiitExercise> exercises) =>
      call(exercises: exercises);

  @override
  HiitSession roundNumber(int roundNumber) => call(roundNumber: roundNumber);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HiitSession(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HiitSession(...).copyWith(id: 12, name: "My name")
  /// ```
  HiitSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? orderInProgram = const $CopyWithPlaceholder(),
    Object? style = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? roundNumber = const $CopyWithPlaceholder(),
  }) {
    return HiitSession(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      orderInProgram:
          orderInProgram == const $CopyWithPlaceholder() ||
              orderInProgram == null
          ? _value.orderInProgram
          // ignore: cast_nullable_to_non_nullable
          : orderInProgram as int,
      style: style == const $CopyWithPlaceholder() || style == null
          ? _value.style
          // ignore: cast_nullable_to_non_nullable
          : style as SessionStyle,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<HiitExercise>,
      roundNumber:
          roundNumber == const $CopyWithPlaceholder() || roundNumber == null
          ? _value.roundNumber
          // ignore: cast_nullable_to_non_nullable
          : roundNumber as int,
    );
  }
}

extension $HiitSessionCopyWith on HiitSession {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHiitSession.copyWith(...)` or `instanceOfHiitSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HiitSessionCWProxy get copyWith => _$HiitSessionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassicSession _$ClassicSessionFromJson(Map<String, dynamic> json) =>
    ClassicSession(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      orderInProgram: (json['order_in_program'] as num).toInt(),
      style: $enumDecode(_$SessionStyleEnumMap, json['style']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ClassicExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassicSessionToJson(ClassicSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order_in_program': instance.orderInProgram,
      'style': instance.style.toJson(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

const _$SessionStyleEnumMap = {
  SessionStyle.bodyweight: 'bodyweight',
  SessionStyle.weights: 'weights',
  SessionStyle.stretchingMobility: 'stretchingMobility',
};

AmrapSession _$AmrapSessionFromJson(Map<String, dynamic> json) => AmrapSession(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  orderInProgram: (json['order_in_program'] as num).toInt(),
  style: $enumDecode(_$SessionStyleEnumMap, json['style']),
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => AmrapExercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  duration: const DurationConverter().fromJson(
    (json['duration'] as num).toInt(),
  ),
);

Map<String, dynamic> _$AmrapSessionToJson(AmrapSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order_in_program': instance.orderInProgram,
      'style': instance.style.toJson(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'duration': const DurationConverter().toJson(instance.duration),
    };

EmomSession _$EmomSessionFromJson(Map<String, dynamic> json) => EmomSession(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  orderInProgram: (json['order_in_program'] as num).toInt(),
  style: $enumDecode(_$SessionStyleEnumMap, json['style']),
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => EmomExercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  roundNumber: (json['round_number'] as num).toInt(),
);

Map<String, dynamic> _$EmomSessionToJson(EmomSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order_in_program': instance.orderInProgram,
      'style': instance.style.toJson(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'round_number': instance.roundNumber,
    };

HiitSession _$HiitSessionFromJson(Map<String, dynamic> json) => HiitSession(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  orderInProgram: (json['order_in_program'] as num).toInt(),
  style: $enumDecode(_$SessionStyleEnumMap, json['style']),
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => HiitExercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  roundNumber: (json['round_number'] as num).toInt(),
);

Map<String, dynamic> _$HiitSessionToJson(HiitSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order_in_program': instance.orderInProgram,
      'style': instance.style.toJson(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'round_number': instance.roundNumber,
    };
