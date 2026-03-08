import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/subscriptions/subscription_limits_with_usage.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/programs.service.dart';
import 'package:trainer_backend/services/subscriptions.service.dart';

import '../fixtures/test_accounts.dart';
import '../fixtures/test_programs.dart';
import 'test_setup.dart';

/// Integration tests for Free Plan subscription limits.
///
/// Tests verify that Free Plan limits are correctly enforced:
/// - 1 program maximum
/// - 2 sessions per program maximum
/// - 6 exercises per session maximum
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
  });

  group('Free Plan Limits', () {
    setUp(() async {
      await TestSetup.signInAndCleanup(supabase, TestAccounts.freeUser);
    });

    tearDown(() async {
      final String? userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // await CleanupHelper.cleanupAndSignOut(supabase, userId);
      }
    });

    test('should create 1 program successfully', () async {
      // Arrange
      final Program program = TestPrograms.createSimpleProgram(
        name: 'Free Test Program',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.id, greaterThan(0));
      expect(createdProgram.name, equals('Free Test Program'));
      expect(createdProgram.sessions.length, equals(1));

      // Verify the counter
      final SubscriptionLimitsWithUsage limits = await SubscriptionsService.getUserLimitsWithUsage();
      expect(limits.usage.programsCount, equals(1));
    });

    test('should throw SUBSCRIPTION_LIMIT_PROGRAMS on 2nd program', () async {
      // Arrange: Create the first program
      final Program program1 = TestPrograms.createSimpleProgram(
        name: 'Program 1',
      );

      await ProgramsService.createFullProgram(program1);

      // Act & Assert: Should throw exception: Attempt to create a 2nd program
      final Program program2 = TestPrograms.createSimpleProgram(
        name: 'Program 2',
      );

      expect(
        () => ProgramsService.createFullProgram(program2),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_PROGRAMS'),
          ),
        ),
      );
    });

    test('should create 2 sessions per program', () async {
      // Arrange: Create a program with 2 sessions (Free plan limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 2 sessions',
        sessionCount: 2,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(2));
    });

    test('should throw SUBSCRIPTION_LIMIT_SESSIONS on 3rd session', () async {
      // Arrange: Create a program with 2 sessions (Free plan limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 2 sessions',
        sessionCount: 2,
      );

      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Act & Assert: Should throw exception: Attempt to add a 3rd session (should fail)
      final ClassicSession newSession = TestPrograms.createClassicSession(
        name: 'Session 3',
        orderInProgram: 3,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    test('should create session with 6 exercises', () async {
      // Arrange: Create a session with 6 exercises (Free plan limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'Program with 6 exercises',
        exerciseCount: 6,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as ClassicSession).exercises.length, equals(6));
    });

    test('should throw SUBSCRIPTION_LIMIT_EXERCISES with 7 exercises', () async {
      // Arrange: Create a session with 7 exercises (exceeds Free plan limit of 6)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'Program with 7 exercises',
        exerciseCount: 7,
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on AMRAP sessions ---
    test('should create AMRAP session with 6 exercises', () async {
      // Arrange: Create an AMRAP session with 6 exercises (Free plan limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'AMRAP program with 6 exercises',
        exerciseCount: 6,
        sessionType: 'amrap',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as AmrapSession).exercises.length, equals(6));
    });

    test('should throw error with 7 exercises in AMRAP session', () async {
      // Arrange: Create an AMRAP session with 7 exercises (exceeds Free plan limit of 6)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'AMRAP program with 7 exercises',
        exerciseCount: 7,
        sessionType: 'amrap',
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on EMOM sessions ---
    test('should create EMOM session with 6 exercises', () async {
      // Arrange: Create an EMOM session with 6 exercises (Free plan limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'EMOM program with 6 exercises',
        exerciseCount: 6,
        sessionType: 'emom',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as EmomSession).exercises.length, equals(6));
    });

    test('should throw error with 7 exercises in EMOM session', () async {
      // Arrange: Create an EMOM session with 7 exercises (exceeds Free plan limit of 6)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'EMOM program with 7 exercises',
        exerciseCount: 7,
        sessionType: 'emom',
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on HIIT sessions ---
    test('should create HIIT session with 6 exercises', () async {
      // Arrange: Create a HIIT session with 6 exercises (Free plan limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'HIIT program with 6 exercises',
        exerciseCount: 6,
        sessionType: 'hiit',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as HiitSession).exercises.length, equals(6));
    });

    test('should throw error with 7 exercises in HIIT session', () async {
      // Arrange: Create a HIIT session with 7 exercises (exceeds Free plan limit of 6)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'HIIT program with 7 exercises',
        exerciseCount: 7,
        sessionType: 'hiit',
      );

      // Act & Assert: Should throw exception
      expect(
        () => ProgramsService.createFullProgram(program),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION'),
          ),
        ),
      );
    });

    // --- Tests on session limits by type ---
    test('should create 2 AMRAP sessions', () async {
      // Arrange: Create 2 AMRAP sessions (Free plan limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 2 AMRAP sessions',
        sessionCount: 2,
        sessionType: 'amrap',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(2));
      expect(createdProgram.sessions.every((Session s) => s is AmrapSession), isTrue);
    });

    test('should throw error on 3rd AMRAP session', () async {
      // Arrange: Create 2 AMRAP sessions
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 2 AMRAP sessions',
        sessionCount: 2,
        sessionType: 'amrap',
      );

      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Act & Assert: Attempt to add 3rd AMRAP session
      final AmrapSession newSession = TestPrograms.createAmrapSession(
        name: 'AMRAP Session 3',
        orderInProgram: 3,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });

    // --- Tests on mixed programs ---
    test('should create 1 Classic + 1 EMOM session (mixed)', () async {
      // Arrange: Create a mixed program with 1 Classic and 1 EMOM session
      final Program program = Program.forCreation(
        name: 'Mixed Classic + EMOM program',
        sessions: <Session>[
          TestPrograms.createClassicSession(name: 'Classic 1', orderInProgram: 0),
          TestPrograms.createEmomSession(name: 'EMOM 1', orderInProgram: 1),
        ],
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(2));
      expect(createdProgram.sessions[0], isA<ClassicSession>());
      expect(createdProgram.sessions[1], isA<EmomSession>());
    });

    test('should throw error on 3rd session in mixed program', () async {
      // Arrange: Create a mixed program with 2 sessions
      final Program program = Program.forCreation(
        name: 'Mixed program with 2 sessions',
        sessions: <Session>[
          TestPrograms.createClassicSession(name: 'Classic 1', orderInProgram: 0),
          TestPrograms.createHiitSession(name: 'HIIT 1', orderInProgram: 1),
        ],
      );

      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Act & Assert: Attempt to add 3rd session
      final AmrapSession newSession = TestPrograms.createAmrapSession(
        name: 'AMRAP Session 3',
        orderInProgram: 3,
      );

      expect(
        () => ProgramsService.addSessionToProgram(
          programId: createdProgram.id,
          session: newSession,
        ),
        throwsA(
          predicate<PostgrestException>(
            (PostgrestException e) => e.message.contains('LIMIT_EXCEEDED:MAX_SESSIONS'),
          ),
        ),
      );
    });
  });
}
