import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:trainer_backend/models/api/create_session_log_response.dart';
import 'package:trainer_backend/models/history/exercise_log.dart';
import 'package:trainer_backend/models/history/round_log.dart';
import 'package:trainer_backend/models/history/session_log.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/history.service.dart';

class SessionLoggerScreen extends StatefulWidget {
  const SessionLoggerScreen({
    required this.session,
    super.key,
  });
  final Session session;

  @override
  State<SessionLoggerScreen> createState() => _SessionLoggerScreenState();
}

class _SessionLoggerScreenState extends State<SessionLoggerScreen> {
  // --- State Variables ---
  late final DateTime _startTime;
  late final List<Exercise> _sortedExercises;

  // Controllers for exercise performance, nested for [round][exercise]
  final List<List<Map<String, TextEditingController>>> _controllers = <List<Map<String, TextEditingController>>>[];

  // Session-specific state
  int _amrapRoundCounter = 1;
  late TextEditingController _sessionParameterController;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _sortExercises();

    // Initialize session-specific controllers based on session type
    switch (widget.session) {
      case AmrapSession s:
        _sessionParameterController = TextEditingController(text: s.duration.inMinutes.toString());
      case EmomSession s:
        _sessionParameterController = TextEditingController(text: s.roundNumber.toString());
      case HiitSession s:
        _sessionParameterController = TextEditingController(text: s.roundNumber.toString());
      case ClassicSession _:
        // No session-level parameters to control here
        _sessionParameterController = TextEditingController();
    }

    _initializeControllers();
    _sessionParameterController.addListener(_rebuildControllersForRounds);
  }

  @override
  void dispose() {
    _sessionParameterController
      ..removeListener(_rebuildControllersForRounds)
      ..dispose();

    for (final List<Map<String, TextEditingController>> roundControllers in _controllers) {
      for (final Map<String, TextEditingController> exerciseControllers in roundControllers) {
        for (final TextEditingController c in exerciseControllers.values) {
          c.dispose();
        }
      }
    }
    super.dispose();
  }

  // --- Logic Methods ---

  void _sortExercises() {
    _sortedExercises = List<Exercise>.from(
      switch (widget.session) {
        ClassicSession s => s.exercises,
        AmrapSession s => s.exercises,
        EmomSession s => s.exercises,
        HiitSession s => s.exercises,
      },
    )..sort(
        (Exercise a, Exercise b) => a.orderInSession.compareTo(b.orderInSession),
      );
  }

  void _rebuildControllersForRounds() {
    // This is called when the round number for EMOM/HIIT changes.
    setState(_initializeControllers);
  }

  void _initializeControllers() {
    // Clear and dispose previous controllers to prevent memory leaks
    for (final List<Map<String, TextEditingController>> round in _controllers) {
      for (final Map<String, TextEditingController> exercise in round) {
        for (final TextEditingController controller in exercise.values) {
          controller.dispose();
        }
      }
    }
    _controllers.clear();

    final Session session = widget.session;

    // Special handling for Classic sessions, which are set-based, not round-based.
    if (session is ClassicSession) {
      final List<Map<String, TextEditingController>> classicSetControllers = <Map<String, TextEditingController>>[];
      for (final ClassicExercise exercise in _sortedExercises.whereType<ClassicExercise>()) {
        final ClassicExerciseParameters params = exercise.objectiveParameters ?? exercise.templateParameters;
        for (final ClassicExerciseSet set in params.sets) {
          classicSetControllers.add(<String, TextEditingController>{
            'weight': TextEditingController(text: set.weight.toString()),
            'reps': TextEditingController(text: set.repsNumber.toString()),
            'restDuration': TextEditingController(text: set.restDuration.inSeconds.toString()),
          });
        }
      }
      // Add all set controllers as a single "round"
      _controllers.add(classicSetControllers);
      return;
    }

    // Generic handling for round-based sessions (AMRAP, EMOM, HIIT)
    int rounds = 1;
    if (session is EmomSession || session is HiitSession) {
      rounds = int.tryParse(_sessionParameterController.text) ?? 1;
    } else if (session is AmrapSession) {
      rounds = _amrapRoundCounter;
    }

    for (int i = 0; i < rounds; i++) {
      _controllers.add(_createControllersForOneRound());
    }
  }

  List<Map<String, TextEditingController>> _createControllersForOneRound() {
    final List<Map<String, TextEditingController>> roundControllers = <Map<String, TextEditingController>>[];

    for (final Exercise exercise in _sortedExercises) {
      final Map<String, TextEditingController> exerciseControllers = <String, TextEditingController>{};
      // This method now only handles round-based sessions.
      switch (exercise) {
        case AmrapExercise e:
          final AmrapExerciseParameters params = e.objectiveParameters ?? e.templateParameters;
          exerciseControllers['reps'] = TextEditingController(text: params.repsNumber.toString());
          exerciseControllers['weight'] = TextEditingController(text: params.weight.toString());
          break;
        case EmomExercise e:
          final EmomExerciseParameters params = e.objectiveParameters ?? e.templateParameters;
          exerciseControllers['duration'] = TextEditingController(text: params.duration.inSeconds.toString());
          exerciseControllers['reps'] = TextEditingController(text: params.repsNumber.toString());
          exerciseControllers['weight'] = TextEditingController(text: params.weight.toString());
          break;
        case HiitExercise e:
          final HiitExerciseParameters params = e.objectiveParameters ?? e.templateParameters;
          exerciseControllers['effortDuration'] = TextEditingController(
            text: params.effortDuration.inSeconds.toString(),
          );
          exerciseControllers['restDuration'] = TextEditingController(
            text: params.restDuration.inSeconds.toString(),
          );
          exerciseControllers['weight'] = TextEditingController(text: params.weight.toString());
          break;
        case ClassicExercise _:
        // This case is handled in _initializeControllers, so we do nothing.
      }
      roundControllers.add(exerciseControllers);
    }
    return roundControllers;
  }

  void _addAmrapRound() {
    setState(() {
      _amrapRoundCounter++;
      _controllers.add(_createControllersForOneRound());
    });
  }

  void _removeAmrapRound() {
    if (_amrapRoundCounter > 1) {
      setState(() {
        _amrapRoundCounter--;
        _controllers.removeLast();
      });
    }
  }

  Future<void> _finishSession() async {
    try {
      final SessionLog sessionLog = _buildSessionLog();
      log('Creating session log: ${sessionLog.toJson()}');
      final CreateSessionLogResponse response = await HistoryService.createSessionLog(sessionLog);
      final SessionLog createdLog = response.sessionLog;

      // In a real app, you would now use `response.updatedSessionPreview`
      // to show a dialog to the user, asking if they want to update their
      // session objectives with the new performance.
      log('Received updated session preview: ${response.updatedSessionPreview.toJson()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session log created successfully! ID: ${createdLog.id}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating session log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  SessionLog _buildSessionLog() {
    final Session session = widget.session;

    return switch (session) {
      AmrapSession s => () {
          final List<RoundLog<AmrapExerciseLog>> rounds = <RoundLog<AmrapExerciseLog>>[];
          for (int i = 0; i < _controllers.length; i++) {
            final List<AmrapExerciseLog> exerciseLogs = <AmrapExerciseLog>[];
            for (int j = 0; j < _sortedExercises.length; j++) {
              final Exercise exercise = _sortedExercises[j];
              final Map<String, TextEditingController> currentControllers = _controllers[i][j];
              final AmrapExerciseLog log = switch (exercise) {
                AmrapExercise e => AmrapExerciseLog.forCreation(
                    sessionExerciseId: e.id,
                    orderInRoundLog: j + 1,
                    repsNumber: int.tryParse(currentControllers['reps']!.text) ?? 0,
                    weight: double.tryParse(currentControllers['weight']!.text) ?? 0,
                  ),
                _ => throw ArgumentError('Invalid exercise type for AMRAP session'),
              };
              exerciseLogs.add(log);
            }
            rounds.add(
              RoundLog.forCreation(roundNumber: i + 1, exercises: exerciseLogs),
            );
          }
          return AmrapSessionLog.forCreation(
            sessionId: s.id,
            name: s.name,
            startedAt: _startTime,
            endedAt: DateTime.now(),
            rounds: rounds,
          );
        }(),
      EmomSession s => () {
          final List<RoundLog<EmomExerciseLog>> rounds = <RoundLog<EmomExerciseLog>>[];
          for (int i = 0; i < _controllers.length; i++) {
            final List<EmomExerciseLog> exerciseLogs = <EmomExerciseLog>[];
            for (int j = 0; j < _sortedExercises.length; j++) {
              final Exercise exercise = _sortedExercises[j];
              final Map<String, TextEditingController> currentControllers = _controllers[i][j];
              final EmomExerciseLog log = switch (exercise) {
                EmomExercise e => EmomExerciseLog.forCreation(
                    sessionExerciseId: e.id,
                    orderInRoundLog: j + 1,
                    duration: Duration(
                      seconds: int.tryParse(currentControllers['duration']!.text) ?? 0,
                    ),
                    repsNumber: int.tryParse(currentControllers['reps']!.text) ?? 0,
                    weight: double.tryParse(currentControllers['weight']!.text) ?? 0,
                  ),
                _ => throw ArgumentError('Invalid exercise type for EMOM session'),
              };
              exerciseLogs.add(log);
            }
            rounds.add(
              RoundLog.forCreation(roundNumber: i + 1, exercises: exerciseLogs),
            );
          }
          return EmomSessionLog.forCreation(
            sessionId: s.id,
            name: s.name,
            startedAt: _startTime,
            endedAt: DateTime.now(),
            rounds: rounds,
          );
        }(),
      HiitSession s => () {
          final List<RoundLog<HiitExerciseLog>> rounds = <RoundLog<HiitExerciseLog>>[];
          for (int i = 0; i < _controllers.length; i++) {
            final List<HiitExerciseLog> exerciseLogs = <HiitExerciseLog>[];
            for (int j = 0; j < _sortedExercises.length; j++) {
              final Exercise exercise = _sortedExercises[j];
              final Map<String, TextEditingController> currentControllers = _controllers[i][j];
              final HiitExerciseLog log = switch (exercise) {
                HiitExercise e => HiitExerciseLog.forCreation(
                    sessionExerciseId: e.id,
                    orderInRoundLog: j + 1,
                    effortDuration: Duration(
                      seconds: int.tryParse(currentControllers['effortDuration']!.text) ?? 0,
                    ),
                    restDuration: Duration(
                      seconds: int.tryParse(currentControllers['restDuration']!.text) ?? 0,
                    ),
                    weight: double.tryParse(currentControllers['weight']!.text) ?? 0,
                  ),
                _ => throw ArgumentError('Invalid exercise type for HIIT session'),
              };
              exerciseLogs.add(log);
            }
            rounds.add(
              RoundLog.forCreation(roundNumber: i + 1, exercises: exerciseLogs),
            );
          }
          return HiitSessionLog.forCreation(
            sessionId: s.id,
            name: s.name,
            startedAt: _startTime,
            endedAt: DateTime.now(),
            rounds: rounds,
          );
        }(),
      ClassicSession() => _buildClassicSessionLog(),
    };
  }

  // ClassicSession has a different structure (sets) and is handled separately.
  ClassicSessionLog _buildClassicSessionLog() {
    int controllerIndex = 0;
    final List<ClassicExerciseLog> exerciseLogs = <ClassicExerciseLog>[];

    final List<ClassicExercise> classicExercises = _sortedExercises.whereType<ClassicExercise>().toList();
    for (int exerciseIdx = 0; exerciseIdx < classicExercises.length; exerciseIdx++) {
      final ClassicExercise exercise = classicExercises[exerciseIdx];
      final List<SetLog> sets = <SetLog>[];
      final ClassicExerciseParameters params = exercise.objectiveParameters ?? exercise.templateParameters;
      for (int i = 0; i < params.sets.length; i++) {
        final double weight = double.tryParse(_controllers[0][controllerIndex]['weight']!.text) ?? 0.0;
        final int reps = int.tryParse(
              _controllers[0][controllerIndex]['reps']!.text,
            ) ??
            0;
        final int rest = int.tryParse(_controllers[0][controllerIndex]['restDuration']!.text) ?? 0;
        sets.add(SetLog(number: i + 1, reps: reps, weight: weight, restDuration: Duration(seconds: rest)));
        controllerIndex++;
      }
      exerciseLogs.add(
        ClassicExerciseLog.forCreation(
          sessionExerciseId: exercise.id,
          orderInRoundLog: exerciseIdx + 1,
          sets: sets,
        ),
      );
    }
    final RoundLog<ClassicExerciseLog> roundLog = RoundLog<ClassicExerciseLog>.forCreation(
      roundNumber: 1,
      exercises: exerciseLogs,
    );

    return ClassicSessionLog.forCreation(
      sessionId: widget.session.id,
      name: widget.session.name,
      startedAt: _startTime,
      endedAt: DateTime.now(),
      rounds: <RoundLog<ClassicExerciseLog>>[roundLog],
    );
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Log: ${widget.session.name}'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _finishSession,
              tooltip: 'Finish Session',
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            _buildSessionParameters(),
            Expanded(child: _buildBody()),
          ],
        ),
      );

  Widget _buildSessionParameters() {
    switch (widget.session) {
      case AmrapSession _:
        return _AmrapParameters(
          durationController: _sessionParameterController,
          roundCounter: _amrapRoundCounter,
          onAddRound: _addAmrapRound,
          onRemoveRound: _removeAmrapRound,
        );
      case EmomSession _:
      case HiitSession _:
        return _EmomHiitParameters(
          roundController: _sessionParameterController,
        );
      case ClassicSession _:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody() {
    if (widget.session is ClassicSession) {
      return _buildClassicSessionLogger(
        widget.session as ClassicSession,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _controllers.length,
      itemBuilder: (BuildContext context, int roundIndex) => _RoundCard(
        roundNumber: roundIndex + 1,
        exercises: _sortedExercises,
        controllers: _controllers[roundIndex],
      ),
    );
  }

  Widget _buildClassicSessionLogger(ClassicSession session) {
    int setControllerIndex = 0;
    // Classic session's "exercises" are sets, a bit of a different model.
    // For simplicity, we'll reuse the logger list view for exercises.
    return ListView.builder(
      itemCount: _sortedExercises.length,
      itemBuilder: (BuildContext context, int exerciseIndex) {
        final Exercise currentExercise = _sortedExercises[exerciseIndex];
        if (currentExercise is! ClassicExercise) {
          return const SizedBox.shrink(); // Should not happen for classic session
        }
        final ClassicExercise exercise = currentExercise;
        final ClassicExerciseParameters params = exercise.objectiveParameters ?? exercise.templateParameters;
        final int startIndex = setControllerIndex;
        setControllerIndex += params.sets.length;

        // This widget is not ideal for classic, as it's exercise-based.
        // We adapt it by putting the set list inside.
        return _ExerciseLogCard(
          exerciseName: exercise.name,
          child: _ClassicSetList(
            params: params,
            // The controllers for classic are flat, in _controllers[0]
            controllers: _controllers.isNotEmpty ? _controllers[0] : <Map<String, TextEditingController>>[],
            startIndex: startIndex,
          ),
        );
      },
    );
  }
}

// --- UI Helper Widgets ---

class _AmrapParameters extends StatelessWidget {
  const _AmrapParameters({
    required this.durationController,
    required this.roundCounter,
    required this.onAddRound,
    required this.onRemoveRound,
  });

  final TextEditingController durationController;
  final int roundCounter;
  final VoidCallback onAddRound;
  final VoidCallback onRemoveRound;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _LogTextField(
                  controller: durationController,
                  labelText: 'Duration (min)',
                ),
              ),
              const SizedBox(width: 16),
              const Text('Rounds:'),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onRemoveRound,
              ),
              Text('$roundCounter', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAddRound,
              ),
            ],
          ),
        ),
      );
}

class _EmomHiitParameters extends StatelessWidget {
  const _EmomHiitParameters({required this.roundController});
  final TextEditingController roundController;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _LogTextField(
            controller: roundController,
            labelText: 'Number of Rounds',
          ),
        ),
      );
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.roundNumber,
    required this.exercises,
    required this.controllers,
  });
  final int roundNumber;
  final List<Exercise> exercises;
  final List<Map<String, TextEditingController>> controllers;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Round $roundNumber',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(),
              ...List<Widget>.generate(
                exercises.length,
                (int index) {
                  final Exercise exercise = exercises[index];
                  return _ExerciseLogCard(
                    exerciseName: exercise.name,
                    child: _buildParameterFields(exercise, controllers[index]),
                  );
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildParameterFields(
    Exercise exercise,
    Map<String, TextEditingController> currentControllers,
  ) =>
      Column(
        children: switch (exercise) {
          AmrapExercise() => <Widget>[
              _LogTextField(
                controller: currentControllers['reps']!,
                labelText: 'Reps',
              ),
              const SizedBox(height: 8),
              _LogTextField(
                controller: currentControllers['weight']!,
                labelText: 'Weight (kg)',
              ),
            ],
          EmomExercise() => <Widget>[
              _LogTextField(
                controller: currentControllers['duration']!,
                labelText: 'Duration (s)',
              ),
              const SizedBox(height: 8),
              _LogTextField(
                controller: currentControllers['reps']!,
                labelText: 'Reps',
              ),
              const SizedBox(height: 8),
              _LogTextField(
                controller: currentControllers['weight']!,
                labelText: 'Weight (kg)',
              ),
            ],
          HiitExercise() => <Widget>[
              _LogTextField(
                controller: currentControllers['effortDuration']!,
                labelText: 'Effort (s)',
              ),
              const SizedBox(height: 8),
              _LogTextField(
                controller: currentControllers['restDuration']!,
                labelText: 'Rest (s)',
              ),
              const SizedBox(height: 8),
              _LogTextField(
                controller: currentControllers['weight']!,
                labelText: 'Weight (kg)',
              ),
            ],
          ClassicExercise() => <Widget>[], // Should not happen in this path
        },
      );
}

class _ExerciseLogCard extends StatelessWidget {
  const _ExerciseLogCard({
    required this.exerciseName,
    required this.child,
  });

  final String exerciseName;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                exerciseName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
}

class _ClassicSetList extends StatelessWidget {
  const _ClassicSetList({
    required this.params,
    required this.controllers,
    required this.startIndex,
  });

  final ClassicExerciseParameters params;
  final List<Map<String, TextEditingController>> controllers;
  final int startIndex;

  @override
  Widget build(BuildContext context) => Column(
        children: List<Widget>.generate(
          params.sets.length,
          (int setIndex) {
            final int controllerIdx = startIndex + setIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Set ${setIndex + 1}:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LogTextField(
                      controller: controllers[controllerIdx]['weight']!,
                      labelText: 'Weight (kg)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LogTextField(
                      controller: controllers[controllerIdx]['reps']!,
                      labelText: 'Reps',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LogTextField(
                      controller: controllers[controllerIdx]['restDuration']!,
                      labelText: 'Rest (s)',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class _LogTextField extends StatelessWidget {
  const _LogTextField({
    required this.controller,
    required this.labelText,
  });

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
}
