import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/history/exercise_log.dart';
import 'package:trainer_backend/models/history/round_log.dart';
import 'package:trainer_backend/models/training/enums/session_type.dart';

part 'session_log.g.dart';

/// A sealed class representing a log of a completed training session.
///
/// This class serves as a base for different types of session logs,
/// distinguished by the [SessionType]. It uses a factory constructor
/// to deserialize the correct subclass from JSON based on the `type` field.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  createToJson: false,
)
sealed class SessionLog {
  /// Creates an instance of [SessionLog].
  const SessionLog({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.programName,
    required this.startedAt,
    required this.endedAt,
  });

  /// A factory for creating a [SessionLog] instance from a JSON object.
  ///
  /// It determines the concrete type of the session log
  /// (e.g., [ClassicSessionLog], [AmrapSessionLog]) based on the `type`
  /// field in the JSON and delegates the deserialization to the
  /// corresponding subclass.
  factory SessionLog.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    switch (SessionType.fromJson(type)) {
      case SessionType.classic:
        return ClassicSessionLog.fromJson(json);
      case SessionType.amrap:
        return AmrapSessionLog.fromJson(json);
      case SessionType.emom:
        return EmomSessionLog.fromJson(json);
      case SessionType.hiit:
        return HiitSessionLog.fromJson(json);
    }
  }

  /// The unique identifier for the session log.
  final int id;

  /// The ID of the original [Session] this log corresponds to.
  final int sessionId;

  /// The name of the session, fetched from the database.
  final String name;

  /// The name of the program this session belongs to.
  final String programName;

  /// The timestamp when the session started.
  final DateTime startedAt;

  /// The timestamp when the session ended. Can be null if in progress.
  final DateTime endedAt;

  /// Converts this [SessionLog] to a JSON object.
  ///
  /// This method must be implemented by all subclasses.
  Map<String, dynamic> toJson();
}

/// A log for a 'Classic' style training session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class ClassicSessionLog extends SessionLog {
  /// Creates an instance of [ClassicSessionLog].
  const ClassicSessionLog({
    required super.id,
    required super.sessionId,
    required super.name,
    required super.programName,
    required super.startedAt,
    required super.endedAt,
    required this.rounds,
  });

  /// A factory for creating a [ClassicSessionLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory ClassicSessionLog.forCreation({
    required int sessionId,
    required String name,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<RoundLog<ClassicExerciseLog>> rounds,
  }) => ClassicSessionLog(
    id: 0,
    sessionId: sessionId,
    name: name,
    programName: '',
    startedAt: startedAt,
    endedAt: endedAt,
    rounds: rounds,
  );

  /// Creates a [ClassicSessionLog] from a JSON object.
  factory ClassicSessionLog.fromJson(Map<String, dynamic> json) =>
      _$ClassicSessionLogFromJson(json);

  /// A list of rounds performed during the classic session.
  ///
  /// Although classic sessions are typically set-based, they are modeled
  /// here as a single round for consistency.
  final List<RoundLog<ClassicExerciseLog>> rounds;

  @override
  Map<String, dynamic> toJson() => _$ClassicSessionLogToJson(this);
}

/// A log for an 'AMRAP' (As Many Rounds As Possible) style session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class AmrapSessionLog extends SessionLog {
  /// Creates an instance of [AmrapSessionLog].
  const AmrapSessionLog({
    required super.id,
    required super.sessionId,
    required super.name,
    required super.programName,
    required super.startedAt,
    required super.endedAt,
    required this.rounds,
  });

  /// A factory for creating an [AmrapSessionLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory AmrapSessionLog.forCreation({
    required int sessionId,
    required String name,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<RoundLog<AmrapExerciseLog>> rounds,
  }) => AmrapSessionLog(
    id: 0,
    sessionId: sessionId,
    name: name,
    programName: '',
    startedAt: startedAt,
    endedAt: endedAt,
    rounds: rounds,
  );

  /// Creates an [AmrapSessionLog] from a JSON object.
  factory AmrapSessionLog.fromJson(Map<String, dynamic> json) =>
      _$AmrapSessionLogFromJson(json);

  /// The list of rounds completed during the AMRAP session.
  final List<RoundLog<AmrapExerciseLog>> rounds;

  @override
  Map<String, dynamic> toJson() => _$AmrapSessionLogToJson(this);
}

/// A log for an 'EMOM' (Every Minute On the Minute) style session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class EmomSessionLog extends SessionLog {
  /// Creates an instance of [EmomSessionLog].
  const EmomSessionLog({
    required super.id,
    required super.sessionId,
    required super.name,
    required super.programName,
    required super.startedAt,
    required super.endedAt,
    required this.rounds,
  });

  /// A factory for creating an [EmomSessionLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory EmomSessionLog.forCreation({
    required int sessionId,
    required String name,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<RoundLog<EmomExerciseLog>> rounds,
  }) => EmomSessionLog(
    id: 0,
    sessionId: sessionId,
    name: name,
    programName: '',
    startedAt: startedAt,
    endedAt: endedAt,
    rounds: rounds,
  );

  /// Creates an [EmomSessionLog] from a JSON object.
  factory EmomSessionLog.fromJson(Map<String, dynamic> json) =>
      _$EmomSessionLogFromJson(json);

  /// The list of rounds performed during the EMOM session.
  final List<RoundLog<EmomExerciseLog>> rounds;

  @override
  Map<String, dynamic> toJson() => _$EmomSessionLogToJson(this);
}

/// A log for a 'HIIT' (High-Intensity Interval Training) style session.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
@CopyWith()
class HiitSessionLog extends SessionLog {
  /// Creates an instance of [HiitSessionLog].
  const HiitSessionLog({
    required super.id,
    required super.sessionId,
    required super.name,
    required super.programName,
    required super.startedAt,
    required super.endedAt,
    required this.rounds,
  });

  /// A factory for creating a [HiitSessionLog] for insertion into the db.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory HiitSessionLog.forCreation({
    required int sessionId,
    required String name,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<RoundLog<HiitExerciseLog>> rounds,
  }) => HiitSessionLog(
    id: 0,
    sessionId: sessionId,
    name: name,
    programName: '',
    startedAt: startedAt,
    endedAt: endedAt,
    rounds: rounds,
  );

  /// Creates a [HiitSessionLog] from a JSON object.
  factory HiitSessionLog.fromJson(Map<String, dynamic> json) =>
      _$HiitSessionLogFromJson(json);

  /// The list of rounds performed during the HIIT session.
  final List<RoundLog<HiitExerciseLog>> rounds;

  @override
  Map<String, dynamic> toJson() => _$HiitSessionLogToJson(this);
}
