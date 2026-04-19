import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/programs.service.dart';

import '../../fixtures/test_accounts.dart';
import '../../fixtures/test_programs.dart';
import '../test_setup.dart';

/// Integration tests for [ProgramsService].
///
/// Covers the full CRUD lifecycle of programs and sessions across all 4 session
/// types (Classic, AMRAP, EMOM, HIIT):
/// - [ProgramsService.createFullProgram]
/// - [ProgramsService.fetchUserPrograms]
/// - [ProgramsService.updateFullProgram]
/// - [ProgramsService.addSessionToProgram]
/// - [ProgramsService.deleteSession]
/// - [ProgramsService.deleteProgram]
/// - [ProgramsService.addProgramToFavorites]
/// - [ProgramsService.removeProgramFromFavorites]
///
/// Uses [TestAccounts.premiumUser] to avoid subscription limit interference.
///
/// IMPORTANT — concurrency:
/// These tests share [TestAccounts.premiumUser] with other integration test files.
/// A single [setUpAll] signs-in and cleans-up ONCE per file. Each test registers
/// an [addTearDown] to remove only the data it created, reducing cross-file
/// interference when tests run in parallel (e.g. Cursor Test Explorer).
/// For a fully deterministic run, prefer: flutter test test/integration/ --concurrency=1
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
    await TestSetup.signInAndCleanup(supabase, TestAccounts.premiumUser);
  });

  // ---------------------------------------------------------------------------
  // createFullProgram
  // ---------------------------------------------------------------------------

  group('createFullProgram', () {
    test('should create a program with a Classic session', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Classic Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      expect(created.id, greaterThan(0));
      expect(created.sessions.length, equals(1));
      final ClassicSession session = created.sessions
          .whereType<ClassicSession>()
          .first;
      expect(session.id, greaterThan(0));
      expect(session.exercises.first.id, greaterThan(0));
    });

    test('should create a program with an AMRAP session', () async {
      final Program created = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'AMRAP Program',
          sessions: <Session>[
            TestPrograms.createAmrapSession(
              name: 'AMRAP Session',
              orderInProgram: 0,
            ),
          ],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      expect(created.id, greaterThan(0));
      expect(created.sessions.length, equals(1));
      final AmrapSession session = created.sessions
          .whereType<AmrapSession>()
          .first;
      expect(session.id, greaterThan(0));
      expect(session.exercises.first.id, greaterThan(0));
    });

    test('should create a program with an EMOM session', () async {
      final Program created = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'EMOM Program',
          sessions: <Session>[
            TestPrograms.createEmomSession(
              name: 'EMOM Session',
              orderInProgram: 0,
            ),
          ],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      expect(created.id, greaterThan(0));
      expect(created.sessions.length, equals(1));
      final EmomSession session = created.sessions
          .whereType<EmomSession>()
          .first;
      expect(session.id, greaterThan(0));
      expect(session.roundNumber, equals(10));
      expect(session.exercises.first.id, greaterThan(0));
    });

    test('should create a program with a HIIT session', () async {
      final Program created = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'HIIT Program',
          sessions: <Session>[
            TestPrograms.createHiitSession(
              name: 'HIIT Session',
              orderInProgram: 0,
            ),
          ],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      expect(created.id, greaterThan(0));
      expect(created.sessions.length, equals(1));
      final HiitSession session = created.sessions
          .whereType<HiitSession>()
          .first;
      expect(session.id, greaterThan(0));
      expect(session.roundNumber, equals(8));
      expect(session.exercises.first.id, greaterThan(0));
    });

    test(
      'should create a program with mixed session types and deserialize all correctly',
      () async {
        final Program created = await ProgramsService.createFullProgram(
          TestPrograms.createMixedTypeProgram(name: 'Mixed Program'),
        );
        addTearDown(() async => ProgramsService.deleteProgram(created.id));

        expect(created.id, greaterThan(0));
        expect(created.sessions.length, equals(4));
        expect(created.sessions.whereType<ClassicSession>().length, equals(1));
        expect(created.sessions.whereType<AmrapSession>().length, equals(1));
        expect(created.sessions.whereType<EmomSession>().length, equals(1));
        expect(created.sessions.whereType<HiitSession>().length, equals(1));
        expect(created.sessions.every((Session s) => s.id > 0), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // fetchUserPrograms
  // ---------------------------------------------------------------------------

  group('fetchUserPrograms', () {
    test('should return empty list when no programs exist', () async {
      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 0,
      );
      expect(programs, isEmpty);
    });

    test('should return created programs on page 0', () async {
      final Program a = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program A'),
      );
      final Program b = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program B'),
      );
      addTearDown(() async {
        await ProgramsService.deleteProgram(a.id);
        await ProgramsService.deleteProgram(b.id);
      });

      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 0,
      );

      // Filter by name so the test is resilient to extra programs created by
      // concurrent test files that share the same premiumUser account.
      final List<Program> ours = programs
          .where((Program p) => p.name == 'Program A' || p.name == 'Program B')
          .toList();
      expect(ours.length, equals(2));
      expect(ours.every((Program p) => p.id > 0), isTrue);
    });

    test('should deserialize all 4 session types correctly', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createMixedTypeProgram(name: 'Fetch Mixed Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 0,
      );

      final Program fetched = programs.firstWhere(
        (Program p) => p.id == created.id,
      );
      expect(fetched.sessions.whereType<ClassicSession>().length, equals(1));
      expect(fetched.sessions.whereType<AmrapSession>().length, equals(1));
      expect(fetched.sessions.whereType<EmomSession>().length, equals(1));
      expect(fetched.sessions.whereType<HiitSession>().length, equals(1));
    });

    test('should return empty list for out-of-bounds page', () async {
      final Program p = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program A'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(p.id));

      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 1,
        pageSize: 5,
      );
      expect(programs, isEmpty);
    });

    test('should respect pageSize parameter', () async {
      final List<Program> created = <Program>[];
      for (int i = 1; i <= 4; i++) {
        created.add(
          await ProgramsService.createFullProgram(
            TestPrograms.createSimpleProgram(name: 'PageSize-$i'),
          ),
        );
      }
      addTearDown(() async {
        for (final Program p in created) {
          await ProgramsService.deleteProgram(p.id);
        }
      });

      final List<Program> page0 = await ProgramsService.fetchUserPrograms(
        page: 0,
        pageSize: 2,
      );
      final List<Program> page1 = await ProgramsService.fetchUserPrograms(
        page: 1,
        pageSize: 2,
      );

      expect(page0.length, equals(2));
      expect(page1.length, greaterThanOrEqualTo(2));
      final List<Program> allFetched = <Program>[...page0, ...page1];
      for (final Program p in created) {
        expect(allFetched.any((Program f) => f.id == p.id), isTrue);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // updateFullProgram
  // ---------------------------------------------------------------------------

  group('updateFullProgram', () {
    test('should update program name', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Original Name'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Program updated = await ProgramsService.updateFullProgram(
        created.copyWith(name: 'Updated Name'),
      );

      expect(updated.id, equals(created.id));
      expect(updated.name, equals('Updated Name'));
    });

    test('should update program description', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'My Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Program updated = await ProgramsService.updateFullProgram(
        created.copyWith(description: 'A brand new description'),
      );

      expect(updated.description, equals('A brand new description'));
    });

    test('should update session order with Classic sessions', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createProgramWithMultipleSessions(
          name: 'Program with 2 sessions',
          sessionCount: 2,
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Session session0 = created.sessions[0];
      final Session session1 = created.sessions[1];

      final Program updated = await ProgramsService.updateFullProgram(
        created.copyWith(
          sessions: <Session>[_withOrder(session1, 0), _withOrder(session0, 1)],
        ),
      );

      // The RPC may return sessions in insertion order, so look up by ID.
      expect(updated.sessions.length, equals(2));
      final Session returned0 = updated.sessions.firstWhere(
        (Session s) => s.id == session0.id,
      );
      final Session returned1 = updated.sessions.firstWhere(
        (Session s) => s.id == session1.id,
      );
      expect(returned0.orderInProgram, equals(1));
      expect(returned1.orderInProgram, equals(0));
    });

    test('should update session order with mixed session types', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createMixedTypeProgram(name: 'Mixed Order Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      // Reverse the order of all 4 sessions
      final List<Session> reversed = created.sessions
          .asMap()
          .entries
          .map(
            (MapEntry<int, Session> e) =>
                _withOrder(e.value, created.sessions.length - 1 - e.key),
          )
          .toList();

      final Program updated = await ProgramsService.updateFullProgram(
        created.copyWith(sessions: reversed),
      );

      expect(updated.sessions.length, equals(4));
      // Verify each session has its new orderInProgram value
      for (final Session s in reversed) {
        final Session returned = updated.sessions.firstWhere(
          (Session r) => r.id == s.id,
        );
        expect(returned.orderInProgram, equals(s.orderInProgram));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // addSessionToProgram
  // ---------------------------------------------------------------------------

  group('addSessionToProgram', () {
    test('should add a Classic session to an existing program', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Base Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      final int initialCount = created.sessions.length;

      final Program updated = await ProgramsService.addSessionToProgram(
        programId: created.id,
        session: TestPrograms.createClassicSession(
          name: 'New Classic Session',
          orderInProgram: initialCount,
        ),
      );

      expect(updated.sessions.length, equals(initialCount + 1));
      final ClassicSession added = updated.sessions
          .whereType<ClassicSession>()
          .firstWhere((ClassicSession s) => s.name == 'New Classic Session');
      expect(added.id, greaterThan(0));
    });

    test('should add an AMRAP session to an existing program', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Base Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Program updated = await ProgramsService.addSessionToProgram(
        programId: created.id,
        session: TestPrograms.createAmrapSession(
          name: 'New AMRAP Session',
          orderInProgram: created.sessions.length,
        ),
      );

      final AmrapSession added = updated.sessions
          .whereType<AmrapSession>()
          .firstWhere((AmrapSession s) => s.name == 'New AMRAP Session');
      expect(added.id, greaterThan(0));
    });

    test('should add an EMOM session to an existing program', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Base Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Program updated = await ProgramsService.addSessionToProgram(
        programId: created.id,
        session: TestPrograms.createEmomSession(
          name: 'New EMOM Session',
          orderInProgram: created.sessions.length,
        ),
      );

      final EmomSession added = updated.sessions
          .whereType<EmomSession>()
          .firstWhere((EmomSession s) => s.name == 'New EMOM Session');
      expect(added.id, greaterThan(0));
      expect(added.roundNumber, equals(10));
    });

    test('should add a HIIT session to an existing program', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Base Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Program updated = await ProgramsService.addSessionToProgram(
        programId: created.id,
        session: TestPrograms.createHiitSession(
          name: 'New HIIT Session',
          orderInProgram: created.sessions.length,
        ),
      );

      final HiitSession added = updated.sessions
          .whereType<HiitSession>()
          .firstWhere((HiitSession s) => s.name == 'New HIIT Session');
      expect(added.id, greaterThan(0));
      expect(added.roundNumber, equals(8));
    });

    test('should add multiple sessions in sequence', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Base Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      Program current = created;
      for (int i = 0; i < 3; i++) {
        current = await ProgramsService.addSessionToProgram(
          programId: current.id,
          session: TestPrograms.createClassicSession(
            name: 'Session ${current.sessions.length + 1}',
            orderInProgram: current.sessions.length,
          ),
        );
      }

      expect(current.sessions.length, equals(4));
    });
  });

  // ---------------------------------------------------------------------------
  // deleteSession
  // ---------------------------------------------------------------------------

  group('deleteSession', () {
    test(
      'should delete a Classic session and return the updated program',
      () async {
        final Program created = await ProgramsService.createFullProgram(
          TestPrograms.createProgramWithMultipleSessions(
            name: 'Program with 2 sessions',
            sessionCount: 2,
          ),
        );
        addTearDown(() async => ProgramsService.deleteProgram(created.id));
        final int sessionToDeleteId = created.sessions.first.id;

        final Program updated = await ProgramsService.deleteSession(
          sessionToDeleteId,
        );

        expect(updated.id, equals(created.id));
        expect(updated.sessions.length, equals(1));
        expect(
          updated.sessions.any((Session s) => s.id == sessionToDeleteId),
          isFalse,
        );
      },
    );

    test(
      'should delete an AMRAP session and return the updated program',
      () async {
        final Program created = await ProgramsService.createFullProgram(
          Program.forCreation(
            name: 'Program with AMRAP',
            sessions: <Session>[
              TestPrograms.createClassicSession(
                name: 'Classic Session',
                orderInProgram: 0,
              ),
              TestPrograms.createAmrapSession(
                name: 'AMRAP To Delete',
                orderInProgram: 1,
              ),
            ],
          ),
        );
        addTearDown(() async => ProgramsService.deleteProgram(created.id));
        final AmrapSession toDelete = created.sessions
            .whereType<AmrapSession>()
            .first;

        final Program updated = await ProgramsService.deleteSession(
          toDelete.id,
        );

        expect(updated.sessions.length, equals(1));
        expect(updated.sessions.whereType<AmrapSession>(), isEmpty);
        expect(updated.sessions.first, isA<ClassicSession>());
      },
    );

    test(
      'should delete an EMOM session and return the updated program',
      () async {
        final Program created = await ProgramsService.createFullProgram(
          Program.forCreation(
            name: 'Program with EMOM',
            sessions: <Session>[
              TestPrograms.createClassicSession(
                name: 'Classic Session',
                orderInProgram: 0,
              ),
              TestPrograms.createEmomSession(
                name: 'EMOM To Delete',
                orderInProgram: 1,
              ),
            ],
          ),
        );
        addTearDown(() async => ProgramsService.deleteProgram(created.id));
        final EmomSession toDelete = created.sessions
            .whereType<EmomSession>()
            .first;

        final Program updated = await ProgramsService.deleteSession(
          toDelete.id,
        );

        expect(updated.sessions.length, equals(1));
        expect(updated.sessions.whereType<EmomSession>(), isEmpty);
      },
    );

    test(
      'should delete a HIIT session and return the updated program',
      () async {
        final Program created = await ProgramsService.createFullProgram(
          Program.forCreation(
            name: 'Program with HIIT',
            sessions: <Session>[
              TestPrograms.createClassicSession(
                name: 'Classic Session',
                orderInProgram: 0,
              ),
              TestPrograms.createHiitSession(
                name: 'HIIT To Delete',
                orderInProgram: 1,
              ),
            ],
          ),
        );
        addTearDown(() async => ProgramsService.deleteProgram(created.id));
        final HiitSession toDelete = created.sessions
            .whereType<HiitSession>()
            .first;

        final Program updated = await ProgramsService.deleteSession(
          toDelete.id,
        );

        expect(updated.sessions.length, equals(1));
        expect(updated.sessions.whereType<HiitSession>(), isEmpty);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // deleteProgram
  // ---------------------------------------------------------------------------

  group('deleteProgram', () {
    test('should delete a program and return its ID', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program to Delete'),
      );

      final int deletedId = await ProgramsService.deleteProgram(created.id);

      expect(deletedId, equals(created.id));
      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 0,
      );
      expect(programs.any((Program p) => p.id == created.id), isFalse);
    });

    test('should delete all sessions along with the program', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createProgramWithMultipleSessions(
          name: 'Program with 3 sessions',
          sessionCount: 3,
        ),
      );

      await ProgramsService.deleteProgram(created.id);

      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 0,
      );
      expect(programs.any((Program p) => p.id == created.id), isFalse);
    });

    test('should delete a mixed-type program', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createMixedTypeProgram(name: 'Mixed Program to Delete'),
      );

      final int deletedId = await ProgramsService.deleteProgram(created.id);

      expect(deletedId, equals(created.id));
      final List<Program> programs = await ProgramsService.fetchUserPrograms(
        page: 0,
      );
      expect(programs.any((Program p) => p.id == created.id), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // addProgramToFavorites / removeProgramFromFavorites
  // ---------------------------------------------------------------------------

  group('addProgramToFavorites', () {
    test('should mark a program as favorite', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program to Favorite'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      expect(created.isFavorite, isFalse);

      final Program favorited = await ProgramsService.addProgramToFavorites(
        created.id,
      );

      expect(favorited.id, equals(created.id));
      expect(favorited.isFavorite, isTrue);
    });
  });

  group('removeProgramFromFavorites', () {
    test('should unmark a program as favorite', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program to Unfavorite'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      await ProgramsService.addProgramToFavorites(created.id);

      final Program unfavorited =
          await ProgramsService.removeProgramFromFavorites(created.id);

      expect(unfavorited.id, equals(created.id));
      expect(unfavorited.isFavorite, isFalse);
    });

    test('should toggle favorites correctly (add then remove)', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Toggle Favorite Program'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));

      final Program afterAdd = await ProgramsService.addProgramToFavorites(
        created.id,
      );
      expect(afterAdd.isFavorite, isTrue);

      final Program afterRemove =
          await ProgramsService.removeProgramFromFavorites(created.id);
      expect(afterRemove.isFavorite, isFalse);
    });
  });
}

/// Returns a copy of [session] with its [orderInProgram] updated.
Session _withOrder(Session session, int order) => switch (session) {
  ClassicSession() => session.copyWith(orderInProgram: order),
  AmrapSession() => session.copyWith(orderInProgram: order),
  EmomSession() => session.copyWith(orderInProgram: order),
  HiitSession() => session.copyWith(orderInProgram: order),
};
