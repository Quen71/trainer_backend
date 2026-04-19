import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/subscriptions/subscription_limits_with_usage.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/programs.service.dart';
import 'package:trainer_backend/services/subscriptions.service.dart';

import '../../fixtures/test_accounts.dart';
import '../../fixtures/test_programs.dart';
import '../test_setup.dart';

/// Integration tests for Basic Plan subscription limits.
///
/// Tests verify that Basic Plan limits are correctly enforced:
/// - 5 programs maximum
/// - 10 sessions per program maximum
/// - 15 exercises per session maximum
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
  });

  group('Basic Plan Limits', () {
    setUp(() async {
      await TestSetup.signInAndCleanup(supabase, TestAccounts.basicUser);
    });

    tearDown(() async {
      final String? userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // await CleanupHelper.cleanupAndSignOut(supabase, userId);
      }
    });

    test('should create 5 programs successfully', () async {
      // Arrange & Act: Create 5 programs (Basic plan limit)
      for (int i = 1; i <= 5; i++) {
        final Program program = TestPrograms.createSimpleProgram(
          name: 'Basic Program $i',
        );

        final Program createdProgram = await ProgramsService.createFullProgram(
          program,
        );
        expect(createdProgram.id, greaterThan(0));
      }

      // Assert: Verify the counter
      final SubscriptionLimitsWithUsage limits =
          await SubscriptionsService.getUserLimitsWithUsage();
      expect(limits.usage.programsCount, equals(5));
    });

    test('should throw SUBSCRIPTION_LIMIT_PROGRAMS on 6th program', () async {
      // Arrange: Create 5 programs (Basic plan limit)
      for (int i = 1; i <= 5; i++) {
        final Program program = TestPrograms.createSimpleProgram(
          name: 'Program $i',
        );
        await ProgramsService.createFullProgram(program);
      }

      // Act & Assert: Attempt to create 6th program (should throw)
      final Program program6 = TestPrograms.createSimpleProgram(
        name: 'Program 6',
      );

      expect(
        () => ProgramsService.createFullProgram(program6),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_PROGRAMS'),
          ),
        ),
      );
    });

    test('should create 10 sessions per program', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 sessions',
        sessionCount: 10,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(createdProgram.sessions.length, equals(10));
    });

    test('should throw SUBSCRIPTION_LIMIT_SESSIONS on 11th session', () async {
      // Arrange: Create program with 10 sessions
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 sessions',
        sessionCount: 10,
      );

      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Act & Assert: Attempt to add 11th session (should throw)
      final ClassicSession newSession = TestPrograms.createClassicSession(
        name: 'Extra Session',
        orderInProgram: 11,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    test('should create session with 15 exercises', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'Program with 15 exercises',
        exerciseCount: 15,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(
        (createdProgram.sessions.first as ClassicSession).exercises.length,
        equals(15),
      );
    });

    test(
      'should throw SUBSCRIPTION_LIMIT_EXERCISES with 16 exercises',
      () async {
        // Arrange
        final Program program = TestPrograms.createProgramForExerciseLimitTest(
          name: 'Program with 16 exercises',
          exerciseCount: 16,
        );

        // Act & Assert: Should throw exception
        expect(
          () => ProgramsService.createFullProgram(program),
          throwsA(
            predicate<PostgrestException>(
              (PostgrestException e) => e.message.contains(
                'LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION',
              ),
            ),
          ),
        );
      },
    );

    // --- Tests on AMRAP sessions ---
    test('should create AMRAP session with 15 exercises', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'AMRAP program with 15 exercises',
        exerciseCount: 15,
        sessionType: 'amrap',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(
        (createdProgram.sessions.first as AmrapSession).exercises.length,
        equals(15),
      );
    });

    test('should throw error with 16 exercises in AMRAP session', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'AMRAP program with 16 exercises',
        exerciseCount: 16,
        sessionType: 'amrap',
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on EMOM sessions ---
    test('should create EMOM session with 15 exercises', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'EMOM program with 15 exercises',
        exerciseCount: 15,
        sessionType: 'emom',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(
        (createdProgram.sessions.first as EmomSession).exercises.length,
        equals(15),
      );
    });

    test('should throw error with 16 exercises in EMOM session', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'EMOM program with 16 exercises',
        exerciseCount: 16,
        sessionType: 'emom',
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on HIIT sessions ---
    test('should create HIIT session with 15 exercises', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'HIIT program with 15 exercises',
        exerciseCount: 15,
        sessionType: 'hiit',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(
        (createdProgram.sessions.first as HiitSession).exercises.length,
        equals(15),
      );
    });

    test('should throw error with 16 exercises in HIIT session', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'HIIT program with 16 exercises',
        exerciseCount: 16,
        sessionType: 'hiit',
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on session limits by type ---
    test('should create 10 AMRAP sessions', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 AMRAP sessions',
        sessionCount: 10,
        sessionType: 'amrap',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(createdProgram.sessions.length, equals(10));
      expect(
        createdProgram.sessions.every((Session s) => s is AmrapSession),
        isTrue,
      );
    });

    test('should throw error on 11th AMRAP session', () async {
      // Arrange: Create 10 AMRAP sessions
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 AMRAP sessions',
        sessionCount: 10,
        sessionType: 'amrap',
      );

      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Act & Assert: Attempt to add 11th AMRAP session
      final AmrapSession newSession = TestPrograms.createAmrapSession(
        name: 'AMRAP Session 11',
        orderInProgram: 11,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    test('should create 10 EMOM sessions', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 EMOM sessions',
        sessionCount: 10,
        sessionType: 'emom',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(createdProgram.sessions.length, equals(10));
      expect(
        createdProgram.sessions.every((Session s) => s is EmomSession),
        isTrue,
      );
    });

    test('should throw error on 11th EMOM session', () async {
      // Arrange: Create 10 EMOM sessions
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 EMOM sessions',
        sessionCount: 10,
        sessionType: 'emom',
      );

      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Act & Assert: Attempt to add 11th EMOM session
      final EmomSession newSession = TestPrograms.createEmomSession(
        name: 'EMOM Session 11',
        orderInProgram: 11,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    test('should create 10 HIIT sessions', () async {
      // Arrange
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 HIIT sessions',
        sessionCount: 10,
        sessionType: 'hiit',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Assert
      expect(createdProgram.sessions.length, equals(10));
      expect(
        createdProgram.sessions.every((Session s) => s is HiitSession),
        isTrue,
      );
    });

    test('should throw error on 11th HIIT session', () async {
      // Arrange: Create 10 HIIT sessions
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 10 HIIT sessions',
        sessionCount: 10,
        sessionType: 'hiit',
      );

      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Act & Assert: Attempt to add 11th HIIT session
      final HiitSession newSession = TestPrograms.createHiitSession(
        name: 'HIIT Session 11',
        orderInProgram: 11,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    // --- Tests on mixed programs ---
    test(
      'should create 10 mixed sessions (Classic + AMRAP + EMOM + HIIT)',
      () async {
        // Arrange: Create a program with 10 sessions of mixed types
        final Program program = Program.forCreation(
          name: 'Mixed program with 10 sessions',
          sessions: <Session>[
            TestPrograms.createClassicSession(
              name: 'Classic 1',
              orderInProgram: 0,
            ),
            TestPrograms.createAmrapSession(name: 'AMRAP 1', orderInProgram: 1),
            TestPrograms.createEmomSession(name: 'EMOM 1', orderInProgram: 2),
            TestPrograms.createHiitSession(name: 'HIIT 1', orderInProgram: 3),
            TestPrograms.createClassicSession(
              name: 'Classic 2',
              orderInProgram: 4,
            ),
            TestPrograms.createAmrapSession(name: 'AMRAP 2', orderInProgram: 5),
            TestPrograms.createEmomSession(name: 'EMOM 2', orderInProgram: 6),
            TestPrograms.createHiitSession(name: 'HIIT 2', orderInProgram: 7),
            TestPrograms.createClassicSession(
              name: 'Classic 3',
              orderInProgram: 8,
            ),
            TestPrograms.createAmrapSession(name: 'AMRAP 3', orderInProgram: 9),
          ],
        );

        // Act
        final Program createdProgram = await ProgramsService.createFullProgram(
          program,
        );

        // Assert
        expect(createdProgram.sessions.length, equals(10));
      },
    );

    test('should throw error on 11th session in mixed program', () async {
      // Arrange: Create a program with 10 mixed sessions
      final Program program = Program.forCreation(
        name: 'Mixed program with 10 sessions',
        sessions: <Session>[
          TestPrograms.createClassicSession(
            name: 'Classic 1',
            orderInProgram: 0,
          ),
          TestPrograms.createAmrapSession(name: 'AMRAP 1', orderInProgram: 1),
          TestPrograms.createEmomSession(name: 'EMOM 1', orderInProgram: 2),
          TestPrograms.createHiitSession(name: 'HIIT 1', orderInProgram: 3),
          TestPrograms.createClassicSession(
            name: 'Classic 2',
            orderInProgram: 4,
          ),
          TestPrograms.createAmrapSession(name: 'AMRAP 2', orderInProgram: 5),
          TestPrograms.createEmomSession(name: 'EMOM 2', orderInProgram: 6),
          TestPrograms.createHiitSession(name: 'HIIT 2', orderInProgram: 7),
          TestPrograms.createClassicSession(
            name: 'Classic 3',
            orderInProgram: 8,
          ),
          TestPrograms.createAmrapSession(name: 'AMRAP 3', orderInProgram: 9),
        ],
      );

      final Program createdProgram = await ProgramsService.createFullProgram(
        program,
      );

      // Act & Assert: Attempt to add 11th session
      final ClassicSession newSession = TestPrograms.createClassicSession(
        name: 'Extra Session',
        orderInProgram: 11,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) =>
                e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    test(
      'should enforce 15 exercises limit on each session type in mixed program',
      () async {
        // Arrange: Create a mixed program where each session has 15 exercises
        final Program program = Program.forCreation(
          name: 'Mixed program with exercise limits',
          sessions: <Session>[
            TestPrograms.createClassicSession(
              name: 'Classic',
              orderInProgram: 0,
              exerciseCount: 15,
            ),
            TestPrograms.createAmrapSession(
              name: 'AMRAP',
              orderInProgram: 1,
              exerciseCount: 15,
            ),
            TestPrograms.createEmomSession(
              name: 'EMOM',
              orderInProgram: 2,
              exerciseCount: 15,
            ),
            TestPrograms.createHiitSession(
              name: 'HIIT',
              orderInProgram: 3,
              exerciseCount: 15,
            ),
          ],
        );

        // Act
        final Program createdProgram = await ProgramsService.createFullProgram(
          program,
        );

        // Assert
        expect(createdProgram.sessions.length, equals(4));
        expect(
          (createdProgram.sessions[0] as ClassicSession).exercises.length,
          equals(15),
        );
        expect(
          (createdProgram.sessions[1] as AmrapSession).exercises.length,
          equals(15),
        );
        expect(
          (createdProgram.sessions[2] as EmomSession).exercises.length,
          equals(15),
        );
        expect(
          (createdProgram.sessions[3] as HiitSession).exercises.length,
          equals(15),
        );

        // Verify that creating a session with 16 exercises fails
        final Program programWithTooManyExercises = Program.forCreation(
          name: 'Program with too many exercises',
          sessions: <Session>[
            TestPrograms.createAmrapSession(
              name: 'AMRAP',
              orderInProgram: 0,
              exerciseCount: 16,
            ),
          ],
        );

        expect(
          () => ProgramsService.createFullProgram(programWithTooManyExercises),
          throwsA(
            predicate<PostgrestException>(
              (PostgrestException e) => e.message.contains(
                'LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION',
              ),
            ),
          ),
        );
      },
    );
  });
}
