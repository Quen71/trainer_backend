import 'package:flutter/material.dart';
import 'package:trainer_backend/models/models.export.dart';
import 'package:trainer_backend/services/services.export.dart';

class ProfileTestScreen extends StatefulWidget {
  const ProfileTestScreen({super.key});

  @override
  State<ProfileTestScreen> createState() => _ProfileTestScreenState();
}

class _ProfileTestScreenState extends State<ProfileTestScreen> {
  Profile? _profile;
  bool _isLoading = true;
  String? _error;

  // Pagination for programs
  final List<Program> _programs = <Program>[];
  final ScrollController _programsScrollController = ScrollController();
  bool _isLoadingMorePrograms = false;
  int _programsPage = 0;
  bool _hasMorePrograms = true;
  static const int _pageSize = 10;

  // Pagination for session logs
  final List<SessionLog> _sessionLogs = <SessionLog>[];
  final ScrollController _sessionLogsScrollController = ScrollController();
  bool _isLoadingMoreSessionLogs = false;
  int _sessionLogsPage = 0;
  bool _hasMoreSessionLogs = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _programsScrollController.addListener(_onProgramsScroll);
    _sessionLogsScrollController.addListener(_onSessionLogsScroll);
  }

  @override
  void dispose() {
    _programsScrollController
      ..removeListener(_onProgramsScroll)
      ..dispose();
    _sessionLogsScrollController
      ..removeListener(_onSessionLogsScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final Profile profile = await AuthService.getProfileWithInitialData(limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _programs.addAll(profile.programs);
        _sessionLogs.addAll(profile.sessionLogs);
        _hasMorePrograms = profile.programs.length >= _pageSize;
        _hasMoreSessionLogs = profile.sessionLogs.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load initial data: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onProgramsScroll() {
    if (_programsScrollController.position.pixels >= _programsScrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMorePrograms &&
        _hasMorePrograms) {
      _loadMorePrograms();
    }
  }

  Future<void> _loadMorePrograms() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMorePrograms = true;
    });
    _programsPage++;
    try {
      final List<Program> newPrograms = await ProgramsService.fetchUserPrograms(
        page: _programsPage,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _programs.addAll(newPrograms);
        _hasMorePrograms = newPrograms.length >= _pageSize;
      });
    } catch (e) {
      debugPrint('Failed to load more programs: $e');
      _programsPage--; // revert page count on error
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMorePrograms = false;
        });
      }
    }
  }

  void _onSessionLogsScroll() {
    if (_sessionLogsScrollController.position.pixels >= _sessionLogsScrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMoreSessionLogs &&
        _hasMoreSessionLogs) {
      _loadMoreSessionLogs();
    }
  }

  Future<void> _loadMoreSessionLogs() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMoreSessionLogs = true;
    });
    _sessionLogsPage++;
    try {
      final List<SessionLog> newLogs = await HistoryService.fetchUserSessionsLogs(
        page: _sessionLogsPage,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _sessionLogs.addAll(newLogs);
        _hasMoreSessionLogs = newLogs.length >= _pageSize;
      });
    } catch (e) {
      debugPrint('Failed to load more session logs: $e');
      _sessionLogsPage--;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMoreSessionLogs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_profile?.username ?? 'Profile Test'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(icon: Icon(Icons.fitness_center), text: 'Programs'),
                Tab(icon: Icon(Icons.history), text: 'Session Logs'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    )
                  : TabBarView(
                      children: <Widget>[
                        _buildProgramsList(),
                        _buildSessionLogsList(),
                      ],
                    ),
        ),
      );

  Widget _buildProgramsList() {
    if (_programs.isEmpty && !_isLoadingMorePrograms) {
      return const Center(child: Text('No programs found.'));
    }
    return ListView.builder(
      controller: _programsScrollController,
      itemCount: _programs.length + (_isLoadingMorePrograms ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == _programs.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final Program program = _programs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('${program.name} (ID: ${program.id})'),
            subtitle: Text(
                '${program.sessions.length} session(s) - Updated: ${program.updatedAt.toLocal().toString().substring(0, 10)}'),
          ),
        );
      },
    );
  }

  Widget _buildSessionLogsList() {
    if (_sessionLogs.isEmpty && !_isLoadingMoreSessionLogs) {
      return const Center(child: Text('No session logs found.'));
    }
    return ListView.builder(
      controller: _sessionLogsScrollController,
      itemCount: _sessionLogs.length + (_isLoadingMoreSessionLogs ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == _sessionLogs.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final SessionLog log = _sessionLogs[index];
        final int roundsCount = switch (log) {
          ClassicSessionLog() => log.rounds.length,
          AmrapSessionLog() => log.rounds.length,
          EmomSessionLog() => log.rounds.length,
          HiitSessionLog() => log.rounds.length,
        };

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('Session Log ID: ${log.id} (Session: ${log.id})'),
            subtitle: Text('$roundsCount round(s) - Started: ${log.startedAt.toLocal().toString().substring(0, 16)}'),
          ),
        );
      },
    );
  }
}
