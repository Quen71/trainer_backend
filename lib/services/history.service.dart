import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/exceptions/exceptions.export.dart';
import 'package:trainer_backend/models/api/create_session_log_response.dart';
import 'package:trainer_backend/models/history/session_log.dart';
import 'package:trainer_backend/utils/rpc.guard.dart';

/// A service class for managing user training history.
///
/// This class provides methods to interact with the user's session logs,
/// allowing for the creation and retrieval of training session data.
/// It communicates with the Supabase backend via RPC (Remote Procedure Calls).
///
/// All methods normalize Supabase errors into [TrainerBackendException]
/// subclasses via [RpcGuard]. Generic Postgres failures become
/// [TrainerBackendRpcException]; network failures become
/// [TrainerBackendNetworkException]; and any remaining errors become
/// [TrainerBackendUnknownException].
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
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails (e.g. session
  /// not found or access denied).
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<CreateSessionLogResponse> createSessionLog(SessionLog sessionLog) => RpcGuard.run(
    operation: 'createSessionLog',
    body: () async {
      final dynamic data = await _client.rpc(
        'create_session_log',
        params: <String, dynamic>{'session_log_data': sessionLog.toJson()},
      );
      return CreateSessionLogResponse.fromJson(data as Map<String, dynamic>);
    },
  );

  /// Fetches a paginated list of session logs for the current user.
  ///
  /// - [page]: The page number to fetch.
  /// - [pageSize]: The number of items per page. Defaults to 5.
  ///
  /// Returns a [Future] that completes with a list of [SessionLog] objects.
  /// If there are no logs or the page is out of bounds, it returns an empty list.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<List<SessionLog>> fetchUserSessionsLogs({required int page, int pageSize = 5}) => RpcGuard.run(
    operation: 'fetchUserSessionsLogs',
    body: () async {
      final dynamic response = await _client.rpc(
        'get_user_sessions_logs',
        params: <String, dynamic>{'page_number': page, 'page_size': pageSize},
      );

      if (response == null) return <SessionLog>[];

      return (response as List<dynamic>).map((dynamic l) => SessionLog.fromJson(l as Map<String, dynamic>)).toList();
    },
  );
}
