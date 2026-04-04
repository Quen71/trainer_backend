import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:trainer_backend/models/api/session_api_response.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/sessions.service.dart';
import 'package:trainer_backend_example/session_logger.screen.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.session});

  final Session session;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late Session _session;
  late List<Exercise> _sortedExercises;

  // For renaming session
  late TextEditingController _sessionNameController;
  bool _isEditingSessionName = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _sessionNameController = TextEditingController(text: _session.name);
    _sortExercises();
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  void _sortExercises() {
    _sortedExercises = List<Exercise>.from(
      switch (_session) {
        ClassicSession s => s.exercises,
        AmrapSession s => s.exercises,
        EmomSession s => s.exercises,
        HiitSession s => s.exercises
      },
    )..sort((Exercise a, Exercise b) => a.orderInSession.compareTo(b.orderInSession));
  }

  Future<void> _updateSessionInBackend() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final SessionApiResponse response = await SessionsService.updateFullSession(_session);
      if (!mounted) return;

      setState(() {
        // Update the local session with the authoritative response from the server.
        _session = response.session;
        // Re-sort the exercises based on the new session data to update the UI.
        _sortExercises();
        _sessionNameController.text = _session.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      log(
        name: 'API Error',
        'Failed to update session: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditingSessionName = false; // Exit editing mode on save/error
        });
      }
    }
  }

  void _saveSessionName() {
    if (_sessionNameController.text.isEmpty || _sessionNameController.text == _session.name) {
      setState(() {
        _isEditingSessionName = false;
      });
      return;
    }
    setState(() {
      _session = switch (_session) {
        ClassicSession s => s.copyWith(name: _sessionNameController.text),
        AmrapSession s => s.copyWith(name: _sessionNameController.text),
        EmomSession s => s.copyWith(name: _sessionNameController.text),
        HiitSession s => s.copyWith(name: _sessionNameController.text),
      };
    });
    _updateSessionInBackend();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Exercise item = _sortedExercises.removeAt(oldIndex);
      _sortedExercises.insert(newIndex, item);

      final List<Exercise> reorderedExercises = <Exercise>[];
      for (int i = 0; i < _sortedExercises.length; i++) {
        final Exercise exercise = _sortedExercises[i];
        reorderedExercises.add(
          switch (exercise) {
            ClassicExercise e => e.copyWith(
                orderInSession: i,
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
            AmrapExercise e => e.copyWith(
                orderInSession: i,
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
            EmomExercise e => e.copyWith(
                orderInSession: i,
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
            HiitExercise e => e.copyWith(
                orderInSession: i,
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
          },
        );
      }

      _sortedExercises = reorderedExercises;

      _session = switch (_session) {
        ClassicSession s => s.copyWith(exercises: _sortedExercises.cast<ClassicExercise>()),
        AmrapSession s => s.copyWith(exercises: _sortedExercises.cast<AmrapExercise>()),
        EmomSession s => s.copyWith(exercises: _sortedExercises.cast<EmomExercise>()),
        HiitSession s => s.copyWith(exercises: _sortedExercises.cast<HiitExercise>()),
      };
    });
    _updateSessionInBackend();
  }

  Future<void> _confirmDeleteExercise(int index) async {
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this exercise?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (didConfirm == true) {
      setState(() {
        _sortedExercises.removeAt(index);
        // After removing, we must re-calculate the order of the remaining exercises.
        final List<Exercise> reorderedExercises = <Exercise>[];
        for (int i = 0; i < _sortedExercises.length; i++) {
          final Exercise exercise = _sortedExercises[i];
          reorderedExercises.add(
            switch (exercise) {
              ClassicExercise e => e.copyWith(orderInSession: i),
              AmrapExercise e => e.copyWith(orderInSession: i),
              EmomExercise e => e.copyWith(orderInSession: i),
              HiitExercise e => e.copyWith(orderInSession: i),
            },
          );
        }
        _sortedExercises = reorderedExercises;

        _session = switch (_session) {
          ClassicSession s => s.copyWith(exercises: _sortedExercises.cast<ClassicExercise>()),
          AmrapSession s => s.copyWith(exercises: _sortedExercises.cast<AmrapExercise>()),
          EmomSession s => s.copyWith(exercises: _sortedExercises.cast<EmomExercise>()),
          HiitSession s => s.copyWith(exercises: _sortedExercises.cast<HiitExercise>()),
        };
      });
      _updateSessionInBackend();
    }
  }

  void _editExercise(Exercise exercise) async {
    final Exercise? updatedExercise = await showDialog<Exercise>(
      context: context,
      builder: (BuildContext context) => _EditExerciseDialog(exercise: exercise),
    );

    if (updatedExercise != null) {
      setState(() {
        final int index = _sortedExercises.indexWhere((Exercise e) => e.id == updatedExercise.id);
        if (index != -1) {
          _sortedExercises[index] = updatedExercise;
          final List<Exercise> newExercisesList = List<Exercise>.from(_sortedExercises);
          _session = switch (_session) {
            ClassicSession s => s.copyWith(exercises: newExercisesList.cast<ClassicExercise>()),
            AmrapSession s => s.copyWith(exercises: newExercisesList.cast<AmrapExercise>()),
            EmomSession s => s.copyWith(exercises: newExercisesList.cast<EmomExercise>()),
            HiitSession s => s.copyWith(exercises: newExercisesList.cast<HiitExercise>()),
          };
        }
      });
      _updateSessionInBackend();
    }
  }

  Future<void> _addExercise() async {
    final Exercise? newExerciseFromDialog = await showDialog<Exercise>(
      context: context,
      builder: (BuildContext context) => _AddExerciseDialog(session: _session),
    );

    if (newExerciseFromDialog != null) {
      final Exercise exerciseWithOrder = switch (newExerciseFromDialog) {
        ClassicExercise e => e.copyWith(
            orderInSession: _sortedExercises.length,
            templateParameters: e.templateParameters,
            objectiveParameters: e.objectiveParameters,
          ),
        AmrapExercise e => e.copyWith(
            orderInSession: _sortedExercises.length,
            templateParameters: e.templateParameters,
            objectiveParameters: e.objectiveParameters,
          ),
        EmomExercise e => e.copyWith(
            orderInSession: _sortedExercises.length,
            templateParameters: e.templateParameters,
            objectiveParameters: e.objectiveParameters,
          ),
        HiitExercise e => e.copyWith(
            orderInSession: _sortedExercises.length,
            templateParameters: e.templateParameters,
            objectiveParameters: e.objectiveParameters,
          ),
      };

      final List<Exercise> newExercisesList = List<Exercise>.from(_sortedExercises)..add(exerciseWithOrder);
      final List<Exercise> updatedExercisesWithParameters = <Exercise>[];
      for (final Exercise exercise in newExercisesList) {
        updatedExercisesWithParameters.add(
          switch (exercise) {
            ClassicExercise e => e.copyWith(
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
            AmrapExercise e => e.copyWith(
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
            EmomExercise e => e.copyWith(
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
            HiitExercise e => e.copyWith(
                templateParameters: e.templateParameters,
                objectiveParameters: e.objectiveParameters,
              ),
          },
        );
      }

      setState(() {
        _sortedExercises = updatedExercisesWithParameters;
        _session = switch (_session) {
          ClassicSession s => s.copyWith(exercises: _sortedExercises.cast<ClassicExercise>()),
          AmrapSession s => s.copyWith(exercises: _sortedExercises.cast<AmrapExercise>()),
          EmomSession s => s.copyWith(exercises: _sortedExercises.cast<EmomExercise>()),
          HiitSession s => s.copyWith(exercises: _sortedExercises.cast<HiitExercise>()),
        };
      });

      final Map<String, dynamic> sessionJsonSend = _session.toJson();

      log(
        name: 'API SEND',
        'sessionJsonSend testing add exercise: ${jsonEncode(sessionJsonSend)}',
      );

      _updateSessionInBackend();
    }
  }

  Future<void> _editSessionParameters() async {
    final Session? updatedSession = await showDialog<Session>(
      context: context,
      builder: (BuildContext context) => _EditSessionParametersDialog(session: _session),
    );

    if (updatedSession != null && updatedSession != _session) {
      setState(() {
        _session = updatedSession;
      });
      _updateSessionInBackend();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: _isEditingSessionName
              ? TextField(
                  controller: _sessionNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Session Name',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _saveSessionName(),
                )
              : Text(_session.name),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => SessionLoggerScreen(session: _session),
                  ),
                );
              },
              tooltip: 'Start Session',
            ),
            if (_isEditingSessionName)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveSessionName,
              )
            else
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditingSessionName = true;
                  });
                },
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addExercise,
          child: const Icon(Icons.add),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                if (_session is! ClassicSession)
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: _buildSessionParameters(_session),
                      trailing: const Icon(Icons.edit),
                      onTap: _editSessionParameters,
                    ),
                  ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    itemCount: _sortedExercises.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Exercise exercise = _sortedExercises[index];
                      return Card(
                        key: ValueKey<int>(exercise.id),
                        child: ListTile(
                          leading: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                          isThreeLine: true,
                          title: Text(exercise.name),
                          subtitle: _buildExerciseParameters(exercise),
                          onTap: () => _editExercise(exercise),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircleAvatar(
                                child: Text('${exercise.orderInSession}'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteExercise(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    onReorder: _onReorder,
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      );

  Widget _buildSessionParameters(Session session) {
    if (session is AmrapSession) {
      return Text('AMRAP for ${session.duration.inMinutes} minutes');
    }
    if (session is EmomSession) {
      return Text('EMOM - ${session.roundNumber} rounds');
    }
    if (session is HiitSession) {
      return Text('HIIT - ${session.roundNumber} rounds');
    }
    return const SizedBox.shrink();
  }

  Widget _buildExerciseParameters(Exercise exercise) {
    if (exercise is ClassicExercise) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: exercise.templateParameters.sets.asMap().entries.map((MapEntry<int, ClassicExerciseSet> entry) {
          final int setIndex = entry.key;
          final ClassicExerciseSet set = entry.value;
          final String weight =
              set.weight == set.weight.truncate() ? set.weight.truncate().toString() : set.weight.toString();
          return Text(
            'Set ${setIndex + 1}: ${set.repsNumber} reps, ${weight}kg, rest ${set.restDuration.inSeconds}s',
          );
        }).toList(),
      );
    }
    if (exercise is AmrapExercise) {
      final AmrapExerciseParameters params = exercise.templateParameters;
      return Text('Reps: ${params.repsNumber}, Weight: ${params.weight}kg');
    }
    if (exercise is EmomExercise) {
      final EmomExerciseParameters params = exercise.templateParameters;
      return Text('Every ${params.duration.inSeconds}s | Reps: ${params.repsNumber}, Weight: ${params.weight}kg');
    }
    if (exercise is HiitExercise) {
      final HiitExerciseParameters params = exercise.templateParameters;
      return Text(
        'Effort: ${params.effortDuration.inSeconds}s, Rest: ${params.restDuration.inSeconds}s, Weight: ${params.weight}kg',
      );
    }
    return const Text('No parameters defined');
  }
}

class _EditSessionParametersDialog extends StatefulWidget {
  const _EditSessionParametersDialog({required this.session});

  final Session session;

  @override
  State<_EditSessionParametersDialog> createState() => _EditSessionParametersDialogState();
}

class _EditSessionParametersDialogState extends State<_EditSessionParametersDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _durationController;
  late TextEditingController _roundNumberController;

  @override
  void initState() {
    super.initState();
    switch (widget.session) {
      case AmrapSession s:
        _durationController = TextEditingController(text: s.duration.inMinutes.toString());
      case EmomSession s:
        _roundNumberController = TextEditingController(text: s.roundNumber.toString());
      case HiitSession s:
        _roundNumberController = TextEditingController(text: s.roundNumber.toString());
      case ClassicSession _:
        break;
    }
  }

  @override
  void dispose() {
    switch (widget.session) {
      case AmrapSession _:
        _durationController.dispose();
      case EmomSession _:
      case HiitSession _:
        _roundNumberController.dispose();
      case ClassicSession _:
        break;
    }
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Session? updatedSession;
      switch (widget.session) {
        case AmrapSession s:
          updatedSession = s.copyWith(
            duration: Duration(minutes: int.parse(_durationController.text)),
          );
        case EmomSession s:
          updatedSession = s.copyWith(
            roundNumber: int.parse(_roundNumberController.text),
          );
        case HiitSession s:
          updatedSession = s.copyWith(
            roundNumber: int.parse(_roundNumberController.text),
          );
        case ClassicSession _:
          break;
      }
      Navigator.of(context).pop(updatedSession);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Edit Session Parameters'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildFields(),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      );

  List<Widget> _buildFields() {
    switch (widget.session) {
      case AmrapSession _:
        return <Widget>[
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value == null || value.isEmpty ? 'Required' : null,
          ),
        ];
      case EmomSession _:
      case HiitSession _:
        return <Widget>[
          TextFormField(
            controller: _roundNumberController,
            decoration: const InputDecoration(labelText: 'Rounds'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value == null || value.isEmpty ? 'Required' : null,
          ),
        ];
      case ClassicSession _:
        return <Widget>[];
    }
  }
}

class _EditExerciseDialog extends StatefulWidget {
  const _EditExerciseDialog({required this.exercise});

  final Exercise exercise;

  @override
  _EditExerciseDialogState createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<_EditExerciseDialog> {
  late Exercise _exercise;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;

  // Controllers for different exercise types
  // Template
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _durationController;
  late TextEditingController _effortDurationController;
  late TextEditingController _restDurationController;
  // Objective
  late TextEditingController _objRepsController;
  late TextEditingController _objWeightController;
  late TextEditingController _objDurationController;
  late TextEditingController _objEffortDurationController;
  late TextEditingController _objRestDurationController;

  // State for ClassicExercise sets
  late List<ClassicExerciseSet> _templateSets;
  late List<ClassicExerciseSet> _objectiveSets;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: _exercise.name);

    // Initialize controllers based on exercise type
    switch (_exercise) {
      case ClassicExercise e:
        _templateSets = List<ClassicExerciseSet>.from(e.templateParameters.sets);
        _objectiveSets = e.objectiveParameters != null
            ? List<ClassicExerciseSet>.from(e.objectiveParameters!.sets)
            : <ClassicExerciseSet>[];
        break;
      case AmrapExercise e:
        _repsController = TextEditingController(text: e.templateParameters.repsNumber.toString());
        _weightController = TextEditingController(text: e.templateParameters.weight.toString());
        _objRepsController = TextEditingController(text: e.objectiveParameters?.repsNumber.toString() ?? '');
        _objWeightController = TextEditingController(text: e.objectiveParameters?.weight.toString() ?? '');
        break;
      case EmomExercise e:
        _durationController = TextEditingController(text: e.templateParameters.duration.inSeconds.toString());
        _repsController = TextEditingController(text: e.templateParameters.repsNumber.toString());
        _weightController = TextEditingController(text: e.templateParameters.weight.toString());
        _objDurationController =
            TextEditingController(text: e.objectiveParameters?.duration.inSeconds.toString() ?? '');
        _objRepsController = TextEditingController(text: e.objectiveParameters?.repsNumber.toString() ?? '');
        _objWeightController = TextEditingController(text: e.objectiveParameters?.weight.toString() ?? '');
        break;
      case HiitExercise e:
        _effortDurationController =
            TextEditingController(text: e.templateParameters.effortDuration.inSeconds.toString());
        _restDurationController = TextEditingController(text: e.templateParameters.restDuration.inSeconds.toString());
        _weightController = TextEditingController(text: e.templateParameters.weight.toString());
        _objEffortDurationController =
            TextEditingController(text: e.objectiveParameters?.effortDuration.inSeconds.toString() ?? '');
        _objRestDurationController =
            TextEditingController(text: e.objectiveParameters?.restDuration.inSeconds.toString() ?? '');
        _objWeightController = TextEditingController(text: e.objectiveParameters?.weight.toString() ?? '');
        break;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();

    switch (widget.exercise) {
      case ClassicExercise _:
        break;
      case AmrapExercise _:
        _repsController.dispose();
        _weightController.dispose();
        _objRepsController.dispose();
        _objWeightController.dispose();
        break;
      case EmomExercise _:
        _durationController.dispose();
        _repsController.dispose();
        _weightController.dispose();
        _objDurationController.dispose();
        _objRepsController.dispose();
        _objWeightController.dispose();
        break;
      case HiitExercise _:
        _effortDurationController.dispose();
        _restDurationController.dispose();
        _weightController.dispose();
        _objEffortDurationController.dispose();
        _objRestDurationController.dispose();
        _objWeightController.dispose();
        break;
    }
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Exercise updatedExercise = switch (_exercise) {
        ClassicExercise e => () {
            final List<ClassicExerciseSet> finalTemplateSets = <ClassicExerciseSet>[];
            for (int i = 0; i < _templateSets.length; i++) {
              finalTemplateSets.add(_templateSets[i].copyWith(orderInExercise: i + 1));
            }
            final List<ClassicExerciseSet> finalObjectiveSets = <ClassicExerciseSet>[];
            for (int i = 0; i < _objectiveSets.length; i++) {
              finalObjectiveSets.add(_objectiveSets[i].copyWith(orderInExercise: i + 1));
            }
            return ClassicExercise(
              id: e.id,
              exerciseId: e.exerciseId,
              name: _nameController.text,
              orderInSession: e.orderInSession,
              templateParameters: ClassicExerciseParameters(sets: finalTemplateSets),
              objectiveParameters:
                  finalObjectiveSets.isNotEmpty ? ClassicExerciseParameters(sets: finalObjectiveSets) : null,
            );
          }(),
        AmrapExercise e => AmrapExercise(
            id: e.id,
            exerciseId: e.exerciseId,
            name: _nameController.text,
            orderInSession: e.orderInSession,
            templateParameters: AmrapExerciseParameters(
              repsNumber: int.parse(_repsController.text),
              weight: double.parse(_weightController.text),
            ),
            objectiveParameters: _objRepsController.text.isNotEmpty && _objWeightController.text.isNotEmpty
                ? AmrapExerciseParameters(
                    repsNumber: int.parse(_objRepsController.text),
                    weight: double.parse(_objWeightController.text),
                  )
                : null,
          ),
        EmomExercise e => EmomExercise(
            id: e.id,
            exerciseId: e.exerciseId,
            name: _nameController.text,
            orderInSession: e.orderInSession,
            templateParameters: EmomExerciseParameters(
              duration: Duration(seconds: int.parse(_durationController.text)),
              repsNumber: int.parse(_repsController.text),
              weight: double.parse(_weightController.text),
            ),
            objectiveParameters: _objDurationController.text.isNotEmpty &&
                    _objRepsController.text.isNotEmpty &&
                    _objWeightController.text.isNotEmpty
                ? EmomExerciseParameters(
                    duration: Duration(seconds: int.parse(_objDurationController.text)),
                    repsNumber: int.parse(_objRepsController.text),
                    weight: double.parse(_objWeightController.text),
                  )
                : null,
          ),
        HiitExercise e => HiitExercise(
            id: e.id,
            exerciseId: e.exerciseId,
            name: _nameController.text,
            orderInSession: e.orderInSession,
            templateParameters: HiitExerciseParameters(
              effortDuration: Duration(seconds: int.parse(_effortDurationController.text)),
              restDuration: Duration(seconds: int.parse(_restDurationController.text)),
              weight: double.parse(_weightController.text),
            ),
            objectiveParameters: _objEffortDurationController.text.isNotEmpty &&
                    _objRestDurationController.text.isNotEmpty &&
                    _objWeightController.text.isNotEmpty
                ? HiitExerciseParameters(
                    effortDuration: Duration(seconds: int.parse(_objEffortDurationController.text)),
                    restDuration: Duration(seconds: int.parse(_objRestDurationController.text)),
                    weight: double.parse(_objWeightController.text),
                  )
                : null,
          ),
      };

      Navigator.of(context).pop(updatedExercise);
    }
  }

  Future<void> _editSetDialog(
    ClassicExerciseSet? setToEdit,
    ValueChanged<ClassicExerciseSet> onSave,
  ) async {
    final ClassicExerciseSet? result = await showDialog<ClassicExerciseSet>(
      context: context,
      builder: (BuildContext context) => _EditSetDialog(set: setToEdit),
    );
    if (result != null) {
      onSave(result);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (String? value) => value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                ..._buildParameterFields(),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      );

  List<Widget> _buildParameterFields() {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;

    switch (widget.exercise) {
      case ClassicExercise _:
        return <Widget>[
          _buildSetList(
            title: 'Template Sets',
            sets: _templateSets,
            onSetAdded: () {
              _editSetDialog(null, (ClassicExerciseSet newSet) {
                setState(() => _templateSets.add(newSet));
              });
            },
            onSetEdited: (int index) {
              _editSetDialog(_templateSets[index], (ClassicExerciseSet updatedSet) {
                setState(() => _templateSets[index] = updatedSet);
              });
            },
            onSetDeleted: (int index) {
              setState(() => _templateSets.removeAt(index));
            },
          ),
          const Divider(height: 24),
          _buildSetList(
            title: 'Objective Sets',
            sets: _objectiveSets,
            onSetAdded: () {
              _editSetDialog(null, (ClassicExerciseSet newSet) {
                setState(() => _objectiveSets.add(newSet));
              });
            },
            onSetEdited: (int index) {
              _editSetDialog(_objectiveSets[index], (ClassicExerciseSet updatedSet) {
                setState(() => _objectiveSets[index] = updatedSet);
              });
            },
            onSetDeleted: (int index) {
              setState(() => _objectiveSets.removeAt(index));
            },
          ),
        ];
      case AmrapExercise _:
        return <Widget>[
          Text('Template', style: titleStyle),
          TextFormField(
            controller: _repsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          const Divider(height: 24),
          Text('Objective', style: titleStyle),
          TextFormField(
            controller: _objRepsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _objWeightController,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
        ];
      case EmomExercise _:
        return <Widget>[
          Text('Template', style: titleStyle),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: 'Every... (seconds)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _repsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          const Divider(height: 24),
          Text('Objective', style: titleStyle),
          TextFormField(
            controller: _objDurationController,
            decoration: const InputDecoration(labelText: 'Every... (seconds)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _objRepsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _objWeightController,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
        ];
      case HiitExercise _:
        return <Widget>[
          Text('Template', style: titleStyle),
          TextFormField(
            controller: _effortDurationController,
            decoration: const InputDecoration(labelText: 'Effort (seconds)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _restDurationController,
            decoration: const InputDecoration(labelText: 'Rest (seconds)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          const Divider(height: 24),
          Text('Objective', style: titleStyle),
          TextFormField(
            controller: _objEffortDurationController,
            decoration: const InputDecoration(labelText: 'Effort (seconds)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _objRestDurationController,
            decoration: const InputDecoration(labelText: 'Rest (seconds)'),
            keyboardType: TextInputType.number,
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _objWeightController,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (String? value) => value!.isEmpty ? 'Required' : null,
          ),
        ];
    }
  }

  Widget _buildSetList({
    required String title,
    required List<ClassicExerciseSet> sets,
    required VoidCallback onSetAdded,
    required void Function(int) onSetEdited,
    required void Function(int) onSetDeleted,
  }) {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title, style: titleStyle),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: onSetAdded,
            ),
          ],
        ),
        if (sets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('No sets defined.'),
          )
        else
          Column(
            children: sets.asMap().entries.map((MapEntry<int, ClassicExerciseSet> entry) {
              final int index = entry.key;
              final ClassicExerciseSet set = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('Set ${index + 1}'),
                  subtitle: Text('${set.repsNumber} reps, ${set.weight}kg, rest ${set.restDuration.inSeconds}s'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => onSetEdited(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => onSetDeleted(index),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  const _AddExerciseDialog({required this.session});

  final Session session;

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _exerciseName = '';

  // Use dummy initial values, they will be replaced by user input.
  Exercise _exercise = ClassicExercise.forCreation(
    name: '',
    orderInSession: 0,
    templateParameters: const ClassicExerciseParameters(sets: <ClassicExerciseSet>[]),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add New Exercise'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (String? value) => _exerciseName = value!,
                ),
                const SizedBox(height: 20),
                // Based on session type, create a dummy exercise to build the form
                _buildParameterForm(),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Re-create the exercise with the final name
                final Exercise finalExercise = switch (_exercise) {
                  ClassicExercise e => e.copyWith(name: _exerciseName),
                  AmrapExercise e => e.copyWith(name: _exerciseName),
                  EmomExercise e => e.copyWith(name: _exerciseName),
                  HiitExercise e => e.copyWith(name: _exerciseName),
                };
                Navigator.of(context).pop(finalExercise);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );

  Widget _buildParameterForm() {
    switch (widget.session) {
      case ClassicSession _:
        _exercise = ClassicExercise.forCreation(
          name: '',
          orderInSession: 0,
          templateParameters: const ClassicExerciseParameters(
            sets: <ClassicExerciseSet>[
              ClassicExerciseSet(
                orderInExercise: 1,
                repsNumber: 10,
                weight: 50,
                restDuration: Duration(seconds: 60),
              ),
            ],
          ),
          objectiveParameters: null,
        );
        return const Text('Classic Exercise will be added with 1 set of 10 reps at 50kg. Edit it after creation.');
      case AmrapSession _:
        const AmrapExerciseParameters params = AmrapExerciseParameters(repsNumber: 10, weight: 20);
        _exercise = AmrapExercise.forCreation(
          name: '',
          orderInSession: 0,
          templateParameters: params,
          objectiveParameters: null,
        );
        return Text(
          'AMRAP Exercise will be added with default parameters: ${params.repsNumber} reps at ${params.weight}kg.',
        );
      case EmomSession _:
        const EmomExerciseParameters params =
            EmomExerciseParameters(duration: Duration(seconds: 45), repsNumber: 12, weight: 0);
        _exercise = EmomExercise.forCreation(
          name: '',
          orderInSession: 0,
          templateParameters: params,
          objectiveParameters: null,
        );
        return const Text('EMOM Exercise will be added with default parameters.');
      case HiitSession _:
        const HiitExerciseParameters params = HiitExerciseParameters(
          effortDuration: Duration(seconds: 30),
          restDuration: Duration(seconds: 15),
          weight: 0,
        );
        _exercise = HiitExercise.forCreation(
          name: '',
          orderInSession: 0,
          templateParameters: params,
          objectiveParameters: null,
        );
        return const Text('HIIT Exercise will be added with default parameters.');
    }
  }
}

class _EditSetDialog extends StatefulWidget {
  const _EditSetDialog({this.set});
  final ClassicExerciseSet? set;

  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.set?.repsNumber.toString() ?? '');
    _weightController = TextEditingController(text: widget.set?.weight.toString() ?? '');
    _restController = TextEditingController(text: widget.set?.restDuration.inSeconds.toString() ?? '');
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final ClassicExerciseSet result = ClassicExerciseSet(
        orderInExercise: widget.set?.orderInExercise ?? 0, // Is recalculated by parent on save.
        repsNumber: int.parse(_repsController.text),
        weight: double.parse(_weightController.text),
        restDuration: Duration(seconds: int.parse(_restController.text)),
      );
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.set == null ? 'Add Set' : 'Edit Set'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                validator: (String? value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (String? value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _restController,
                decoration: const InputDecoration(labelText: 'Rest (seconds)'),
                keyboardType: TextInputType.number,
                validator: (String? value) => value!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      );
}
