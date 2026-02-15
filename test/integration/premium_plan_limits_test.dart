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

/// Integration tests for Premium Plan subscription limits.
///
/// Tests verify that Premium Plan has virtually unlimited access:
/// - Unlimited programs (999999)
/// - Unlimited sessions per program (999999)
/// - Unlimited exercises per session (999999)
///
/// Tests ensure users can exceed all Basic Plan limits without errors.
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
  });

  group('Premium Plan Limits', () {
    setUp(() async {
      await TestSetup.signInAndCleanup(supabase, TestAccounts.premiumUser);
    });

    tearDown(() async {
      final String? userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // await CleanupHelper.cleanupAndSignOut(supabase, userId);
      }
    });

    // --- Group 1: Verify limits equal 999999 ---
    test('should return 999999 for all subscription limits', () async {
      // Act
      final SubscriptionLimitsWithUsage limits = await SubscriptionsService.getUserLimitsWithUsage();

      // Assert: Verify all limits are set to 999999 (virtually unlimited)
      expect(limits.limits.maxPrograms, equals(999999));
      expect(limits.limits.maxSessionsPerProgram, equals(999999));
      expect(limits.limits.maxExercisesPerSession, equals(999999));
    });

    // --- Group 2: Exceed Basic limits (5 programs) ---
    test('should create 10 programs without error (exceeds Basic limit of 5)', () async {
      // Arrange & Act: Create 10 programs (2x Basic limit of 5)
      for (int i = 1; i <= 10; i++) {
        final Program program = TestPrograms.createSimpleProgram(
          name: 'Premium Program $i',
        );

        final Program createdProgram = await ProgramsService.createFullProgram(program);
        expect(createdProgram.id, greaterThan(0));
      }

      // Assert: Verify counter
      final SubscriptionLimitsWithUsage limits = await SubscriptionsService.getUserLimitsWithUsage();
      expect(limits.usage.programsCount, equals(10));
    });

    // --- Group 2: Exceed Basic limits (10 sessions) ---
    test('should create 20 Classic sessions in one program (exceeds Basic limit of 10)', () async {
      // Arrange: Create program with 20 Classic sessions (2x Basic limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 20 Classic sessions',
        sessionCount: 20,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(20));
      expect(createdProgram.sessions.every((Session s) => s is ClassicSession), isTrue);
    });

    test('should create 20 AMRAP sessions in one program (exceeds Basic limit of 10)', () async {
      // Arrange: Create program with 20 AMRAP sessions (2x Basic limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 20 AMRAP sessions',
        sessionCount: 20,
        sessionType: 'amrap',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(20));
      expect(createdProgram.sessions.every((Session s) => s is AmrapSession), isTrue);
    });

    test('should create 20 EMOM sessions in one program (exceeds Basic limit of 10)', () async {
      // Arrange: Create program with 20 EMOM sessions (2x Basic limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 20 EMOM sessions',
        sessionCount: 20,
        sessionType: 'emom',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(20));
      expect(createdProgram.sessions.every((Session s) => s is EmomSession), isTrue);
    });

    test('should create 20 HIIT sessions in one program (exceeds Basic limit of 10)', () async {
      // Arrange: Create program with 20 HIIT sessions (2x Basic limit)
      final Program program = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program with 20 HIIT sessions',
        sessionCount: 20,
        sessionType: 'hiit',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(20));
      expect(createdProgram.sessions.every((Session s) => s is HiitSession), isTrue);
    });

    // --- Group 2: Exceed Basic limits (15 exercises) ---
    test('should create Classic session with 30 exercises (exceeds Basic limit of 15)', () async {
      // Arrange: Create session with 30 exercises (2x Basic limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'Classic program with 30 exercises',
        exerciseCount: 30,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as ClassicSession).exercises.length, equals(30));
    });

    test('should create AMRAP session with 30 exercises (exceeds Basic limit of 15)', () async {
      // Arrange: Create AMRAP session with 30 exercises (2x Basic limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'AMRAP program with 30 exercises',
        exerciseCount: 30,
        sessionType: 'amrap',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as AmrapSession).exercises.length, equals(30));
    });

    test('should create EMOM session with 30 exercises (exceeds Basic limit of 15)', () async {
      // Arrange: Create EMOM session with 30 exercises (2x Basic limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'EMOM program with 30 exercises',
        exerciseCount: 30,
        sessionType: 'emom',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as EmomSession).exercises.length, equals(30));
    });

    test('should create HIIT session with 30 exercises (exceeds Basic limit of 15)', () async {
      // Arrange: Create HIIT session with 30 exercises (2x Basic limit)
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'HIIT program with 30 exercises',
        exerciseCount: 30,
        sessionType: 'hiit',
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as HiitSession).exercises.length, equals(30));
    });

    // --- Group 3: Representative Premium volume tests ---
    test('should create program with 50 mixed sessions (realistic Premium usage)', () async {
      // Arrange: Create program with 50 sessions of mixed types (Classic, AMRAP, EMOM, HIIT).
      final Program program = TestPrograms.createMixedSessionsProgram(
        name: 'Premium program with 50 mixed sessions',
        sessionCount: 50,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect(createdProgram.sessions.length, equals(50));
    });

    test('should create session with 50 exercises (realistic Premium usage)', () async {
      // Arrange: Create session with 50 exercises
      final Program program = TestPrograms.createProgramForExerciseLimitTest(
        name: 'Program with session of 50 exercises',
        exerciseCount: 50,
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      expect((createdProgram.sessions.first as ClassicSession).exercises.length, equals(50));
    });

    test('should create multiple complex programs without limits (complete Premium scenario)', () async {
      // Arrange & Act: Create 5 programs with 15 sessions each, each session with 20 exercises
      for (int i = 1; i <= 5; i++) {
        final Program program = TestPrograms.createProgramForSessionLimitTest(
          name: 'Complex Premium program $i',
          sessionCount: 15,
          exercisesPerSession: 20,
        );

        final Program createdProgram = await ProgramsService.createFullProgram(program);
        expect(createdProgram.sessions.length, equals(15));
        expect((createdProgram.sessions.first as ClassicSession).exercises.length, equals(20));
      }

      // Assert: Verify total count
      final SubscriptionLimitsWithUsage limits = await SubscriptionsService.getUserLimitsWithUsage();
      expect(limits.usage.programsCount, equals(5));
    });

    // --- Group 4: Verify no limit errors occur ---
    test('should never throw LIMIT_EXCEEDED errors with Premium plan', () async {
      // Arrange: Create various resources that would fail on Basic plan
      final Program program1 = TestPrograms.createProgramForExerciseLimitTest(
        name: 'Program 1 - 20 exercises',
        exerciseCount: 20,
      );

      final Program program2 = TestPrograms.createProgramForSessionLimitTest(
        name: 'Program 2 - 15 sessions',
        sessionCount: 15,
        exercisesPerSession: 20,
      );

      // Act & Assert: Should not throw any LIMIT_EXCEEDED exceptions
      final Program createdProgram1 = await ProgramsService.createFullProgram(program1);
      expect((createdProgram1.sessions.first as ClassicSession).exercises.length, equals(20));

      final Program createdProgram2 = await ProgramsService.createFullProgram(program2);
      expect(createdProgram2.sessions.length, equals(15));

      // Verify no limit errors in usage
      final SubscriptionLimitsWithUsage limits = await SubscriptionsService.getUserLimitsWithUsage();
      expect(limits.usage.programsCount, greaterThanOrEqualTo(2));
    });
  });
}
