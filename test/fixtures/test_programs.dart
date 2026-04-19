import 'package:trainer_backend/models/training/enums/session_style.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';

/// Utility class for creating test programs with configurable sessions and exercises.
///
/// This class provides factories to create properly formatted [Program] instances
/// for use in integration and unit tests. It ensures consistency across tests
/// and makes it easy to create programs with various session types and configurations.
class TestPrograms {
  TestPrograms._();

  /// Creates a basic program with a single classic session containing one exercise.
  ///
  /// **Parameters:**
  /// - [name]: The name of the program. Defaults to 'Test Program'.
  /// - [sessionName]: The name of the session. Defaults to 'Session 1'.
  /// - [style]: The session style. Defaults to [SessionStyle.weights].
  /// - [exerciseCount]: The number of exercises in the session. Defaults to 1.
  static Program createSimpleProgram({
    String name = 'Test Program',
    String sessionName = 'Session 1',
    SessionStyle style = SessionStyle.weights,
    int exerciseCount = 1,
  }) => Program.forCreation(
    name: name,
    sessions: <Session>[
      ClassicSession.forCreation(
        name: sessionName,
        orderInProgram: 0,
        style: style,
        exercises: List<ClassicExercise>.generate(
          exerciseCount,
          (int index) => _createClassicExercise(
            orderInSession: index,
            name: 'Exercise ${index + 1}',
          ),
        ),
      ),
    ],
  );

  /// Creates a program with multiple classic sessions.
  ///
  /// **Parameters:**
  /// - [name]: The name of the program.
  /// - [sessionCount]: The number of sessions in the program.
  /// - [exercisesPerSession]: The number of exercises per session. Defaults to 1.
  /// - [style]: The session style for all sessions. Defaults to [SessionStyle.weights].
  static Program createProgramWithMultipleSessions({
    required String name,
    required int sessionCount,
    int exercisesPerSession = 1,
    SessionStyle style = SessionStyle.weights,
  }) => Program.forCreation(
    name: name,
    sessions: List<Session>.generate(
      sessionCount,
      (int index) => ClassicSession.forCreation(
        name: 'Session ${index + 1}',
        orderInProgram: index,
        style: style,
        exercises: List<ClassicExercise>.generate(
          exercisesPerSession,
          (int exIndex) => _createClassicExercise(
            orderInSession: exIndex,
            name: 'Exercise ${exIndex + 1}',
          ),
        ),
      ),
    ),
  );

  /// Creates a program with mixed session types (Classic, AMRAP, EMOM, HIIT).
  ///
  /// **Parameters:**
  /// - [name]: The name of the program.
  /// - [includeClassic]: Whether to include a Classic session. Defaults to true.
  /// - [includeAmrap]: Whether to include an AMRAP session. Defaults to true.
  /// - [includeEmom]: Whether to include an EMOM session. Defaults to true.
  /// - [includeHiit]: Whether to include a HIIT session. Defaults to true.
  /// - [exercisesPerSession]: The number of exercises per session. Defaults to 2.
  static Program createMixedTypeProgram({
    String name = 'Mixed Program',
    bool includeClassic = true,
    bool includeAmrap = true,
    bool includeEmom = true,
    bool includeHiit = true,
    int exercisesPerSession = 2,
  }) {
    final List<Session> sessions = <Session>[];
    int orderInProgram = 0;

    if (includeClassic) {
      sessions.add(
        ClassicSession.forCreation(
          name: 'Session Classic',
          orderInProgram: orderInProgram++,
          style: SessionStyle.weights,
          exercises: List<ClassicExercise>.generate(
            exercisesPerSession,
            (int index) => _createClassicExercise(
              orderInSession: index,
              name: 'Classic Exercise ${index + 1}',
            ),
          ),
        ),
      );
    }

    if (includeAmrap) {
      sessions.add(
        AmrapSession.forCreation(
          name: 'Session AMRAP',
          orderInProgram: orderInProgram++,
          style: SessionStyle.bodyweight,
          duration: const Duration(minutes: 20),
          exercises: List<AmrapExercise>.generate(
            exercisesPerSession,
            (int index) => _createAmrapExercise(
              orderInSession: index,
              name: 'AMRAP Exercise ${index + 1}',
            ),
          ),
        ),
      );
    }

    if (includeEmom) {
      sessions.add(
        EmomSession.forCreation(
          name: 'Session EMOM',
          orderInProgram: orderInProgram++,
          style: SessionStyle.bodyweight,
          roundNumber: 10,
          exercises: List<EmomExercise>.generate(
            exercisesPerSession,
            (int index) => _createEmomExercise(
              orderInSession: index,
              name: 'EMOM Exercise ${index + 1}',
            ),
          ),
        ),
      );
    }

    if (includeHiit) {
      sessions.add(
        HiitSession.forCreation(
          name: 'Session HIIT',
          orderInProgram: orderInProgram++,
          style: SessionStyle.bodyweight,
          roundNumber: 8,
          exercises: List<HiitExercise>.generate(
            exercisesPerSession,
            (int index) => _createHiitExercise(
              orderInSession: index,
              name: 'HIIT Exercise ${index + 1}',
            ),
          ),
        ),
      );
    }

    return Program.forCreation(name: name, sessions: sessions);
  }

  /// Creates a program with mixed session types (Classic, AMRAP, EMOM, HIIT) cycling.
  ///
  /// Useful for testing Premium volume limits with diverse session types.
  ///
  /// **Parameters:**
  /// - [name]: The name of the program.
  /// - [sessionCount]: The exact number of sessions to create.
  /// - [exercisesPerSession]: The number of exercises per session. Defaults to 1.
  static Program createMixedSessionsProgram({
    required String name,
    required int sessionCount,
    int exercisesPerSession = 1,
  }) {
    const List<String> sessionTypes = <String>[
      'classic',
      'amrap',
      'emom',
      'hiit',
    ];
    return Program.forCreation(
      name: name,
      sessions: List<Session>.generate(sessionCount, (int index) {
        final String sessionType = sessionTypes[index % 4];
        return _createSessionByType(
          sessionType: sessionType,
          orderInProgram: index,
          name: 'Session ${index + 1}',
          exerciseCount: exercisesPerSession,
        );
      }),
    );
  }

  /// Creates a program designed to test session limits.
  ///
  /// **Parameters:**
  /// - [name]: The name of the program.
  /// - [sessionCount]: The exact number of sessions to create.
  /// - [sessionType]: The type of sessions to create. Defaults to 'classic'.
  /// - [exercisesPerSession]: The number of exercises per session. Defaults to 1.
  static Program createProgramForSessionLimitTest({
    required String name,
    required int sessionCount,
    String sessionType = 'classic',
    int exercisesPerSession = 1,
  }) => Program.forCreation(
    name: name,
    sessions: List<Session>.generate(
      sessionCount,
      (int index) => _createSessionByType(
        sessionType: sessionType,
        orderInProgram: index,
        name: 'Session ${index + 1}',
        exerciseCount: exercisesPerSession,
      ),
    ),
  );

  /// Creates a program with a session containing a specific number of exercises.
  ///
  /// This is useful for testing exercise limits per session.
  ///
  /// **Parameters:**
  /// - [name]: The name of the program.
  /// - [exerciseCount]: The number of exercises in the session.
  /// - [sessionType]: The type of session. Defaults to 'classic'.
  static Program createProgramForExerciseLimitTest({
    required String name,
    required int exerciseCount,
    String sessionType = 'classic',
  }) => Program.forCreation(
    name: name,
    sessions: <Session>[
      _createSessionByType(
        sessionType: sessionType,
        orderInProgram: 0,
        name: 'Test Session',
        exerciseCount: exerciseCount,
      ),
    ],
  );

  /// Creates a classic session with configurable parameters.
  ///
  /// **Parameters:**
  /// - [name]: The name of the session.
  /// - [orderInProgram]: The order of this session in the program.
  /// - [style]: The session style. Defaults to [SessionStyle.weights].
  /// - [exerciseCount]: The number of exercises in the session.
  static ClassicSession createClassicSession({
    required String name,
    required int orderInProgram,
    SessionStyle style = SessionStyle.weights,
    int exerciseCount = 1,
  }) => ClassicSession.forCreation(
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    exercises: List<ClassicExercise>.generate(
      exerciseCount,
      (int index) => _createClassicExercise(
        orderInSession: index,
        name: 'Exercise ${index + 1}',
      ),
    ),
  );

  /// Creates an AMRAP session with configurable parameters.
  ///
  /// **Parameters:**
  /// - [name]: The name of the session.
  /// - [orderInProgram]: The order of this session in the program.
  /// - [duration]: The duration of the AMRAP session. Defaults to 20 minutes.
  /// - [style]: The session style. Defaults to [SessionStyle.bodyweight].
  /// - [exerciseCount]: The number of exercises in the session.
  static AmrapSession createAmrapSession({
    required String name,
    required int orderInProgram,
    Duration duration = const Duration(minutes: 20),
    SessionStyle style = SessionStyle.bodyweight,
    int exerciseCount = 1,
  }) => AmrapSession.forCreation(
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    duration: duration,
    exercises: List<AmrapExercise>.generate(
      exerciseCount,
      (int index) => _createAmrapExercise(
        orderInSession: index,
        name: 'Exercise ${index + 1}',
      ),
    ),
  );

  /// Creates an EMOM session with configurable parameters.
  ///
  /// **Parameters:**
  /// - [name]: The name of the session.
  /// - [orderInProgram]: The order of this session in the program.
  /// - [roundNumber]: The number of rounds. Defaults to 10.
  /// - [style]: The session style. Defaults to [SessionStyle.bodyweight].
  /// - [exerciseCount]: The number of exercises in the session.
  static EmomSession createEmomSession({
    required String name,
    required int orderInProgram,
    int roundNumber = 10,
    SessionStyle style = SessionStyle.bodyweight,
    int exerciseCount = 1,
  }) => EmomSession.forCreation(
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    roundNumber: roundNumber,
    exercises: List<EmomExercise>.generate(
      exerciseCount,
      (int index) => _createEmomExercise(
        orderInSession: index,
        name: 'Exercise ${index + 1}',
      ),
    ),
  );

  /// Creates a HIIT session with configurable parameters.
  ///
  /// **Parameters:**
  /// - [name]: The name of the session.
  /// - [orderInProgram]: The order of this session in the program.
  /// - [roundNumber]: The number of rounds. Defaults to 8.
  /// - [style]: The session style. Defaults to [SessionStyle.bodyweight].
  /// - [exerciseCount]: The number of exercises in the session.
  static HiitSession createHiitSession({
    required String name,
    required int orderInProgram,
    int roundNumber = 8,
    SessionStyle style = SessionStyle.bodyweight,
    int exerciseCount = 1,
  }) => HiitSession.forCreation(
    name: name,
    orderInProgram: orderInProgram,
    style: style,
    roundNumber: roundNumber,
    exercises: List<HiitExercise>.generate(
      exerciseCount,
      (int index) => _createHiitExercise(
        orderInSession: index,
        name: 'Exercise ${index + 1}',
      ),
    ),
  );

  // --- Private Helper Methods ---

  /// Creates a session based on the specified type.
  static Session _createSessionByType({
    required String sessionType,
    required int orderInProgram,
    required String name,
    required int exerciseCount,
  }) {
    switch (sessionType.toLowerCase()) {
      case 'classic':
        return createClassicSession(
          name: name,
          orderInProgram: orderInProgram,
          exerciseCount: exerciseCount,
        );
      case 'amrap':
        return createAmrapSession(
          name: name,
          orderInProgram: orderInProgram,
          exerciseCount: exerciseCount,
        );
      case 'emom':
        return createEmomSession(
          name: name,
          orderInProgram: orderInProgram,
          exerciseCount: exerciseCount,
        );
      case 'hiit':
        return createHiitSession(
          name: name,
          orderInProgram: orderInProgram,
          exerciseCount: exerciseCount,
        );
      default:
        throw ArgumentError('Unknown session type: $sessionType');
    }
  }

  /// Creates a classic exercise with default parameters.
  static ClassicExercise _createClassicExercise({
    required int orderInSession,
    required String name,
    int sets = 3,
    int reps = 10,
    double weight = 50.0,
    Duration restDuration = const Duration(minutes: 1),
  }) => ClassicExercise.forCreation(
    orderInSession: orderInSession,
    name: name,
    templateParameters: ClassicExerciseParameters(
      sets: List<ClassicExerciseSet>.generate(
        sets,
        (int index) => ClassicExerciseSet(
          orderInExercise: index,
          repsNumber: reps,
          weight: weight,
          restDuration: restDuration,
        ),
      ),
    ),
  );

  /// Creates an AMRAP exercise with default parameters.
  static AmrapExercise _createAmrapExercise({
    required int orderInSession,
    required String name,
    int reps = 15,
    double weight = 20.0,
  }) => AmrapExercise.forCreation(
    orderInSession: orderInSession,
    name: name,
    templateParameters: AmrapExerciseParameters(
      repsNumber: reps,
      weight: weight,
    ),
  );

  /// Creates an EMOM exercise with default parameters.
  static EmomExercise _createEmomExercise({
    required int orderInSession,
    required String name,
    Duration duration = const Duration(seconds: 40),
    int reps = 12,
    double weight = 30.0,
  }) => EmomExercise.forCreation(
    orderInSession: orderInSession,
    name: name,
    templateParameters: EmomExerciseParameters(
      duration: duration,
      repsNumber: reps,
      weight: weight,
    ),
  );

  /// Creates a HIIT exercise with default parameters.
  static HiitExercise _createHiitExercise({
    required int orderInSession,
    required String name,
    Duration effortDuration = const Duration(seconds: 30),
    Duration restDuration = const Duration(seconds: 15),
    double weight = 0.0,
  }) => HiitExercise.forCreation(
    orderInSession: orderInSession,
    name: name,
    templateParameters: HiitExerciseParameters(
      effortDuration: effortDuration,
      restDuration: restDuration,
      weight: weight,
    ),
  );
}
