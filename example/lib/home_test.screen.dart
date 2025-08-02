import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/training/enums/session_style.dart';
import 'package:trainer_backend/models/training/exercise.dart';
import 'package:trainer_backend/models/training/parameters/exercise_parameters.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/services/auth.service.dart';
import 'package:trainer_backend/services/programs.service.dart';
import 'package:trainer_backend_example/profile_test.screen.dart';
import 'package:trainer_backend_example/program_detail.screen.dart';
import 'package:trainer_backend_example/sessions_logs.screen.dart';

class HomeTestScreen extends StatefulWidget {
  const HomeTestScreen({super.key});

  @override
  State<HomeTestScreen> createState() => _HomeTestScreenState();
}

class _HomeTestScreenState extends State<HomeTestScreen> {
  final List<Program> _fetchedPrograms = <Program>[];
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final User? user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Test Screen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => _handleApiCall(AuthService.signOut),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (user != null) ...<Widget>[
              Text('Welcome, ${user.email}'),
              Text('ID: ${user.id}'),
            ] else
              const Text('Welcome!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testCreateFullProgram,
              child: const Text('Create Full Program'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFetchUserPrograms,
              child: const Text('Fetch My Programs'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const SessionsLogsScreen(),
                      ),
                    );
                  },
                  child: const Text('View Session History'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const ProfileTestScreen(),
                      ),
                    );
                  },
                  child: const Text('Test Profile Loading'),
                ),
              ],
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _fetchedPrograms.length,
                itemBuilder: (BuildContext context, int index) {
                  final Program program = _fetchedPrograms[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    child: ListTile(
                      title: Text(program.name),
                      subtitle: Text('ID: ${program.id} - Created: ${program.createdAt.toLocal()}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ProgramDetailScreen(program: program),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  _handleApiCall(() => AuthService.deleteAccount(), successMessage: 'Account deleted successfully.'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Program _createSampleProgram() {
    // Unique name to avoid conflicts
    final String uniqueName = 'Full Body Test ${DateTime.now().millisecondsSinceEpoch}';
    return Program.forCreation(
      name: uniqueName,
      description: 'A complex program created for testing purposes.',
      sessions: <Session>[
        ClassicSession.forCreation(
          name: 'Classic Weight Training',
          orderInProgram: 1,
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
                    weight: 80,
                    restDuration: Duration(seconds: 90),
                  ),
                  ClassicExerciseSet(
                    orderInExercise: 2,
                    repsNumber: 8,
                    weight: 80,
                    restDuration: Duration(seconds: 90),
                  ),
                  ClassicExerciseSet(
                    orderInExercise: 3,
                    repsNumber: 8,
                    weight: 80,
                    restDuration: Duration(seconds: 90),
                  ),
                ],
              ),
            ),
            ClassicExercise.forCreation(
              orderInSession: 2,
              name: 'Overhead Press',
              templateParameters: const ClassicExerciseParameters(
                sets: <ClassicExerciseSet>[
                  ClassicExerciseSet(
                    orderInExercise: 1,
                    repsNumber: 10,
                    weight: 50,
                    restDuration: Duration(seconds: 60),
                  ),
                  ClassicExerciseSet(
                    orderInExercise: 2,
                    repsNumber: 10,
                    weight: 50,
                    restDuration: Duration(seconds: 60),
                  ),
                ],
              ),
            ),
          ],
        ),
        AmrapSession.forCreation(
          name: 'Cardio AMRAP',
          orderInProgram: 2,
          style: SessionStyle.bodyweight,
          duration: const Duration(minutes: 15),
          exercises: <AmrapExercise>[
            AmrapExercise.forCreation(
              orderInSession: 1,
              name: 'Burpees',
              templateParameters: const AmrapExerciseParameters(repsNumber: 10, weight: 0),
            ),
            AmrapExercise.forCreation(
              orderInSession: 2,
              name: 'Kettlebell Swings',
              templateParameters: const AmrapExerciseParameters(repsNumber: 15, weight: 16),
            ),
          ],
        ),
        EmomSession.forCreation(
          name: 'Full Body EMOM',
          orderInProgram: 3,
          style: SessionStyle.weights,
          roundNumber: 5,
          exercises: <EmomExercise>[
            EmomExercise.forCreation(
              orderInSession: 1,
              name: 'Thrusters',
              templateParameters: const EmomExerciseParameters(
                duration: Duration(minutes: 1),
                repsNumber: 12,
                weight: 40,
              ),
            ),
            EmomExercise.forCreation(
              orderInSession: 2,
              name: 'Burpees',
              templateParameters: const EmomExerciseParameters(
                duration: Duration(minutes: 1),
                repsNumber: 12,
                weight: 40,
              ),
            ),
          ],
        ),
        HiitSession.forCreation(
          name: 'Legs HIIT',
          orderInProgram: 4,
          style: SessionStyle.bodyweight,
          roundNumber: 4,
          exercises: <HiitExercise>[
            HiitExercise.forCreation(
              orderInSession: 1,
              name: 'Jumping Squats',
              templateParameters: const HiitExerciseParameters(
                effortDuration: Duration(seconds: 45),
                restDuration: Duration(seconds: 15),
                weight: 0,
              ),
            ),
            HiitExercise.forCreation(
              orderInSession: 2,
              name: 'Push-ups',
              templateParameters: const HiitExerciseParameters(
                effortDuration: Duration(seconds: 45),
                restDuration: Duration(seconds: 15),
                weight: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _testCreateFullProgram() async {
    final Program programToCreate = _createSampleProgram();

    await _handleApiCall<Program>(
      () => ProgramsService.createFullProgram(programToCreate),
      onSuccess: (Program newProgram) {
        if (mounted) {
          setState(() {});
        }
        return 'Program "${newProgram.name}" created successfully with ID: ${newProgram.id}';
      },
    );
  }

  Future<void> _testFetchUserPrograms() async {
    setState(() {
      _isLoading = true;
    });

    await _handleApiCall<List<Program>>(
      () => ProgramsService.fetchUserPrograms(page: _currentPage),
      onSuccess: (List<Program> newPrograms) {
        setState(() {
          _fetchedPrograms.addAll(newPrograms);
          _currentPage++;
        });
        return '${newPrograms.length} programs fetched for page ${_currentPage - 1}';
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleApiCall<T>(
    Future<T> Function() apiCall, {
    String? successMessage,
    String Function(T result)? onSuccess,
  }) async {
    try {
      final T result = await apiCall();
      String message;
      if (onSuccess != null) {
        message = onSuccess(result);
      } else {
        message = successMessage ?? 'Operation successful';
      }
      _showSnackbar(message);
    } catch (e) {
      _showSnackbar('Operation failed: ${e.toString()}', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );

      if (isError) {
        log(
          name: 'API Call ERROR',
          message,
        );
      }
    }
  }
}
