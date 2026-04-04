import 'package:trainer_backend/models/history/exercise_log.dart';
import 'package:trainer_backend/models/history/round_log.dart';
import 'package:trainer_backend/models/history/session_log.dart';

/// Utility class for creating test session logs with configurable parameters.
///
/// Session logs require real IDs from the database (session ID and exercise IDs),
/// so all factories accept these as required parameters. Call
/// [ProgramsService.createFullProgram] first and extract the IDs from the result
/// before using these factories.
class TestSessionLogs {
  TestSessionLogs._();

  /// Creates a [ClassicSessionLog] for a single round with one exercise.
  ///
  /// - [sessionId]: The ID of the session from the database.
  /// - [sessionExerciseId]: The ID of the exercise instance in the session.
  /// - [setCount]: The number of sets to log. Defaults to 3.
  static ClassicSessionLog createClassicSessionLog({
    required int sessionId,
    required int sessionExerciseId,
    int setCount = 3,
  }) => ClassicSessionLog.forCreation(
    sessionId: sessionId,
    name: 'Test Classic Session Log',
    startedAt: DateTime.now().subtract(const Duration(hours: 1)),
    endedAt: DateTime.now(),
    rounds: <RoundLog<ClassicExerciseLog>>[
      RoundLog<ClassicExerciseLog>.forCreation(
        roundNumber: 1,
        exercises: <ClassicExerciseLog>[
          ClassicExerciseLog.forCreation(
            sessionExerciseId: sessionExerciseId,
            orderInRoundLog: 0,
            sets: List<SetLog>.generate(
              setCount,
              (int index) =>
                  SetLog(number: index + 1, weight: 50.0, reps: 10, restDuration: const Duration(minutes: 1)),
            ),
          ),
        ],
      ),
    ],
  );

  /// Creates an [AmrapSessionLog] with a configurable number of rounds.
  ///
  /// - [sessionId]: The ID of the session from the database.
  /// - [sessionExerciseId]: The ID of the exercise instance in the session.
  /// - [roundCount]: The number of completed rounds to log. Defaults to 3.
  static AmrapSessionLog createAmrapSessionLog({
    required int sessionId,
    required int sessionExerciseId,
    int roundCount = 3,
  }) => AmrapSessionLog.forCreation(
    sessionId: sessionId,
    name: 'Test AMRAP Session Log',
    startedAt: DateTime.now().subtract(const Duration(hours: 1)),
    endedAt: DateTime.now(),
    rounds: List<RoundLog<AmrapExerciseLog>>.generate(
      roundCount,
      (int roundIndex) => RoundLog<AmrapExerciseLog>.forCreation(
        roundNumber: roundIndex + 1,
        exercises: <AmrapExerciseLog>[
          AmrapExerciseLog.forCreation(
            sessionExerciseId: sessionExerciseId,
            orderInRoundLog: 0,
            repsNumber: 15,
            weight: 20.0,
          ),
        ],
      ),
    ),
  );

  /// Creates an [EmomSessionLog] with a configurable number of rounds.
  ///
  /// - [sessionId]: The ID of the session from the database.
  /// - [sessionExerciseId]: The ID of the exercise instance in the session.
  /// - [roundCount]: The number of rounds to log. Defaults to 10.
  static EmomSessionLog createEmomSessionLog({
    required int sessionId,
    required int sessionExerciseId,
    int roundCount = 10,
  }) => EmomSessionLog.forCreation(
    sessionId: sessionId,
    name: 'Test EMOM Session Log',
    startedAt: DateTime.now().subtract(const Duration(hours: 1)),
    endedAt: DateTime.now(),
    rounds: List<RoundLog<EmomExerciseLog>>.generate(
      roundCount,
      (int roundIndex) => RoundLog<EmomExerciseLog>.forCreation(
        roundNumber: roundIndex + 1,
        exercises: <EmomExerciseLog>[
          EmomExerciseLog.forCreation(
            sessionExerciseId: sessionExerciseId,
            orderInRoundLog: 0,
            duration: const Duration(seconds: 40),
            repsNumber: 12,
            weight: 30.0,
          ),
        ],
      ),
    ),
  );

  /// Creates a [HiitSessionLog] with a configurable number of rounds.
  ///
  /// - [sessionId]: The ID of the session from the database.
  /// - [sessionExerciseId]: The ID of the exercise instance in the session.
  /// - [roundCount]: The number of rounds to log. Defaults to 8.
  static HiitSessionLog createHiitSessionLog({
    required int sessionId,
    required int sessionExerciseId,
    int roundCount = 8,
  }) => HiitSessionLog.forCreation(
    sessionId: sessionId,
    name: 'Test HIIT Session Log',
    startedAt: DateTime.now().subtract(const Duration(hours: 1)),
    endedAt: DateTime.now(),
    rounds: List<RoundLog<HiitExerciseLog>>.generate(
      roundCount,
      (int roundIndex) => RoundLog<HiitExerciseLog>.forCreation(
        roundNumber: roundIndex + 1,
        exercises: <HiitExerciseLog>[
          HiitExerciseLog.forCreation(
            sessionExerciseId: sessionExerciseId,
            orderInRoundLog: 0,
            effortDuration: const Duration(seconds: 30),
            restDuration: const Duration(seconds: 15),
            weight: 0.0,
          ),
        ],
      ),
    ),
  );
}
