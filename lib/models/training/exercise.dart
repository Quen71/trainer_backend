import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/training/enums/session_type.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';

part 'exercise.g.dart';

/// A helper function for `json_serializable` to read the exercise name
/// from a nested 'exercise' object in the JSON payload.
Object? _readName(Map<dynamic, dynamic> json, String key) => (json['exercise'] as Map<String, dynamic>)['name'];

/// A sealed class representing an exercise within a training session.
///
/// This class serves as a base for different types of exercises, corresponding
/// to the various [SessionType] values. It uses a factory constructor to

/// deserialize the correct subclass from JSON based on the `session_type`
/// field, which is injected during the parent [Session] deserialization.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  createToJson: false,
)
sealed class Exercise {
  /// Creates an instance of [Exercise].
  const Exercise({
    required this.id,
    required this.exerciseId,
    required this.orderInSession,
    required this.name,
  });

  /// A factory for creating an [Exercise] instance from a JSON object.
  ///
  /// It determines the concrete type of the exercise based on the
  /// `session_type` field and delegates deserialization to the
  /// appropriate subclass.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final SessionType type = SessionType.values.byName(json['session_type'] as String);
    switch (type) {
      case SessionType.classic:
        return ClassicExercise.fromJson(json);
      case SessionType.amrap:
        return AmrapExercise.fromJson(json);
      case SessionType.emom:
        return EmomExercise.fromJson(json);
      case SessionType.hiit:
        return HiitExercise.fromJson(json);
    }
  }

  /// The unique identifier for this specific instance of an exercise in a session.
  final int id;

  /// The foreign key referencing the global 'exercises' table.
  final int exerciseId;

  /// The order of this exercise within the session.
  final int orderInSession;

  /// The name of the exercise.
  ///
  /// This value is read from a nested object in the JSON payload.
  @JsonKey(readValue: _readName)
  final String name;

  /// Converts this [Exercise] to a JSON object.
  ///
  /// Subclasses should override this and add their specific fields.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'exercise_id': exerciseId,
        'order_in_session': orderInSession,
        'name': name,
      };
}

/// Represents a 'Classic' style exercise, defined by sets, reps, and weight.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
@CopyWith()
class ClassicExercise extends Exercise {
  /// Creates an instance of [ClassicExercise].
  const ClassicExercise({
    required super.id,
    required super.exerciseId,
    required super.orderInSession,
    required super.name,
    required this.templateParameters,
    this.objectiveParameters,
  });

  /// A factory for creating a [ClassicExercise] for insertion into the db.
  ///
  /// The [id] and [exerciseId] are initialized to 0, as they will be
  /// assigned by the database.
  factory ClassicExercise.forCreation({
    required int orderInSession,
    required String name,
    required ClassicExerciseParameters templateParameters,
    ClassicExerciseParameters? objectiveParameters,
  }) =>
      ClassicExercise(
        id: 0,
        exerciseId: 0,
        orderInSession: orderInSession,
        name: name,
        templateParameters: templateParameters,
        objectiveParameters: objectiveParameters,
      );

  /// Creates a [ClassicExercise] from a JSON object.
  factory ClassicExercise.fromJson(Map<String, dynamic> json) => _$ClassicExerciseFromJson(json);

  /// The base parameters for the exercise (e.g., target reps, weight).
  @JsonKey(name: 'parameters')
  final ClassicExerciseParameters templateParameters;

  /// The parameters for progressive overload, if any.
  @JsonKey(name: 'progression', fromJson: _progressionToObjective, toJson: _objectiveToProgression)
  final ClassicExerciseParameters? objectiveParameters;

  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll(_$ClassicExerciseToJson(this));
}

/// Converts the 'progression' JSON field to [ClassicExerciseParameters].
ClassicExerciseParameters? _progressionToObjective(List<dynamic>? progression) {
  final Map<String, dynamic>? objective =
      progression?.firstOrNull?['next_objective_parameters'] as Map<String, dynamic>?;
  if (objective == null) {
    return null;
  }
  return ClassicExerciseParameters.fromJson(objective);
}

/// Converts [ClassicExerciseParameters] back to the 'progression' JSON format.
List<Map<String, dynamic>>? _objectiveToProgression(
  ClassicExerciseParameters? objective,
) {
  if (objective == null) {
    return null;
  }
  return <Map<String, dynamic>>[
    <String, dynamic>{'next_objective_parameters': objective.toJson()},
  ];
}

/// Represents an 'AMRAP' style exercise.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
@CopyWith()
class AmrapExercise extends Exercise {
  /// Creates an instance of [AmrapExercise].
  const AmrapExercise({
    required super.id,
    required super.exerciseId,
    required super.orderInSession,
    required super.name,
    required this.templateParameters,
    this.objectiveParameters,
  });

  /// A factory for creating an [AmrapExercise] for insertion into the db.
  ///
  /// The [id] and [exerciseId] are initialized to 0.
  factory AmrapExercise.forCreation({
    required int orderInSession,
    required String name,
    required AmrapExerciseParameters templateParameters,
    AmrapExerciseParameters? objectiveParameters,
  }) =>
      AmrapExercise(
        id: 0,
        exerciseId: 0,
        orderInSession: orderInSession,
        name: name,
        templateParameters: templateParameters,
        objectiveParameters: objectiveParameters,
      );

  /// Creates an [AmrapExercise] from a JSON object.
  factory AmrapExercise.fromJson(Map<String, dynamic> json) => _$AmrapExerciseFromJson(json);

  /// The base parameters for the AMRAP exercise.
  @JsonKey(name: 'parameters')
  final AmrapExerciseParameters templateParameters;

  /// The parameters for progressive overload in an AMRAP context.
  @JsonKey(name: 'progression', fromJson: _amrapProgressionToObjective, toJson: _amrapObjectiveToProgression)
  final AmrapExerciseParameters? objectiveParameters;

  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll(_$AmrapExerciseToJson(this));
}

/// Converts the 'progression' JSON field to [AmrapExerciseParameters].
AmrapExerciseParameters? _amrapProgressionToObjective(List<dynamic>? progression) {
  final Map<String, dynamic>? objective =
      progression?.firstOrNull?['next_objective_parameters'] as Map<String, dynamic>?;
  if (objective == null) {
    return null;
  }
  return AmrapExerciseParameters.fromJson(objective);
}

/// Converts [AmrapExerciseParameters] back to the 'progression' JSON format.
List<Map<String, dynamic>>? _amrapObjectiveToProgression(
  AmrapExerciseParameters? objective,
) {
  if (objective == null) {
    return null;
  }
  return <Map<String, dynamic>>[
    <String, dynamic>{'next_objective_parameters': objective.toJson()},
  ];
}

/// Represents an 'EMOM' style exercise.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
@CopyWith()
class EmomExercise extends Exercise {
  /// Creates an instance of [EmomExercise].
  const EmomExercise({
    required super.id,
    required super.exerciseId,
    required super.orderInSession,
    required super.name,
    required this.templateParameters,
    this.objectiveParameters,
  });

  /// A factory for creating an [EmomExercise] for insertion into the db.
  ///
  /// The [id] and [exerciseId] are initialized to 0.
  factory EmomExercise.forCreation({
    required int orderInSession,
    required String name,
    required EmomExerciseParameters templateParameters,
    EmomExerciseParameters? objectiveParameters,
  }) =>
      EmomExercise(
        id: 0,
        exerciseId: 0,
        orderInSession: orderInSession,
        name: name,
        templateParameters: templateParameters,
        objectiveParameters: objectiveParameters,
      );

  /// Creates an [EmomExercise] from a JSON object.
  factory EmomExercise.fromJson(Map<String, dynamic> json) => _$EmomExerciseFromJson(json);

  /// The base parameters for the EMOM exercise.
  @JsonKey(name: 'parameters')
  final EmomExerciseParameters templateParameters;

  /// The parameters for progressive overload in an EMOM context.
  @JsonKey(name: 'progression', fromJson: _emomProgressionToObjective, toJson: _emomObjectiveToProgression)
  final EmomExerciseParameters? objectiveParameters;

  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll(_$EmomExerciseToJson(this));
}

/// Converts the 'progression' JSON field to [EmomExerciseParameters].
EmomExerciseParameters? _emomProgressionToObjective(List<dynamic>? progression) {
  final Map<String, dynamic>? objective =
      progression?.firstOrNull?['next_objective_parameters'] as Map<String, dynamic>?;
  if (objective == null) {
    return null;
  }
  return EmomExerciseParameters.fromJson(objective);
}

/// Converts [EmomExerciseParameters] back to the 'progression' JSON format.
List<Map<String, dynamic>>? _emomObjectiveToProgression(
  EmomExerciseParameters? objective,
) {
  if (objective == null) {
    return null;
  }
  return <Map<String, dynamic>>[
    <String, dynamic>{'next_objective_parameters': objective.toJson()},
  ];
}

/// Represents a 'HIIT' style exercise.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
@CopyWith()
class HiitExercise extends Exercise {
  /// Creates an instance of [HiitExercise].
  const HiitExercise({
    required super.id,
    required super.exerciseId,
    required super.orderInSession,
    required super.name,
    required this.templateParameters,
    this.objectiveParameters,
  });

  /// A factory for creating a [HiitExercise] for insertion into the db.
  ///
  /// The [id] and [exerciseId] are initialized to 0.
  factory HiitExercise.forCreation({
    required int orderInSession,
    required String name,
    required HiitExerciseParameters templateParameters,
    HiitExerciseParameters? objectiveParameters,
  }) =>
      HiitExercise(
        id: 0,
        exerciseId: 0,
        orderInSession: orderInSession,
        name: name,
        templateParameters: templateParameters,
        objectiveParameters: objectiveParameters,
      );

  /// Creates a [HiitExercise] from a JSON object.
  factory HiitExercise.fromJson(Map<String, dynamic> json) => _$HiitExerciseFromJson(json);

  /// The base parameters for the HIIT exercise.
  @JsonKey(name: 'parameters')
  final HiitExerciseParameters templateParameters;

  /// The parameters for progressive overload in a HIIT context.
  @JsonKey(name: 'progression', fromJson: _hiitProgressionToObjective, toJson: _hiitObjectiveToProgression)
  final HiitExerciseParameters? objectiveParameters;

  @override
  Map<String, dynamic> toJson() => super.toJson()..addAll(_$HiitExerciseToJson(this));
}

/// Converts the 'progression' JSON field to [HiitExerciseParameters].
HiitExerciseParameters? _hiitProgressionToObjective(List<dynamic>? progression) {
  final Map<String, dynamic>? objective =
      progression?.firstOrNull?['next_objective_parameters'] as Map<String, dynamic>?;
  if (objective == null) {
    return null;
  }
  return HiitExerciseParameters.fromJson(objective);
}

/// Converts [HiitExerciseParameters] back to the 'progression' JSON format.
List<Map<String, dynamic>>? _hiitObjectiveToProgression(
  HiitExerciseParameters? objective,
) {
  if (objective == null) {
    return null;
  }
  return <Map<String, dynamic>>[
    <String, dynamic>{'next_objective_parameters': objective.toJson()},
  ];
}
