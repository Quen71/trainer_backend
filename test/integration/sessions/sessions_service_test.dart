import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/api/session_api_response.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/programs.service.dart';
import 'package:trainer_backend/services/sessions.service.dart';

import '../../fixtures/test_accounts.dart';
import '../../fixtures/test_programs.dart';
import '../test_setup.dart';

/// Integration tests for [SessionsService].
///
/// Covers [SessionsService.updateFullSession] for all 4 session types:
/// Classic, AMRAP, EMOM, and HIIT. Each test validates:
/// - Correct return of [SessionApiResponse]
/// - Name updates
/// - Exercise parameter updates
/// - Exercise rename within a session (creates a new exercise in the global
///   library if the name does not already exist; updates the session_exercises
///   link to point to the new exercise while preserving progressions)
///
/// Uses [TestAccounts.premiumUser] to avoid subscription limit interference.
///
/// IMPORTANT — concurrency:
/// A single [setUpAll] signs-in and cleans-up ONCE per file. Each test registers
/// an [addTearDown] to remove only the data it created.
/// For a fully deterministic run, prefer: flutter test test/integration/ --concurrency=1
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
    await TestSetup.signInAndCleanup(supabase, TestAccounts.premiumUser);
  });

  // ---------------------------------------------------------------------------
  // Classic
  // ---------------------------------------------------------------------------

  group('updateFullSession — Classic', () {
    test('should return a valid SessionApiResponse', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Session Update'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      final ClassicSession session = created.sessions.first as ClassicSession;

      final SessionApiResponse response = await SessionsService.updateFullSession(session);

      expect(response.programId, equals(created.id));
      expect(response.session.id, equals(session.id));
      expect(response.session, isA<ClassicSession>());
    });

    test('should update session name', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Name Update'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      final ClassicSession session = created.sessions.first as ClassicSession;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(name: 'Updated Classic Name'),
      );

      expect(response.session.name, equals('Updated Classic Name'));
      expect(response.session.id, equals(session.id));
    });

    test('should update exercise parameters (weight) within the session', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Classic Exercise Update', exerciseCount: 2),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      final ClassicSession session = created.sessions.first as ClassicSession;

      // Update all sets of every exercise to a distinctive weight
      final List<ClassicExercise> updatedExercises = session.exercises.map((ClassicExercise ex) {
        final List<ClassicExerciseSet> sets = ex.templateParameters.sets
            .map((ClassicExerciseSet s) => s.copyWith(weight: 999.0))
            .toList();
        return ex.copyWith(templateParameters: ex.templateParameters.copyWith(sets: sets));
      }).toList();

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(exercises: updatedExercises),
      );

      expect(response.session, isA<ClassicSession>());
      final ClassicSession returned = response.session as ClassicSession;
      expect(returned.exercises.length, equals(2));
      expect(
        returned.exercises.every(
          (ClassicExercise e) => e.templateParameters.sets.every((ClassicExerciseSet s) => s.weight == 999.0),
        ),
        isTrue,
      );
    });

    test('should rename an exercise within the session', () async {
      final Program created = await ProgramsService.createFullProgram(
        TestPrograms.createSimpleProgram(name: 'Program for Exercise Rename'),
      );
      addTearDown(() async => ProgramsService.deleteProgram(created.id));
      final ClassicSession session = created.sessions.first as ClassicSession;
      final ClassicExercise original = session.exercises.first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(
          exercises: <ClassicExercise>[original.copyWith(name: 'Renamed Exercise')],
        ),
      );

      expect(response.session, isA<ClassicSession>());
      final ClassicSession returned = response.session as ClassicSession;
      expect(returned.exercises.length, equals(1));
      expect(returned.exercises.first.name, equals('Renamed Exercise'));
      expect(returned.exercises.first.id, equals(original.id));
    });
  });

  // ---------------------------------------------------------------------------
  // AMRAP
  // ---------------------------------------------------------------------------

  group('updateFullSession — AMRAP', () {
    test('should update session name', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'AMRAP Program for Update',
          sessions: <Session>[TestPrograms.createAmrapSession(name: 'AMRAP Session', orderInProgram: 0)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final AmrapSession session = base.sessions.whereType<AmrapSession>().first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(name: 'Updated AMRAP Name'),
      );

      expect(response.session.id, equals(session.id));
      expect(response.session.name, equals('Updated AMRAP Name'));
      expect(response.session, isA<AmrapSession>());
    });

    test('should update exercise parameters (weight) within the session', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'AMRAP Program for Exercise Update',
          sessions: <Session>[TestPrograms.createAmrapSession(name: 'AMRAP Session', orderInProgram: 0, exerciseCount: 2)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final AmrapSession session = base.sessions.whereType<AmrapSession>().first;

      final List<AmrapExercise> updatedExercises = session.exercises
          .map((AmrapExercise ex) => ex.copyWith(
                templateParameters: ex.templateParameters.copyWith(weight: 999.0),
              ))
          .toList();

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(exercises: updatedExercises),
      );

      expect(response.session, isA<AmrapSession>());
      final AmrapSession returned = response.session as AmrapSession;
      expect(returned.exercises.length, equals(2));
      expect(returned.exercises.every((AmrapExercise e) => e.templateParameters.weight == 999.0), isTrue);
    });

    test('should rename an exercise within the session', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'AMRAP Program for Exercise Rename',
          sessions: <Session>[TestPrograms.createAmrapSession(name: 'AMRAP Session', orderInProgram: 0)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final AmrapSession session = base.sessions.whereType<AmrapSession>().first;
      final AmrapExercise original = session.exercises.first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(
          exercises: <AmrapExercise>[original.copyWith(name: 'Renamed AMRAP Exercise')],
        ),
      );

      expect(response.session, isA<AmrapSession>());
      final AmrapSession returned = response.session as AmrapSession;
      expect(returned.exercises.length, equals(1));
      expect(returned.exercises.first.name, equals('Renamed AMRAP Exercise'));
      expect(returned.exercises.first.id, equals(original.id));
    });
  });

  // ---------------------------------------------------------------------------
  // EMOM
  // ---------------------------------------------------------------------------

  group('updateFullSession — EMOM', () {
    test('should update session name', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'EMOM Program for Update',
          sessions: <Session>[TestPrograms.createEmomSession(name: 'EMOM Session', orderInProgram: 0)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final EmomSession session = base.sessions.whereType<EmomSession>().first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(name: 'Updated EMOM Name'),
      );

      expect(response.session.id, equals(session.id));
      expect(response.session.name, equals('Updated EMOM Name'));
      expect(response.session, isA<EmomSession>());
    });

    test('should update exercise parameters (weight) within the session', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'EMOM Program for Exercise Update',
          sessions: <Session>[TestPrograms.createEmomSession(name: 'EMOM Session', orderInProgram: 0, exerciseCount: 2)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final EmomSession session = base.sessions.whereType<EmomSession>().first;

      final List<EmomExercise> updatedExercises = session.exercises
          .map((EmomExercise ex) => ex.copyWith(
                templateParameters: ex.templateParameters.copyWith(weight: 999.0),
              ))
          .toList();

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(exercises: updatedExercises),
      );

      expect(response.session, isA<EmomSession>());
      final EmomSession returned = response.session as EmomSession;
      expect(returned.exercises.length, equals(2));
      expect(returned.exercises.every((EmomExercise e) => e.templateParameters.weight == 999.0), isTrue);
    });

    test('should rename an exercise within the session', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'EMOM Program for Exercise Rename',
          sessions: <Session>[TestPrograms.createEmomSession(name: 'EMOM Session', orderInProgram: 0)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final EmomSession session = base.sessions.whereType<EmomSession>().first;
      final EmomExercise original = session.exercises.first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(
          exercises: <EmomExercise>[original.copyWith(name: 'Renamed EMOM Exercise')],
        ),
      );

      expect(response.session, isA<EmomSession>());
      final EmomSession returned = response.session as EmomSession;
      expect(returned.exercises.length, equals(1));
      expect(returned.exercises.first.name, equals('Renamed EMOM Exercise'));
      expect(returned.exercises.first.id, equals(original.id));
    });
  });

  // ---------------------------------------------------------------------------
  // HIIT
  // ---------------------------------------------------------------------------

  group('updateFullSession — HIIT', () {
    test('should update session name', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'HIIT Program for Update',
          sessions: <Session>[TestPrograms.createHiitSession(name: 'HIIT Session', orderInProgram: 0)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final HiitSession session = base.sessions.whereType<HiitSession>().first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(name: 'Updated HIIT Name'),
      );

      expect(response.session.id, equals(session.id));
      expect(response.session.name, equals('Updated HIIT Name'));
      expect(response.session, isA<HiitSession>());
    });

    test('should update exercise parameters (effort duration) within the session', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'HIIT Program for Exercise Update',
          sessions: <Session>[TestPrograms.createHiitSession(name: 'HIIT Session', orderInProgram: 0, exerciseCount: 2)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final HiitSession session = base.sessions.whereType<HiitSession>().first;

      const Duration updatedEffort = Duration(seconds: 45);
      final List<HiitExercise> updatedExercises = session.exercises
          .map((HiitExercise ex) => ex.copyWith(
                templateParameters: ex.templateParameters.copyWith(effortDuration: updatedEffort),
              ))
          .toList();

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(exercises: updatedExercises),
      );

      expect(response.session, isA<HiitSession>());
      final HiitSession returned = response.session as HiitSession;
      expect(returned.exercises.length, equals(2));
      expect(
        returned.exercises.every((HiitExercise e) => e.templateParameters.effortDuration == updatedEffort),
        isTrue,
      );
    });

    test('should rename an exercise within the session', () async {
      final Program base = await ProgramsService.createFullProgram(
        Program.forCreation(
          name: 'HIIT Program for Exercise Rename',
          sessions: <Session>[TestPrograms.createHiitSession(name: 'HIIT Session', orderInProgram: 0)],
        ),
      );
      addTearDown(() async => ProgramsService.deleteProgram(base.id));
      final HiitSession session = base.sessions.whereType<HiitSession>().first;
      final HiitExercise original = session.exercises.first;

      final SessionApiResponse response = await SessionsService.updateFullSession(
        session.copyWith(
          exercises: <HiitExercise>[original.copyWith(name: 'Renamed HIIT Exercise')],
        ),
      );

      expect(response.session, isA<HiitSession>());
      final HiitSession returned = response.session as HiitSession;
      expect(returned.exercises.length, equals(1));
      expect(returned.exercises.first.name, equals('Renamed HIIT Exercise'));
      expect(returned.exercises.first.id, equals(original.id));
    });
  });
}
