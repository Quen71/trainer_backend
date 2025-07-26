import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:trainer_backend/models/training/enums/session_style.dart';
import 'package:trainer_backend/models/training/enums/session_type.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/programs.service.dart';
import 'package:trainer_backend_example/session_detail.screen.dart';

class ProgramDetailScreen extends StatefulWidget {
  const ProgramDetailScreen({super.key, required this.program});

  final Program program;

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  late Program _program;
  late List<Session> _sessions;
  bool _isEditing = false;
  late final TextEditingController _programNameController;

  @override
  void initState() {
    super.initState();
    _program = widget.program;
    // Create a mutable copy of the sessions list for reordering.
    _sessions = List<Session>.from(_program.sessions)
      ..sort((Session a, Session b) => a.orderInProgram.compareTo(b.orderInProgram));
    _programNameController = TextEditingController(text: _program.name);
  }

  @override
  void dispose() {
    _programNameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Create a new Program object with the updated name and session order.
    final Program programToUpdate = _program.copyWith(
      name: _programNameController.text,
      sessions: _sessions,
    );

    try {
      final Program updatedProgram = await ProgramsService.updateFullProgram(programToUpdate);
      if (!mounted) return;

      setState(() {
        // Update the local state with the authoritative data from the server
        _program = updatedProgram;
        _sessions = List<Session>.from(_program.sessions)
          ..sort((Session a, Session b) => a.orderInProgram.compareTo(b.orderInProgram));
        _programNameController.text = _program.name;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      log(
        name: 'API Error',
        'Failed to update program: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update program: $e')),
      );
    }
  }

  Future<void> _addSession(SessionType type) async {
    late Session sessionToAdd;

    switch (type) {
      case SessionType.classic:
        sessionToAdd = ClassicSession.forCreation(
          name: 'New Classic Session',
          orderInProgram: 0,
          style: SessionStyle.bodyweight,
          exercises: <ClassicExercise>[
            ClassicExercise.forCreation(
              name: 'Push-ups',
              orderInSession: 1,
              templateParameters: const ClassicExerciseParameters(
                sets: <ClassicExerciseSet>[
                  ClassicExerciseSet(
                    orderInExercise: 1,
                    repsNumber: 12,
                    weight: 0,
                    restDuration: Duration(seconds: 60),
                  ),
                ],
              ),
              objectiveParameters: const ClassicExerciseParameters(
                sets: <ClassicExerciseSet>[
                  ClassicExerciseSet(
                    orderInExercise: 1,
                    repsNumber: 15,
                    weight: 0,
                    restDuration: Duration(seconds: 60),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case SessionType.amrap:
        sessionToAdd = AmrapSession.forCreation(
          name: 'New AMRAP Session',
          orderInProgram: 0,
          style: SessionStyle.weights,
          duration: const Duration(minutes: 10),
          exercises: <AmrapExercise>[
            AmrapExercise.forCreation(
              name: 'Kettlebell Swings',
              orderInSession: 1,
              templateParameters: const AmrapExerciseParameters(repsNumber: 15, weight: 16),
              objectiveParameters: const AmrapExerciseParameters(repsNumber: 15, weight: 20),
            ),
          ],
        );
        break;
      case SessionType.emom:
        sessionToAdd = EmomSession.forCreation(
          name: 'New EMOM Session',
          orderInProgram: 0,
          style: SessionStyle.bodyweight,
          roundNumber: 10,
          exercises: <EmomExercise>[
            EmomExercise.forCreation(
              name: 'Burpees',
              orderInSession: 1,
              templateParameters:
                  const EmomExerciseParameters(duration: Duration(seconds: 40), repsNumber: 10, weight: 0),
              objectiveParameters:
                  const EmomExerciseParameters(duration: Duration(seconds: 40), repsNumber: 12, weight: 0),
            ),
          ],
        );
        break;
      case SessionType.hiit:
        sessionToAdd = HiitSession.forCreation(
          name: 'New HIIT Session',
          orderInProgram: 0,
          style: SessionStyle.bodyweight,
          roundNumber: 8,
          exercises: <HiitExercise>[
            HiitExercise.forCreation(
              name: 'Jumping Jacks',
              orderInSession: 1,
              templateParameters: const HiitExerciseParameters(
                effortDuration: Duration(seconds: 30),
                restDuration: Duration(seconds: 15),
                weight: 0,
              ),
              objectiveParameters: const HiitExerciseParameters(
                effortDuration: Duration(seconds: 35),
                restDuration: Duration(seconds: 15),
                weight: 0,
              ),
            ),
          ],
        );
        break;
    }

    try {
      final Program updatedProgram = await ProgramsService.addSessionToProgram(
        programId: _program.id,
        session: sessionToAdd,
      );
      if (!mounted) return;

      setState(() {
        _program = updatedProgram;
        _sessions = List<Session>.from(_program.sessions)
          ..sort((Session a, Session b) => a.orderInProgram.compareTo(b.orderInProgram));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${type.name} session added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      log(
        name: 'API Error',
        'Failed to add session: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add session: $e')),
      );
    }
  }

  Future<void> _deleteSession(Session session) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session.name}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final Program updatedProgram = await ProgramsService.deleteSession(session.id);
      if (!mounted) return;

      setState(() {
        _program = updatedProgram;
        _sessions = List<Session>.from(_program.sessions)
          ..sort((Session a, Session b) => a.orderInProgram.compareTo(b.orderInProgram));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session "${session.name}" deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      log(
        name: 'API Error',
        'Failed to delete session: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete session: $e')),
      );
    }
  }

  Future<void> _deleteProgram() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Program'),
        content: Text('Are you sure you want to permanently delete "${_program.name}"? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ProgramsService.deleteProgram(_program.id);
      if (!mounted) return;

      // Pop the screen and indicate success
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      log(
        name: 'API Error',
        'Failed to delete program: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete program: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: _isEditing
              ? TextFormField(
                  controller: _programNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                )
              : Text(_program.name),
          actions: <Widget>[
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveChanges,
              )
            else
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          children: <SpeedDialChild>[
            SpeedDialChild(
              child: const Icon(Icons.fitness_center),
              label: 'Classic',
              onTap: () => _addSession(SessionType.classic),
            ),
            SpeedDialChild(
              child: const Icon(Icons.repeat),
              label: 'AMRAP',
              onTap: () => _addSession(SessionType.amrap),
            ),
            SpeedDialChild(
              child: const Icon(Icons.timer),
              label: 'EMOM',
              onTap: () => _addSession(SessionType.emom),
            ),
            SpeedDialChild(
              child: const Icon(Icons.flash_on),
              label: 'HIIT',
              onTap: () => _addSession(SessionType.hiit),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _sessions.length,
                itemBuilder: (BuildContext context, int index) {
                  final Session session = _sessions[index];
                  return Card(
                    key: ValueKey<int>(session.id),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${session.orderInProgram}'),
                      ),
                      title: Text(session.name),
                      subtitle: Text('Type: ${session.type.name} | Style: ${session.style.name}'),
                      trailing: _isEditing
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteSession(session),
                                ),
                                const Icon(Icons.drag_handle),
                              ],
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: _isEditing
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => SessionDetailScreen(session: session),
                                ),
                              );
                            },
                    ),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final Session item = _sessions.removeAt(oldIndex);
                    _sessions.insert(newIndex, item);

                    // Update the orderInProgram property for each session
                    for (int i = 0; i < _sessions.length; i++) {
                      // Create a new session object with the updated order
                      _sessions[i] = switch (_sessions[i]) {
                        final ClassicSession self => self.copyWith(orderInProgram: i + 1),
                        final AmrapSession self => self.copyWith(orderInProgram: i + 1),
                        final EmomSession self => self.copyWith(orderInProgram: i + 1),
                        final HiitSession self => self.copyWith(orderInProgram: i + 1),
                      };
                    }
                  });
                },
              ),
            ),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _deleteProgram,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Program'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
          ],
        ),
      );
}
