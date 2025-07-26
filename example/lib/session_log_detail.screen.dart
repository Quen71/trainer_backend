import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trainer_backend/models/history/exercise_log.dart';
import 'package:trainer_backend/models/history/round_log.dart';
import 'package:trainer_backend/models/history/session_log.dart';

class SessionLogDetailScreen extends StatelessWidget {
  const SessionLogDetailScreen({required this.log, super.key});

  final SessionLog log;

  @override
  Widget build(BuildContext context) {
    final (String type, String durationStr, List<RoundLog> rounds) = switch (log) {
      ClassicSessionLog l => (
          'CLASSIC',
          l.endedAt == null
              ? 'In Progress'
              : '${l.endedAt!.difference(l.startedAt).inMinutes}m ${l.endedAt!.difference(l.startedAt).inSeconds.remainder(60)}s',
          l.rounds
        ),
      AmrapSessionLog l => (
          'AMRAP',
          l.endedAt == null
              ? 'In Progress'
              : '${l.endedAt!.difference(l.startedAt).inMinutes}m ${l.endedAt!.difference(l.startedAt).inSeconds.remainder(60)}s',
          l.rounds
        ),
      EmomSessionLog l => (
          'EMOM',
          l.endedAt == null
              ? 'In Progress'
              : '${l.endedAt!.difference(l.startedAt).inMinutes}m ${l.endedAt!.difference(l.startedAt).inSeconds.remainder(60)}s',
          l.rounds
        ),
      HiitSessionLog l => (
          'HIIT',
          l.endedAt == null
              ? 'In Progress'
              : '${l.endedAt!.difference(l.startedAt).inMinutes}m ${l.endedAt!.difference(l.startedAt).inSeconds.remainder(60)}s',
          l.rounds
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Log Detail #${log.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _buildInfoCard(type, durationStr, rounds.length),
          const SizedBox(height: 16),
          ...rounds.map((RoundLog round) => _buildRoundCard(context, round)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String type, String duration, int roundCount) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InfoRow(label: 'Type', value: type),
              _InfoRow(label: 'Started', value: DateFormat.yMMMd().add_Hms().format(log.startedAt)),
              _InfoRow(label: 'Duration', value: duration),
              _InfoRow(label: 'Rounds/Sets', value: roundCount.toString()),
            ],
          ),
        ),
      );

  Widget _buildRoundCard(BuildContext context, RoundLog round) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Round ${round.roundNumber}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              ...round.exercises.map((ExerciseLog exerciseLog) => _buildExerciseLogTile(exerciseLog)),
            ],
          ),
        ),
      );

  Widget _buildExerciseLogTile(ExerciseLog exerciseLog) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              exerciseLog.exerciseName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_formatPerformance(exerciseLog), style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );

  String _formatPerformance(ExerciseLog log) {
    switch (log) {
      case ClassicExerciseLog l:
        return l.sets.map((SetLog set) => 'Set ${set.number}: ${set.reps} reps @ ${set.weight}kg').join('\n');
      case AmrapExerciseLog l:
        return '${l.repsNumber} reps @ ${l.weight}kg';
      case EmomExerciseLog l:
        return '${l.repsNumber} reps in ${l.duration.inSeconds}s @ ${l.weight}kg';
      case HiitExerciseLog l:
        return 'Effort: ${l.effortDuration.inSeconds}s, Rest: ${l.restDuration.inSeconds}s @ ${l.weight}kg';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      );
}
