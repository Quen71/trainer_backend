import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/models/api/session_api_response.dart';
import 'package:trainer_backend/models/training/session.dart';

/// A service class for managing training sessions.
///
/// This class provides methods to interact with individual [Session] objects,
/// such as updating them.
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
  /// Throws a [PostgrestException] if the RPC call fails.
  ///
  /// **Subscription Limit Exceptions:**
  /// The RPC may raise exceptions with the following error codes if subscription limits are exceeded:
  /// - `LIMIT_EXCEEDED:MAX_EXERCISES:X/Y` - Maximum number of exercises exceeded (only for new exercises)
  /// - `SUBSCRIPTION_INACTIVE` - User's subscription is not active
  /// - `SUBSCRIPTION_EXPIRED` - User's subscription has expired
  static Future<SessionApiResponse> updateFullSession(Session session) async {
    final Map<String, dynamic> sessionJson = session.toJson();

    final dynamic response = await _client.rpc(
      'update_full_session',
      params: <String, dynamic>{'p_session_data': sessionJson},
    );

    return SessionApiResponse.fromJson(response as Map<String, dynamic>);
  }
}
