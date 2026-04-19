import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/models/api/create_session_log_response.dart';
import 'package:trainer_backend/models/history/session_log.dart';

/// A service class for managing user training history.
///
/// This class provides methods to interact with the user's session logs,
/// allowing for the creation and retrieval of training session data.
/// It communicates with the Supabase backend via RPC (Remote Procedure Calls).
class HistoryService {
  /// The constructor is private to prevent instantiation of the class.
  const HistoryService._();

  /// A private getter for the Supabase client instance.
  static SupabaseClient get _client => TrainerAPI.client;

  /// Creates a new session log in the database.
  ///
  /// - [sessionLog]: A [SessionLog] object containing the details of the
  ///   completed training session.
  ///
  /// Returns a [Future] that completes with a [CreateSessionLogResponse]
  /// containing both the created log and a preview of the updated session.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<CreateSessionLogResponse> createSessionLog(
    SessionLog sessionLog,
  ) async {
    final Map<String, dynamic> sessionLogJson = sessionLog.toJson();

    final dynamic responseData = await _client.rpc(
      'create_session_log',
      params: <String, dynamic>{'session_log_data': sessionLogJson},
    );

    log('responseData: ${responseData['updated_session_preview']}');

    return CreateSessionLogResponse.fromJson(
      responseData as Map<String, dynamic>,
    );
  }

  /// Fetches a paginated list of session logs for the current user.
  ///
  /// - [page]: The page number to fetch.
  /// - [pageSize]: The number of items per page. Defaults to 5.
  ///
  /// Returns a [Future] that completes with a list of [SessionLog] objects.
  /// If there are no logs or the page is out of bounds, it returns an empty list.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<List<SessionLog>> fetchUserSessionsLogs({
    required int page,
    int pageSize = 5,
  }) async {
    final dynamic response = await _client.rpc(
      'get_user_sessions_logs',
      params: <String, dynamic>{'page_number': page, 'page_size': pageSize},
    );

    if (response == null) {
      return <SessionLog>[];
    }

    final List<dynamic> logsJson = response as List<dynamic>;

    return logsJson
        .map((dynamic l) => SessionLog.fromJson(l as Map<String, dynamic>))
        .toList();
  }
}
