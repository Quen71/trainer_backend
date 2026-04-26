import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/exceptions/exceptions.export.dart';
import 'package:trainer_backend/models/api/session_api_response.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/utils/rpc.guard.dart';

/// A service class for managing training sessions.
///
/// This class provides methods to interact with individual [Session] objects,
/// such as updating them.
///
/// All methods normalize Supabase errors into [TrainerBackendException]
/// subclasses via [RpcGuard]. Subscription-related RPC errors are surfaced as
/// [TrainerBackendSubscriptionException]; generic Postgres failures become
/// [TrainerBackendRpcException]; network failures become
/// [TrainerBackendNetworkException]; and any remaining errors become
/// [TrainerBackendUnknownException].
class SessionsService {
  /// The constructor is private to prevent instantiation of the class.
  const SessionsService._();

  /// A private getter for the Supabase client instance.
  static SupabaseClient get _client => TrainerAPI.client;

  /// Updates a full session, including its exercises and their parameters.
  ///
  /// - [session]: The [Session] object containing the updated data.
  ///
  /// Returns a [Future] with a [SessionApiResponse], which contains the
  /// updated session and any newly created exercises with their server-assigned IDs.
  ///
  /// Throws a [TrainerBackendSubscriptionException] if the exercises-per-session
  /// limit is exceeded or the subscription is inactive/expired.
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<SessionApiResponse> updateFullSession(Session session) => RpcGuard.run(
    operation: 'updateFullSession',
    body: () async {
      final dynamic response = await _client.rpc(
        'update_full_session',
        params: <String, dynamic>{'p_session_data': session.toJson()},
      );
      return SessionApiResponse.fromJson(response as Map<String, dynamic>);
    },
  );
}
