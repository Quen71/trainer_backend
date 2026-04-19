import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/api/create_session_log_response.dart';
import 'package:trainer_backend/models/history/session_log.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/history.service.dart';
import 'package:trainer_backend/services/programs.service.dart';

import '../../fixtures/test_accounts.dart';
import '../../fixtures/test_programs.dart';
import '../../fixtures/test_session_logs.dart';
import '../test_setup.dart';

/// Integration tests for [HistoryService].
///
/// Covers [HistoryService.createSessionLog] and [HistoryService.fetchUserSessionsLogs]
/// for all 4 session/log types: Classic, AMRAP, EMOM, and HIIT.
///
/// Uses [TestAccounts.premiumUser] to avoid subscription limit interference.
/// Each test creates a program via [ProgramsService] first to obtain real
/// session and exercise IDs required by the session log RPC.
///
/// IMPORTANT — concurrency:
/// A single [setUpAll] signs-in and cleans-up ONCE per file. Each test registers
/// an [addTearDown] to remove only the data it created.
/// For a fully deterministic run, prefer: flutter test test/integration/ --concurrency=1
void main() {
  late SupabaseClient supabase;

  /// Deletes session_logs before the program to avoid the FK cascade conflict:
  /// session_logs.session_id has ON DELETE SET NULL on the sessions FK, but the
  /// column also has a NOT NULL constraint, so the cascade would fail if logs exist.
  Future<void> deleteProgramWithLogs(int programId) async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('session_logs').delete().eq('user_id', userId);
    }
    await ProgramsService.deleteProgram(programId);
  }

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
    await TestSetup.signInAndCleanup(supabase, TestAccounts.premiumUser);
  });

  // ---------------------------------------------------------------------------
  // createSessionLog
  // ---------------------------------------------------------------------------

  group('createSessionLog', () {
    test(
      'should create a Classic session log and return a valid response',
      () async {
        final Program program = await ProgramsService.createFullProgram(
          TestPrograms.createSimpleProgram(name: 'Program for Classic Log'),
        );
        addTearDown(() async => deleteProgramWithLogs(program.id));
        final ClassicSession session = program.sessions.first as ClassicSession;
        final Exercise exercise = session.exercises.first;

        final CreateSessionLogResponse response =
            await HistoryService.createSessionLog(
              TestSessionLogs.createClassicSessionLog(
                sessionId: session.id,
                sessionExerciseId: exercise.id,
              ),
            );

        expect(response.sessionLog.id, greaterThan(0));
        expect(response.sessionLog.sessionId, equals(session.id));
        expect(response.sessionLog, isA<ClassicSessionLog>());
      },
    );

    test('should return an updatedSessionPreview in the response', () async {
      final Program program = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Preview Test'),
      );
      addTearDown(() async => deleteProgramWithLogs(program.id));
      final ClassicSession session = program.sessions.first as ClassicSession;
      final Exercise exercise = session.exercises.first;

      final CreateSessionLogResponse response =
          await HistoryService.createSessionLog(
            TestSessionLogs.createClassicSessionLog(
              sessionId: session.id,
              sessionExerciseId: exercise.id,
            ),
          );

      expect(response.updatedSessionPreview.id, equals(session.id));
    });

    test('should create an AMRAP session log', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'Program for AMRAP Log',
          sessions: <Session>[
            TestPrograms.createAmrapSession(
              name: 'AMRAP Session',
              orderInProgram: 0,
            ),
          ],
        ),
      );
      addTearDown(() async => deleteProgramWithLogs(base.id));
      final AmrapSession session = base.sessions
          .whereType<AmrapSession>()
          .first;
      final Exercise exercise = session.exercises.first;

      final CreateSessionLogResponse response =
          await HistoryService.createSessionLog(
            TestSessionLogs.createAmrapSessionLog(
              sessionId: session.id,
              sessionExerciseId: exercise.id,
              roundCount: 4,
            ),
          );

      expect(response.sessionLog.id, greaterThan(0));
      expect(response.sessionLog.sessionId, equals(session.id));
      expect(response.sessionLog, isA<AmrapSessionLog>());
    });

    test('should create an EMOM session log', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'Program for EMOM Log',
          sessions: <Session>[
            TestPrograms.createEmomSession(
              name: 'EMOM Session',
              orderInProgram: 0,
            ),
          ],
        ),
      );
      addTearDown(() async => deleteProgramWithLogs(base.id));
      final EmomSession session = base.sessions.whereType<EmomSession>().first;
      final Exercise exercise = session.exercises.first;

      final CreateSessionLogResponse response =
          await HistoryService.createSessionLog(
            TestSessionLogs.createEmomSessionLog(
              sessionId: session.id,
              sessionExerciseId: exercise.id,
              roundCount: 10,
            ),
          );

      expect(response.sessionLog.id, greaterThan(0));
      expect(response.sessionLog.sessionId, equals(session.id));
      expect(response.sessionLog, isA<EmomSessionLog>());
    });

    test('should create a HIIT session log', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'Program for HIIT Log',
          sessions: <Session>[
            TestPrograms.createHiitSession(
              name: 'HIIT Session',
              orderInProgram: 0,
            ),
          ],
        ),
      );
      addTearDown(() async => deleteProgramWithLogs(base.id));
      final HiitSession session = base.sessions.whereType<HiitSession>().first;
      final Exercise exercise = session.exercises.first;

      final CreateSessionLogResponse response =
          await HistoryService.createSessionLog(
            TestSessionLogs.createHiitSessionLog(
              sessionId: session.id,
              sessionExerciseId: exercise.id,
              roundCount: 8,
            ),
          );

      expect(response.sessionLog.id, greaterThan(0));
      expect(response.sessionLog.sessionId, equals(session.id));
      expect(response.sessionLog, isA<HiitSessionLog>());
    });

    test('should increment log count after creation', () async {
      final Program program = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Count Test'),
      );
      addTearDown(() async => deleteProgramWithLogs(program.id));
      final ClassicSession session = program.sessions.first as ClassicSession;
      final Exercise exercise = session.exercises.first;

      await HistoryService.createSessionLog(
        TestSessionLogs.createClassicSessionLog(
          sessionId: session.id,
          sessionExerciseId: exercise.id,
        ),
      );
      await HistoryService.createSessionLog(
        TestSessionLogs.createClassicSessionLog(
          sessionId: session.id,
          sessionExerciseId: exercise.id,
        ),
      );

      // Filter by sessionId to be resilient against logs from concurrent test files.
      final List<SessionLog> logs = await HistoryService.fetchUserSessionsLogs(
        page: 0,
      );
      final List<SessionLog> ours = logs
          .where((SessionLog l) => l.sessionId == session.id)
          .toList();
      expect(ours.length, equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // fetchUserSessionsLogs
  // ---------------------------------------------------------------------------

  group('fetchUserSessionsLogs', () {
    test('should return empty list when no logs exist', () async {
      final List<SessionLog> logs = await HistoryService.fetchUserSessionsLogs(
        page: 0,
      );
      expect(logs, isEmpty);
    });

    test('should return created logs on page 0', () async {
      final Program program = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Fetch Test'),
      );
      addTearDown(() async => deleteProgramWithLogs(program.id));
      final ClassicSession session = program.sessions.first as ClassicSession;
      final Exercise exercise = session.exercises.first;

      await HistoryService.createSessionLog(
        TestSessionLogs.createClassicSessionLog(
          sessionId: session.id,
          sessionExerciseId: exercise.id,
        ),
      );

      final List<SessionLog> logs = await HistoryService.fetchUserSessionsLogs(
        page: 0,
      );

      // Filter by sessionId to be resilient against logs from concurrent test files.
      final List<SessionLog> ours = logs
          .where((SessionLog l) => l.sessionId == session.id)
          .toList();
      expect(ours.length, equals(1));
      expect(ours.first.id, greaterThan(0));
      expect(ours.first, isA<ClassicSessionLog>());
    });

    test('should correctly deserialize all 4 log types', () async {
      // Arrange: Create a mixed-type program and one log per session type
      final Program program = await ProgramsService.createFullProgram(
        TestPrograms.createMixedTypeProgram(
          name: 'Program for Multi-Type Fetch',
        ),
      );
      addTearDown(() async => deleteProgramWithLogs(program.id));

      final ClassicSession classic = program.sessions
          .whereType<ClassicSession>()
          .first;
      final AmrapSession amrap = program.sessions
          .whereType<AmrapSession>()
          .first;
      final EmomSession emom = program.sessions.whereType<EmomSession>().first;
      final HiitSession hiit = program.sessions.whereType<HiitSession>().first;

      await HistoryService.createSessionLog(
        TestSessionLogs.createClassicSessionLog(
          sessionId: classic.id,
          sessionExerciseId: classic.exercises.first.id,
        ),
      );
      await HistoryService.createSessionLog(
        TestSessionLogs.createAmrapSessionLog(
          sessionId: amrap.id,
          sessionExerciseId: amrap.exercises.first.id,
        ),
      );
      await HistoryService.createSessionLog(
        TestSessionLogs.createEmomSessionLog(
          sessionId: emom.id,
          sessionExerciseId: emom.exercises.first.id,
        ),
      );
      await HistoryService.createSessionLog(
        TestSessionLogs.createHiitSessionLog(
          sessionId: hiit.id,
          sessionExerciseId: hiit.exercises.first.id,
        ),
      );

      // Act: Fetch all logs and filter to those from this test's program
      final List<SessionLog> all = await HistoryService.fetchUserSessionsLogs(
        page: 0,
      );
      final Set<int> ourSessionIds = <int>{
        classic.id,
        amrap.id,
        emom.id,
        hiit.id,
      };
      final List<SessionLog> ours = all
          .where((SessionLog l) => ourSessionIds.contains(l.sessionId))
          .toList();

      // Assert: All 4 types are present and deserialized correctly
      expect(ours.length, equals(4));
      expect(ours.whereType<ClassicSessionLog>().length, equals(1));
      expect(ours.whereType<AmrapSessionLog>().length, equals(1));
      expect(ours.whereType<EmomSessionLog>().length, equals(1));
      expect(ours.whereType<HiitSessionLog>().length, equals(1));
    });

    test('should return empty list for out-of-bounds page', () async {
      final Program program = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Pagination Test'),
      );
      addTearDown(() async => deleteProgramWithLogs(program.id));
      final ClassicSession session = program.sessions.first as ClassicSession;
      final Exercise exercise = session.exercises.first;

      await HistoryService.createSessionLog(
        TestSessionLogs.createClassicSessionLog(
          sessionId: session.id,
          sessionExerciseId: exercise.id,
        ),
      );

      final List<SessionLog> logs = await HistoryService.fetchUserSessionsLogs(
        page: 1,
      );
      expect(logs, isEmpty);
    });

    test('should respect pageSize parameter', () async {
      final Program program = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for PageSize Test'),
      );
      addTearDown(() async => deleteProgramWithLogs(program.id));
      final ClassicSession session = program.sessions.first as ClassicSession;
      final Exercise exercise = session.exercises.first;

      for (int i = 0; i < 4; i++) {
        await HistoryService.createSessionLog(
          TestSessionLogs.createClassicSessionLog(
            sessionId: session.id,
            sessionExerciseId: exercise.id,
          ),
        );
      }

      final List<SessionLog> page0 = await HistoryService.fetchUserSessionsLogs(
        page: 0,
        pageSize: 2,
      );
      final List<SessionLog> page1 = await HistoryService.fetchUserSessionsLogs(
        page: 1,
        pageSize: 2,
      );

      expect(page0.length, equals(2));
      expect(page1.length, greaterThanOrEqualTo(2));
      final List<SessionLog> allFetched = <SessionLog>[...page0, ...page1];
      final List<SessionLog> ours = allFetched
          .where((SessionLog l) => l.sessionId == session.id)
          .toList();
      expect(ours.length, equals(4));
    });
  });
}
