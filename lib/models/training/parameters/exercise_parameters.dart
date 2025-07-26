import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/training/converters/duration_converter.dart';

part 'exercise_parameters.g.dart';

// --- Exercise Parameters ---

/// Represents a single set within a 'Classic' style exercise.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class ClassicExerciseSet {
  /// Creates an instance of [ClassicExerciseSet].
  const ClassicExerciseSet({
    required this.orderInExercise,
    required this.repsNumber,
    required this.weight,
    required this.restDuration,
  });

  /// Creates a [ClassicExerciseSet] from a JSON object.
  factory ClassicExerciseSet.fromJson(Map<String, dynamic> json) => _$ClassicExerciseSetFromJson(json);

  /// Converts this [ClassicExerciseSet] to a JSON object.
  Map<String, dynamic> toJson() => _$ClassicExerciseSetToJson(this);

  /// The order of this set within the exercise.
  final int orderInExercise;

  /// The target number of repetitions for this set.
  final int repsNumber;

  /// The target weight for this set, in kilograms.
  final double weight;

  /// The prescribed rest duration after this set.
  @DurationConverter()
  final Duration restDuration;
}

/// Defines the parameters for a 'Classic' style exercise.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class ClassicExerciseParameters {
  /// Creates an instance of [ClassicExerciseParameters].
  const ClassicExerciseParameters({
    required this.sets,
  });

  /// Creates a [ClassicExerciseParameters] from a JSON object.
  factory ClassicExerciseParameters.fromJson(Map<String, dynamic> json) => _$ClassicExerciseParametersFromJson(json);

  /// The list of sets that define the exercise structure.
  final List<ClassicExerciseSet> sets;

  /// Converts this [ClassicExerciseParameters] to a JSON object.
  Map<String, dynamic> toJson() => _$ClassicExerciseParametersToJson(this);
}

/// Defines the parameters for an 'AMRAP' style exercise.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class AmrapExerciseParameters {
  /// Creates an instance of [AmrapExerciseParameters].
  const AmrapExerciseParameters({
    required this.repsNumber,
    required this.weight,
  });

  /// Creates an [AmrapExerciseParameters] from a JSON object.
  factory AmrapExerciseParameters.fromJson(Map<String, dynamic> json) => _$AmrapExerciseParametersFromJson(json);

  /// The target number of repetitions for each round.
  final int repsNumber;

  /// The target weight for each round, in kilograms.
  final double weight;

  /// Converts this [AmrapExerciseParameters] to a JSON object.
  Map<String, dynamic> toJson() => _$AmrapExerciseParametersToJson(this);
}

/// Defines the parameters for an 'EMOM' style exercise.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class EmomExerciseParameters {
  /// Creates an instance of [EmomExerciseParameters].
  const EmomExerciseParameters({
    required this.duration,
    required this.repsNumber,
    required this.weight,
  });

  /// Creates an [EmomExerciseParameters] from a JSON object.
  factory EmomExerciseParameters.fromJson(Map<String, dynamic> json) => _$EmomExerciseParametersFromJson(json);

  /// The duration of each minute's work interval.
  @DurationConverter()
  final Duration duration;

  /// The target number of repetitions within the interval.
  final int repsNumber;

  /// The target weight for the exercise, in kilograms.
  final double weight;

  /// Converts this [EmomExerciseParameters] to a JSON object.
  Map<String, dynamic> toJson() => _$EmomExerciseParametersToJson(this);
}

/// Defines the parameters for a 'HIIT' style exercise.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class HiitExerciseParameters {
  /// Creates an instance of [HiitExerciseParameters].
  const HiitExerciseParameters({
    required this.effortDuration,
    required this.restDuration,
    required this.weight,
  });

  /// Creates a [HiitExerciseParameters] from a JSON object.
  factory HiitExerciseParameters.fromJson(Map<String, dynamic> json) => _$HiitExerciseParametersFromJson(json);

  /// The duration of the high-intensity effort interval.
  @DurationConverter()
  final Duration effortDuration;

  /// The duration of the rest interval.
  @DurationConverter()
  final Duration restDuration;

  /// The weight to be used, in kilograms.
  final double weight;

  /// Converts this [HiitExerciseParameters] to a JSON object.
  Map<String, dynamic> toJson() => _$HiitExerciseParametersToJson(this);
}
