import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trainer_backend/models/history/session_log.dart';
import 'package:trainer_backend/services/history.service.dart';
import 'package:trainer_backend_example/session_log_detail.screen.dart';

class SessionsLogsScreen extends StatefulWidget {
  const SessionsLogsScreen({super.key});

  @override
  State<SessionsLogsScreen> createState() => _SessionsLogsScreenState();
}

class _SessionsLogsScreenState extends State<SessionsLogsScreen> {
  final List<SessionLog> _logs = <SessionLog>[];
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
        _fetchLogs();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final List<SessionLog> newLogs = await HistoryService.fetchUserSessionsLogs(
        page: _page,
        pageSize: 10,
      );
      setState(() {
        _logs.addAll(newLogs);
        _page++;
        _hasMore = newLogs.isNotEmpty;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Session History'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _page = 0;
              _hasMore = true;
              _logs.clear();
            });
            await _fetchLogs();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _logs.length + (_hasMore ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == _logs.length) {
                return _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink();
              }
              final SessionLog log = _logs[index];
              return _SessionLogCard(log: log);
            },
          ),
        ),
      );
}

class _SessionLogCard extends StatelessWidget {
  const _SessionLogCard({required this.log});

  final SessionLog log;

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat.yMMMd().add_Hms().format(log.startedAt);

    final (String type, String durationStr, String details) = switch (log) {
      ClassicSessionLog l => (
          'CLASSIC',
          '${l.endedAt.difference(l.startedAt).inMinutes}m ${l.endedAt.difference(l.startedAt).inSeconds.remainder(60)}s',
          'Rounds: ${l.rounds.length}'
        ),
      AmrapSessionLog l => (
          'AMRAP',
          '${l.endedAt.difference(l.startedAt).inMinutes}m ${l.endedAt.difference(l.startedAt).inSeconds.remainder(60)}s',
          'Rounds: ${l.rounds.length}'
        ),
      EmomSessionLog l => (
          'EMOM',
          '${l.endedAt.difference(l.startedAt).inMinutes}m ${l.endedAt.difference(l.startedAt).inSeconds.remainder(60)}s',
          'Rounds: ${l.rounds.length}'
        ),
      HiitSessionLog l => (
          'HIIT',
          '${l.endedAt.difference(l.startedAt).inMinutes}m ${l.endedAt.difference(l.startedAt).inSeconds.remainder(60)}s',
          'Rounds: ${l.rounds.length}'
        ),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(log.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              log.programName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text('Type: $type'),
            Text('Started: $formattedDate'),
            Text('Duration: $durationStr'),
            Text(details),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => SessionLogDetailScreen(log: log),
            ),
          );
        },
      ),
    );
  }
}
