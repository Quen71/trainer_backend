import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/training/converters/duration_converter.dart';
import 'package:trainer_backend/models/training/enums/session_style.dart';
import 'package:trainer_backend/models/training/enums/session_type.dart';
import 'package:trainer_backend/models/training/exercise.dart';

part 'session.g.dart';

/// A sealed class representing a single training session within a program.
///
/// This class acts as a base for different types of sessions, such as
/// [ClassicSession], [AmrapSession], etc. It uses a factory constructor
/// to deserialize the correct subclass from JSON based on the `type` field.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  createToJson: false,
)
sealed class Session {
  /// Creates an instance of [Session].
  const Session({
    required this.id,
    required this.name,
    required this.orderInProgram,
    required this.type,
    required this.style,
  });

  /// A factory for creating a [Session] instance from a JSON object.
  ///
  /// It determines the concrete type of the session based on the `type`
  /// field in the JSON and delegates deserialization to the appropriate subclass.
  factory Session.fromJson(Map<String, dynamic> json) {
    final SessionType type = SessionType.fromJson(json['type'] as String);
    switch (type) {
      case SessionType.classic:
        return ClassicSession.fromJson(json);
      case SessionType.amrap:
        return AmrapSession.fromJson(json);
      case SessionType.emom:
        return EmomSession.fromJson(json);
      case SessionType.hiit:
        return HiitSession.fromJson(json);
    }
  }

  /// The unique identifier for the session.
  final int id;

  /// The name of the session.
  final String name;

  /// The order of this session within its parent program.
  final int orderInProgram;

  /// The type of the session (e.g., Classic, AMRAP).
  final SessionType type;

  /// The style of the session (e.g., Strength, Hypertrophy).
  final SessionStyle style;

  /// Converts this [Session] to a JSON object.
  ///
  /// Subclasses should override this and add their specific fields.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'order_in_program': orderInProgram,
    'type': type.toJson(),
    'style': style.toJson(),
    // 'exercises' will be handled by subclasses
  };
}

/// A helper function to inject the session type into exercise JSON objects.
///
/// This is necessary for the correct deserialization of the generic [Exercise]
/// sealed class, as the `type` information resides at the session level.
void _injectSessionType(Map<String, dynamic> json) {
  final String sessionType = json['type'] as String;
  final List<dynamic>? exercises = json['exercises'] as List<dynamic>?;
  if (exercises == null) return;

  for (final dynamic exerciseJson in exercises) {
    (exerciseJson as Map<String, dynamic>)['session_type'] = sessionType;
  }
}

/// Represents a 'Classic' training session, typically focused on sets and reps.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class ClassicSession extends Session {
  /// Creates an instance of [ClassicSession].
  const ClassicSession({
    required super.id,
    required super.name,
    required super.orderInProgram,
    required super.style,
    required this.exercises,
  }) : super(type: SessionType.classic);

  /// A factory for creating a [ClassicSession] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory ClassicSession.forCreation({
    required String name,
    required int orderInProgram,
    required SessionStyle style,
    required List<ClassicExercise> exercises,
  }) => ClassicSession(
    id: 0,
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    exercises: exercises,
  );

  /// Creates a [ClassicSession] from a JSON object.
  ///
  /// It injects the session type into the exercise data before deserialization.
  factory ClassicSession.fromJson(Map<String, dynamic> json) {
    _injectSessionType(json);
    return _$ClassicSessionFromJson(json);
  }

  /// The list of exercises in this classic session.
  final List<ClassicExercise> exercises;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$ClassicSessionToJson(this));
}

/// Represents an 'AMRAP' (As Many Rounds As Possible) session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class AmrapSession extends Session {
  /// Creates an instance of [AmrapSession].
  const AmrapSession({
    required super.id,
    required super.name,
    required super.orderInProgram,
    required super.style,
    required this.exercises,
    required this.duration,
  }) : super(type: SessionType.amrap);

  /// A factory for creating an [AmrapSession] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory AmrapSession.forCreation({
    required String name,
    required int orderInProgram,
    required SessionStyle style,
    required List<AmrapExercise> exercises,
    required Duration duration,
  }) => AmrapSession(
    id: 0,
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    exercises: exercises,
    duration: duration,
  );

  /// Creates an [AmrapSession] from a JSON object.
  ///
  /// It injects the session type into the exercise data before deserialization.
  factory AmrapSession.fromJson(Map<String, dynamic> json) {
    _injectSessionType(json);
    return _$AmrapSessionFromJson(json);
  }

  /// The list of exercises in this AMRAP session.
  final List<AmrapExercise> exercises;

  /// The total duration of the AMRAP session.
  @DurationConverter()
  @JsonKey(name: 'duration')
  final Duration duration;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$AmrapSessionToJson(this));
}

/// Represents an 'EMOM' (Every Minute On the Minute) session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class EmomSession extends Session {
  /// Creates an instance of [EmomSession].
  const EmomSession({
    required super.id,
    required super.name,
    required super.orderInProgram,
    required super.style,
    required this.exercises,
    required this.roundNumber,
  }) : super(type: SessionType.emom);

  /// A factory for creating an [EmomSession] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory EmomSession.forCreation({
    required String name,
    required int orderInProgram,
    required SessionStyle style,
    required List<EmomExercise> exercises,
    required int roundNumber,
  }) => EmomSession(
    id: 0,
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    exercises: exercises,
    roundNumber: roundNumber,
  );

  /// Creates an [EmomSession] from a JSON object.
  ///
  /// It injects the session type into the exercise data before deserialization.
  factory EmomSession.fromJson(Map<String, dynamic> json) {
    _injectSessionType(json);
    return _$EmomSessionFromJson(json);
  }

  /// The list of exercises in this EMOM session.
  final List<EmomExercise> exercises;

  /// The total number of rounds in the EMOM session.
  @JsonKey(name: 'round_number')
  final int roundNumber;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$EmomSessionToJson(this));
}

/// Represents a 'HIIT' (High-Intensity Interval Training) session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class HiitSession extends Session {
  /// Creates an instance of [HiitSession].
  const HiitSession({
    required super.id,
    required super.name,
    required super.orderInProgram,
    required super.style,
    required this.exercises,
    required this.roundNumber,
  }) : super(type: SessionType.hiit);

  /// A factory for creating a [HiitSession] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory HiitSession.forCreation({
    required String name,
    required int orderInProgram,
    required SessionStyle style,
    required List<HiitExercise> exercises,
    required int roundNumber,
  }) => HiitSession(
    id: 0,
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    exercises: exercises,
    roundNumber: roundNumber,
  );

  /// Creates a [HiitSession] from a JSON object.
  ///
  /// It injects the session type into the exercise data before deserialization.
  factory HiitSession.fromJson(Map<String, dynamic> json) {
    _injectSessionType(json);
    return _$HiitSessionFromJson(json);
  }

  /// The list of exercises in this HIIT session.
  final List<HiitExercise> exercises;

  /// The total number of rounds in the HIIT session.
  @JsonKey(name: 'round_number')
  final int roundNumber;

  @override
  Map<String, dynamic> toJson() =>
      super.toJson()..addAll(_$HiitSessionToJson(this));
}
