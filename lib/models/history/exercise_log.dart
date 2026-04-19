import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/training/converters/duration_converter.dart';
import 'package:trainer_backend/models/training/enums/session_type.dart';

part 'exercise_log.g.dart';

/// Represents a single set performed within a [ClassicExerciseLog].
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class SetLog {
  /// Creates an instance of [SetLog].
  const SetLog({
    required this.number,
    required this.weight,
    required this.reps,
    required this.restDuration,
  });

  /// Creates a [SetLog] from a JSON object.
  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);

  /// Converts this [SetLog] to a JSON object.
  Map<String, dynamic> toJson() => _$SetLogToJson(this);

  /// The order number of the set within the exercise (e.g., 1, 2, 3).
  final int number;

  /// The weight used for the set, in kilograms.
  final double weight;

  /// The number of repetitions performed in the set.
  final int reps;

  /// The duration of rest after the set.
  @DurationConverter()
  final Duration restDuration;
}

/// A sealed class representing a log for a single exercise performance.
///
/// This serves as a base class for different types of exercise logs,
/// corresponding to the different [SessionType] values. It uses a factory
/// constructor to deserialize the correct subclass from JSON.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  createToJson: false,
)
sealed class ExerciseLog {
  /// Creates an instance of [ExerciseLog].
  const ExerciseLog({
    required this.id,
    required this.sessionExerciseId,
    required this.exerciseName,
    required this.orderInRoundLog,
  });

  /// A factory for creating an [ExerciseLog] instance from a JSON object.
  ///
  /// It determines the concrete type of the log based on the `type` field
  /// in the JSON and delegates deserialization to the appropriate subclass.
  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    switch (SessionType.fromJson(type)) {
      case SessionType.classic:
        return ClassicExerciseLog.fromJson(json);
      case SessionType.amrap:
        return AmrapExerciseLog.fromJson(json);
      case SessionType.emom:
        return EmomExerciseLog.fromJson(json);
      case SessionType.hiit:
        return HiitExerciseLog.fromJson(json);
    }
  }

  /// The unique identifier for this specific exercise log entry.
  final int id;

  /// The ID of the parent [SessionExercise] this log is associated with.
  final int sessionExerciseId;

  /// The name of the exercise, fetched from the database.
  final String exerciseName;

  /// The order of this exercise within the round.
  final int orderInRoundLog;

  /// Converts this [ExerciseLog] to a JSON object.
  ///
  /// This method must be implemented by all subclasses.
  Map<String, dynamic> toJson();
}

/// A log for a 'Classic' style exercise, composed of multiple sets.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class ClassicExerciseLog extends ExerciseLog {
  /// Creates an instance of [ClassicExerciseLog].
  const ClassicExerciseLog({
    required super.id,
    required super.sessionExerciseId,
    required super.exerciseName,
    required super.orderInRoundLog,
    required this.sets,
  });

  /// A factory for creating a [ClassicExerciseLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0. The [exerciseName] is empty as it's
  /// added by the backend during fetch operations.
  factory ClassicExerciseLog.forCreation({
    required int sessionExerciseId,
    required int orderInRoundLog,
    required List<SetLog> sets,
  }) => ClassicExerciseLog(
    id: 0,
    sessionExerciseId: sessionExerciseId,
    exerciseName: '', // Name is added during fetch, not creation
    orderInRoundLog: orderInRoundLog,
    sets: sets,
  );

  /// Creates a [ClassicExerciseLog] from a JSON object.
  factory ClassicExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ClassicExerciseLogFromJson(json);

  /// The list of sets performed for this exercise.
  final List<SetLog> sets;

  @override
  Map<String, dynamic> toJson() => _$ClassicExerciseLogToJson(this);
}

/// A log for an 'AMRAP' style exercise performance.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class AmrapExerciseLog extends ExerciseLog {
  /// Creates an instance of [AmrapExerciseLog].
  const AmrapExerciseLog({
    required super.id,
    required super.sessionExerciseId,
    required super.exerciseName,
    required super.orderInRoundLog,
    required this.repsNumber,
    required this.weight,
  });

  /// A factory for creating an [AmrapExerciseLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0. The [exerciseName] is empty as it's
  /// added by the backend during fetch operations.
  factory AmrapExerciseLog.forCreation({
    required int sessionExerciseId,
    required int orderInRoundLog,
    required int repsNumber,
    required double weight,
  }) => AmrapExerciseLog(
    id: 0,
    sessionExerciseId: sessionExerciseId,
    exerciseName: '', // Name is added during fetch, not creation
    orderInRoundLog: orderInRoundLog,
    repsNumber: repsNumber,
    weight: weight,
  );

  /// Creates an [AmrapExerciseLog] from a JSON object.
  factory AmrapExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$AmrapExerciseLogFromJson(json);

  /// The number of repetitions performed.
  final int repsNumber;

  /// The weight used, in kilograms.
  final double weight;

  @override
  Map<String, dynamic> toJson() => _$AmrapExerciseLogToJson(this);
}

/// A log for an 'EMOM' style exercise performance.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class EmomExerciseLog extends ExerciseLog {
  /// Creates an instance of [EmomExerciseLog].
  const EmomExerciseLog({
    required super.id,
    required super.sessionExerciseId,
    required super.exerciseName,
    required super.orderInRoundLog,
    required this.duration,
    required this.repsNumber,
    required this.weight,
  });

  /// A factory for creating an [EmomExerciseLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0. The [exerciseName] is empty as it's
  /// added by the backend during fetch operations.
  factory EmomExerciseLog.forCreation({
    required int sessionExerciseId,
    required int orderInRoundLog,
    required Duration duration,
    required int repsNumber,
    required double weight,
  }) => EmomExerciseLog(
    id: 0,
    sessionExerciseId: sessionExerciseId,
    exerciseName: '', // Name is added during fetch, not creation
    orderInRoundLog: orderInRoundLog,
    duration: duration,
    repsNumber: repsNumber,
    weight: weight,
  );

  /// Creates an [EmomExerciseLog] from a JSON object.
  factory EmomExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$EmomExerciseLogFromJson(json);

  /// The duration of the performance.
  @DurationConverter()
  final Duration duration;

  /// The number of repetitions performed.
  final int repsNumber;

  /// The weight used, in kilograms.
  final double weight;

  @override
  Map<String, dynamic> toJson() => _$EmomExerciseLogToJson(this);
}

/// A log for a 'HIIT' style exercise performance.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class HiitExerciseLog extends ExerciseLog {
  /// Creates an instance of [HiitExerciseLog].
  const HiitExerciseLog({
    required super.id,
    required super.sessionExerciseId,
    required super.exerciseName,
    required super.orderInRoundLog,
    required this.effortDuration,
    required this.restDuration,
    required this.weight,
  });

  /// A factory for creating a [HiitExerciseLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0. The [exerciseName] is empty as it's
  /// added by the backend during fetch operations.
  factory HiitExerciseLog.forCreation({
    required int sessionExerciseId,
    required int orderInRoundLog,
    required Duration effortDuration,
    required Duration restDuration,
    required double weight,
  }) => HiitExerciseLog(
    id: 0,
    sessionExerciseId: sessionExerciseId,
    exerciseName: '', // Name is added during fetch, not creation
    orderInRoundLog: orderInRoundLog,
    effortDuration: effortDuration,
    restDuration: restDuration,
    weight: weight,
  );

  /// Creates a [HiitExerciseLog] from a JSON object.
  factory HiitExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$HiitExerciseLogFromJson(json);

  /// The duration of the high-intensity effort.
  @DurationConverter()
  final Duration effortDuration;

  /// The duration of the rest period.
  @DurationConverter()
  final Duration restDuration;

  /// The weight used, in kilograms.
  final double weight;

  @override
  Map<String, dynamic> toJson() => _$HiitExerciseLogToJson(this);
}
