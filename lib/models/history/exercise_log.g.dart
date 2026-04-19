// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetLogCWProxy {
  SetLog number(int number);

  SetLog weight(double weight);

  SetLog reps(int reps);

  SetLog restDuration(Duration restDuration);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SetLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SetLog(...).copyWith(id: 12, name: "My name")
  /// ```
  SetLog call({int number, double weight, int reps, Duration restDuration});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSetLog.copyWith(...)` or call `instanceOfSetLog.copyWith.fieldName(value)` for a single field.
class _$SetLogCWProxyImpl implements _$SetLogCWProxy {
  const _$SetLogCWProxyImpl(this._value);

  final SetLog _value;

  @override
  SetLog number(int number) => call(number: number);

  @override
  SetLog weight(double weight) => call(weight: weight);

  @override
  SetLog reps(int reps) => call(reps: reps);

  @override
  SetLog restDuration(Duration restDuration) =>
      call(restDuration: restDuration);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SetLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SetLog(...).copyWith(id: 12, name: "My name")
  /// ```
  SetLog call({
    Object? number = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? reps = const $CopyWithPlaceholder(),
    Object? restDuration = const $CopyWithPlaceholder(),
  }) {
    return SetLog(
      number: number == const $CopyWithPlaceholder() || number == null
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as int,
      weight: weight == const $CopyWithPlaceholder() || weight == null
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double,
      reps: reps == const $CopyWithPlaceholder() || reps == null
          ? _value.reps
          // ignore: cast_nullable_to_non_nullable
          : reps as int,
      restDuration:
          restDuration == const $CopyWithPlaceholder() || restDuration == null
          ? _value.restDuration
          // ignore: cast_nullable_to_non_nullable
          : restDuration as Duration,
    );
  }
}

extension $SetLogCopyWith on SetLog {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSetLog.copyWith(...)` or `instanceOfSetLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetLogCWProxy get copyWith => _$SetLogCWProxyImpl(this);
}

abstract class _$ClassicExerciseLogCWProxy {
  ClassicExerciseLog id(int id);

  ClassicExerciseLog sessionExerciseId(int sessionExerciseId);

  ClassicExerciseLog exerciseName(String exerciseName);

  ClassicExerciseLog orderInRoundLog(int orderInRoundLog);

  ClassicExerciseLog sets(List<SetLog> sets);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ClassicExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ClassicExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  ClassicExerciseLog call({
    int id,
    int sessionExerciseId,
    String exerciseName,
    int orderInRoundLog,
    List<SetLog> sets,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfClassicExerciseLog.copyWith(...)` or call `instanceOfClassicExerciseLog.copyWith.fieldName(value)` for a single field.
class _$ClassicExerciseLogCWProxyImpl implements _$ClassicExerciseLogCWProxy {
  const _$ClassicExerciseLogCWProxyImpl(this._value);

  final ClassicExerciseLog _value;

  @override
  ClassicExerciseLog id(int id) => call(id: id);

  @override
  ClassicExerciseLog sessionExerciseId(int sessionExerciseId) =>
      call(sessionExerciseId: sessionExerciseId);

  @override
  ClassicExerciseLog exerciseName(String exerciseName) =>
      call(exerciseName: exerciseName);

  @override
  ClassicExerciseLog orderInRoundLog(int orderInRoundLog) =>
      call(orderInRoundLog: orderInRoundLog);

  @override
  ClassicExerciseLog sets(List<SetLog> sets) => call(sets: sets);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ClassicExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ClassicExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  ClassicExerciseLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sessionExerciseId = const $CopyWithPlaceholder(),
    Object? exerciseName = const $CopyWithPlaceholder(),
    Object? orderInRoundLog = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
  }) {
    return ClassicExerciseLog(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      sessionExerciseId:
          sessionExerciseId == const $CopyWithPlaceholder() ||
              sessionExerciseId == null
          ? _value.sessionExerciseId
          // ignore: cast_nullable_to_non_nullable
          : sessionExerciseId as int,
      exerciseName:
          exerciseName == const $CopyWithPlaceholder() || exerciseName == null
          ? _value.exerciseName
          // ignore: cast_nullable_to_non_nullable
          : exerciseName as String,
      orderInRoundLog:
          orderInRoundLog == const $CopyWithPlaceholder() ||
              orderInRoundLog == null
          ? _value.orderInRoundLog
          // ignore: cast_nullable_to_non_nullable
          : orderInRoundLog as int,
      sets: sets == const $CopyWithPlaceholder() || sets == null
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<SetLog>,
    );
  }
}

extension $ClassicExerciseLogCopyWith on ClassicExerciseLog {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfClassicExerciseLog.copyWith(...)` or `instanceOfClassicExerciseLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ClassicExerciseLogCWProxy get copyWith =>
      _$ClassicExerciseLogCWProxyImpl(this);
}

abstract class _$AmrapExerciseLogCWProxy {
  AmrapExerciseLog id(int id);

  AmrapExerciseLog sessionExerciseId(int sessionExerciseId);

  AmrapExerciseLog exerciseName(String exerciseName);

  AmrapExerciseLog orderInRoundLog(int orderInRoundLog);

  AmrapExerciseLog repsNumber(int repsNumber);

  AmrapExerciseLog weight(double weight);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AmrapExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AmrapExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  AmrapExerciseLog call({
    int id,
    int sessionExerciseId,
    String exerciseName,
    int orderInRoundLog,
    int repsNumber,
    double weight,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAmrapExerciseLog.copyWith(...)` or call `instanceOfAmrapExerciseLog.copyWith.fieldName(value)` for a single field.
class _$AmrapExerciseLogCWProxyImpl implements _$AmrapExerciseLogCWProxy {
  const _$AmrapExerciseLogCWProxyImpl(this._value);

  final AmrapExerciseLog _value;

  @override
  AmrapExerciseLog id(int id) => call(id: id);

  @override
  AmrapExerciseLog sessionExerciseId(int sessionExerciseId) =>
      call(sessionExerciseId: sessionExerciseId);

  @override
  AmrapExerciseLog exerciseName(String exerciseName) =>
      call(exerciseName: exerciseName);

  @override
  AmrapExerciseLog orderInRoundLog(int orderInRoundLog) =>
      call(orderInRoundLog: orderInRoundLog);

  @override
  AmrapExerciseLog repsNumber(int repsNumber) => call(repsNumber: repsNumber);

  @override
  AmrapExerciseLog weight(double weight) => call(weight: weight);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AmrapExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AmrapExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  AmrapExerciseLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sessionExerciseId = const $CopyWithPlaceholder(),
    Object? exerciseName = const $CopyWithPlaceholder(),
    Object? orderInRoundLog = const $CopyWithPlaceholder(),
    Object? repsNumber = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
  }) {
    return AmrapExerciseLog(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      sessionExerciseId:
          sessionExerciseId == const $CopyWithPlaceholder() ||
              sessionExerciseId == null
          ? _value.sessionExerciseId
          // ignore: cast_nullable_to_non_nullable
          : sessionExerciseId as int,
      exerciseName:
          exerciseName == const $CopyWithPlaceholder() || exerciseName == null
          ? _value.exerciseName
          // ignore: cast_nullable_to_non_nullable
          : exerciseName as String,
      orderInRoundLog:
          orderInRoundLog == const $CopyWithPlaceholder() ||
              orderInRoundLog == null
          ? _value.orderInRoundLog
          // ignore: cast_nullable_to_non_nullable
          : orderInRoundLog as int,
      repsNumber:
          repsNumber == const $CopyWithPlaceholder() || repsNumber == null
          ? _value.repsNumber
          // ignore: cast_nullable_to_non_nullable
          : repsNumber as int,
      weight: weight == const $CopyWithPlaceholder() || weight == null
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double,
    );
  }
}

extension $AmrapExerciseLogCopyWith on AmrapExerciseLog {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAmrapExerciseLog.copyWith(...)` or `instanceOfAmrapExerciseLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AmrapExerciseLogCWProxy get copyWith => _$AmrapExerciseLogCWProxyImpl(this);
}

abstract class _$EmomExerciseLogCWProxy {
  EmomExerciseLog id(int id);

  EmomExerciseLog sessionExerciseId(int sessionExerciseId);

  EmomExerciseLog exerciseName(String exerciseName);

  EmomExerciseLog orderInRoundLog(int orderInRoundLog);

  EmomExerciseLog duration(Duration duration);

  EmomExerciseLog repsNumber(int repsNumber);

  EmomExerciseLog weight(double weight);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EmomExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EmomExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  EmomExerciseLog call({
    int id,
    int sessionExerciseId,
    String exerciseName,
    int orderInRoundLog,
    Duration duration,
    int repsNumber,
    double weight,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEmomExerciseLog.copyWith(...)` or call `instanceOfEmomExerciseLog.copyWith.fieldName(value)` for a single field.
class _$EmomExerciseLogCWProxyImpl implements _$EmomExerciseLogCWProxy {
  const _$EmomExerciseLogCWProxyImpl(this._value);

  final EmomExerciseLog _value;

  @override
  EmomExerciseLog id(int id) => call(id: id);

  @override
  EmomExerciseLog sessionExerciseId(int sessionExerciseId) =>
      call(sessionExerciseId: sessionExerciseId);

  @override
  EmomExerciseLog exerciseName(String exerciseName) =>
      call(exerciseName: exerciseName);

  @override
  EmomExerciseLog orderInRoundLog(int orderInRoundLog) =>
      call(orderInRoundLog: orderInRoundLog);

  @override
  EmomExerciseLog duration(Duration duration) => call(duration: duration);

  @override
  EmomExerciseLog repsNumber(int repsNumber) => call(repsNumber: repsNumber);

  @override
  EmomExerciseLog weight(double weight) => call(weight: weight);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EmomExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EmomExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  EmomExerciseLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sessionExerciseId = const $CopyWithPlaceholder(),
    Object? exerciseName = const $CopyWithPlaceholder(),
    Object? orderInRoundLog = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? repsNumber = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
  }) {
    return EmomExerciseLog(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      sessionExerciseId:
          sessionExerciseId == const $CopyWithPlaceholder() ||
              sessionExerciseId == null
          ? _value.sessionExerciseId
          // ignore: cast_nullable_to_non_nullable
          : sessionExerciseId as int,
      exerciseName:
          exerciseName == const $CopyWithPlaceholder() || exerciseName == null
          ? _value.exerciseName
          // ignore: cast_nullable_to_non_nullable
          : exerciseName as String,
      orderInRoundLog:
          orderInRoundLog == const $CopyWithPlaceholder() ||
              orderInRoundLog == null
          ? _value.orderInRoundLog
          // ignore: cast_nullable_to_non_nullable
          : orderInRoundLog as int,
      duration: duration == const $CopyWithPlaceholder() || duration == null
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as Duration,
      repsNumber:
          repsNumber == const $CopyWithPlaceholder() || repsNumber == null
          ? _value.repsNumber
          // ignore: cast_nullable_to_non_nullable
          : repsNumber as int,
      weight: weight == const $CopyWithPlaceholder() || weight == null
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double,
    );
  }
}

extension $EmomExerciseLogCopyWith on EmomExerciseLog {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEmomExerciseLog.copyWith(...)` or `instanceOfEmomExerciseLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EmomExerciseLogCWProxy get copyWith => _$EmomExerciseLogCWProxyImpl(this);
}

abstract class _$HiitExerciseLogCWProxy {
  HiitExerciseLog id(int id);

  HiitExerciseLog sessionExerciseId(int sessionExerciseId);

  HiitExerciseLog exerciseName(String exerciseName);

  HiitExerciseLog orderInRoundLog(int orderInRoundLog);

  HiitExerciseLog effortDuration(Duration effortDuration);

  HiitExerciseLog restDuration(Duration restDuration);

  HiitExerciseLog weight(double weight);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HiitExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HiitExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  HiitExerciseLog call({
    int id,
    int sessionExerciseId,
    String exerciseName,
    int orderInRoundLog,
    Duration effortDuration,
    Duration restDuration,
    double weight,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHiitExerciseLog.copyWith(...)` or call `instanceOfHiitExerciseLog.copyWith.fieldName(value)` for a single field.
class _$HiitExerciseLogCWProxyImpl implements _$HiitExerciseLogCWProxy {
  const _$HiitExerciseLogCWProxyImpl(this._value);

  final HiitExerciseLog _value;

  @override
  HiitExerciseLog id(int id) => call(id: id);

  @override
  HiitExerciseLog sessionExerciseId(int sessionExerciseId) =>
      call(sessionExerciseId: sessionExerciseId);

  @override
  HiitExerciseLog exerciseName(String exerciseName) =>
      call(exerciseName: exerciseName);

  @override
  HiitExerciseLog orderInRoundLog(int orderInRoundLog) =>
      call(orderInRoundLog: orderInRoundLog);

  @override
  HiitExerciseLog effortDuration(Duration effortDuration) =>
      call(effortDuration: effortDuration);

  @override
  HiitExerciseLog restDuration(Duration restDuration) =>
      call(restDuration: restDuration);

  @override
  HiitExerciseLog weight(double weight) => call(weight: weight);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HiitExerciseLog(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HiitExerciseLog(...).copyWith(id: 12, name: "My name")
  /// ```
  HiitExerciseLog call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sessionExerciseId = const $CopyWithPlaceholder(),
    Object? exerciseName = const $CopyWithPlaceholder(),
    Object? orderInRoundLog = const $CopyWithPlaceholder(),
    Object? effortDuration = const $CopyWithPlaceholder(),
    Object? restDuration = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
  }) {
    return HiitExerciseLog(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      sessionExerciseId:
          sessionExerciseId == const $CopyWithPlaceholder() ||
              sessionExerciseId == null
          ? _value.sessionExerciseId
          // ignore: cast_nullable_to_non_nullable
          : sessionExerciseId as int,
      exerciseName:
          exerciseName == const $CopyWithPlaceholder() || exerciseName == null
          ? _value.exerciseName
          // ignore: cast_nullable_to_non_nullable
          : exerciseName as String,
      orderInRoundLog:
          orderInRoundLog == const $CopyWithPlaceholder() ||
              orderInRoundLog == null
          ? _value.orderInRoundLog
          // ignore: cast_nullable_to_non_nullable
          : orderInRoundLog as int,
      effortDuration:
          effortDuration == const $CopyWithPlaceholder() ||
              effortDuration == null
          ? _value.effortDuration
          // ignore: cast_nullable_to_non_nullable
          : effortDuration as Duration,
      restDuration:
          restDuration == const $CopyWithPlaceholder() || restDuration == null
          ? _value.restDuration
          // ignore: cast_nullable_to_non_nullable
          : restDuration as Duration,
      weight: weight == const $CopyWithPlaceholder() || weight == null
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double,
    );
  }
}

extension $HiitExerciseLogCopyWith on HiitExerciseLog {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHiitExerciseLog.copyWith(...)` or `instanceOfHiitExerciseLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HiitExerciseLogCWProxy get copyWith => _$HiitExerciseLogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLog _$SetLogFromJson(Map<String, dynamic> json) => SetLog(
  number: (json['number'] as num).toInt(),
  weight: (json['weight'] as num).toDouble(),
  reps: (json['reps'] as num).toInt(),
  restDuration: const DurationConverter().fromJson(
    (json['rest_duration'] as num).toInt(),
  ),
);

Map<String, dynamic> _$SetLogToJson(SetLog instance) => <String, dynamic>{
  'number': instance.number,
  'weight': instance.weight,
  'reps': instance.reps,
  'rest_duration': const DurationConverter().toJson(instance.restDuration),
};

ClassicExerciseLog _$ClassicExerciseLogFromJson(Map<String, dynamic> json) =>
    ClassicExerciseLog(
      id: (json['id'] as num).toInt(),
      sessionExerciseId: (json['session_exercise_id'] as num).toInt(),
      exerciseName: json['exercise_name'] as String,
      orderInRoundLog: (json['order_in_round_log'] as num).toInt(),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassicExerciseLogToJson(ClassicExerciseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_exercise_id': instance.sessionExerciseId,
      'exercise_name': instance.exerciseName,
      'order_in_round_log': instance.orderInRoundLog,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
    };

AmrapExerciseLog _$AmrapExerciseLogFromJson(Map<String, dynamic> json) =>
    AmrapExerciseLog(
      id: (json['id'] as num).toInt(),
      sessionExerciseId: (json['session_exercise_id'] as num).toInt(),
      exerciseName: json['exercise_name'] as String,
      orderInRoundLog: (json['order_in_round_log'] as num).toInt(),
      repsNumber: (json['reps_number'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$AmrapExerciseLogToJson(AmrapExerciseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_exercise_id': instance.sessionExerciseId,
      'exercise_name': instance.exerciseName,
      'order_in_round_log': instance.orderInRoundLog,
      'reps_number': instance.repsNumber,
      'weight': instance.weight,
    };

EmomExerciseLog _$EmomExerciseLogFromJson(Map<String, dynamic> json) =>
    EmomExerciseLog(
      id: (json['id'] as num).toInt(),
      sessionExerciseId: (json['session_exercise_id'] as num).toInt(),
      exerciseName: json['exercise_name'] as String,
      orderInRoundLog: (json['order_in_round_log'] as num).toInt(),
      duration: const DurationConverter().fromJson(
        (json['duration'] as num).toInt(),
      ),
      repsNumber: (json['reps_number'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$EmomExerciseLogToJson(EmomExerciseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_exercise_id': instance.sessionExerciseId,
      'exercise_name': instance.exerciseName,
      'order_in_round_log': instance.orderInRoundLog,
      'duration': const DurationConverter().toJson(instance.duration),
      'reps_number': instance.repsNumber,
      'weight': instance.weight,
    };

HiitExerciseLog _$HiitExerciseLogFromJson(Map<String, dynamic> json) =>
    HiitExerciseLog(
      id: (json['id'] as num).toInt(),
      sessionExerciseId: (json['session_exercise_id'] as num).toInt(),
      exerciseName: json['exercise_name'] as String,
      orderInRoundLog: (json['order_in_round_log'] as num).toInt(),
      effortDuration: const DurationConverter().fromJson(
        (json['effort_duration'] as num).toInt(),
      ),
      restDuration: const DurationConverter().fromJson(
        (json['rest_duration'] as num).toInt(),
      ),
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$HiitExerciseLogToJson(
  HiitExerciseLog instance,
) => <String, dynamic>{
  'id': instance.id,
  'session_exercise_id': instance.sessionExerciseId,
  'exercise_name': instance.exerciseName,
  'order_in_round_log': instance.orderInRoundLog,
  'effort_duration': const DurationConverter().toJson(instance.effortDuration),
  'rest_duration': const DurationConverter().toJson(instance.restDuration),
  'weight': instance.weight,
};
