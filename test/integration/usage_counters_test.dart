import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/subscriptions/subscription_limits_with_usage.dart';
import 'package:trainer_backend/models/training/enums/session_style.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/programs.service.dart';
import 'package:trainer_backend/services/subscriptions.service.dart';

import '../fixtures/test_accounts.dart';
import '../helpers/cleanup_helper.dart';
import 'test_setup.dart';

/// Integration tests for subscription usage counters.
///
/// Tests verify that usage counters are correctly tracked and updated
/// when creating programs, sessions, and exercises.
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
  });

  group('Usage Counters', () {
    setUp(() async {
      // Sign in with Free account
      await supabase.auth.signInWithPassword(
        email: TestAccounts.freeUser.email,
        password: TestAccounts.freeUser.password,
      );
    });

    tearDown(() async {
      final String? userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await CleanupHelper.cleanupAndSignOut(supabase, userId);
      }
    });

    test('should increment programs_count', () async {
      // Arrange
      final SubscriptionLimitsWithUsage before = await SubscriptionsService.getUserLimitsWithUsage();
      expect(before.usage.programsCount, equals(0));

      // Act
      final Program program = Program.forCreation(
        name: 'Programme Test',
        sessions: <Session>[
          ClassicSession.forCreation(
            name: 'Session 1',
            orderInProgram: 1,
            style: SessionStyle.weights,
            exercises: <ClassicExercise>[
              ClassicExercise.forCreation(
                orderInSession: 1,
                name: 'Squat',
                templateParameters: const ClassicExerciseParameters(
                  sets: <ClassicExerciseSet>[
                    ClassicExerciseSet(
                      orderInExercise: 1,
                      repsNumber: 10,
                      weight: 100.0,
                      restDuration: Duration(minutes: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );

      await ProgramsService.createFullProgram(program);

      // Assert
      final SubscriptionLimitsWithUsage after = await SubscriptionsService.getUserLimitsWithUsage();
      expect(after.usage.programsCount, equals(1));
    });

    test('should track sessions_count_by_program', () async {
      // Arrange
      final Program program = Program.forCreation(
        name: 'Programme avec 2 sessions',
        sessions: <Session>[
          ClassicSession.forCreation(
            name: 'Session 1',
            orderInProgram: 1,
            style: SessionStyle.weights,
            exercises: <ClassicExercise>[
              ClassicExercise.forCreation(
                orderInSession: 1,
                name: 'Squat',
                templateParameters: const ClassicExerciseParameters(
                  sets: <ClassicExerciseSet>[
                    ClassicExerciseSet(
                      orderInExercise: 1,
                      repsNumber: 10,
                      weight: 100.0,
                      restDuration: Duration(minutes: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ClassicSession.forCreation(
            name: 'Session 2',
            orderInProgram: 2,
            style: SessionStyle.weights,
            exercises: <ClassicExercise>[
              ClassicExercise.forCreation(
                orderInSession: 1,
                name: 'Bench Press',
                templateParameters: const ClassicExerciseParameters(
                  sets: <ClassicExerciseSet>[
                    ClassicExerciseSet(
                      orderInExercise: 1,
                      repsNumber: 8,
                      weight: 80.0,
                      restDuration: Duration(minutes: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );

      // Act
      final Program createdProgram = await ProgramsService.createFullProgram(program);

      // Assert
      final SubscriptionLimitsWithUsage limits = await SubscriptionsService.getUserLimitsWithUsage();
      expect(
        limits.usage.sessionsCountByProgram[createdProgram.id.toString()],
        equals(2),
      );
    });
  });
}
