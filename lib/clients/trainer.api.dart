import 'package:supabase_flutter/supabase_flutter.dart';

/// A static accessor class for the Supabase client and services.
///
/// This utility class provides a centralized point of access to the
/// Supabase client instance and its authentication manager, simplifying
/// interactions with the backend throughout the application.
class TrainerAPI {
  /// The constructor is private to prevent instantiation of the class.
  const TrainerAPI._();

  /// Provides access to the singleton instance of the [SupabaseClient].
  ///
  /// This client is used for all database operations, such as queries,
  /// mutations, and RPC calls.
  static SupabaseClient get client => Supabase.instance.client;

  /// Provides access to the singleton instance of the [GoTrueClient].
  ///
  /// This client is used specifically for authentication-related operations,
  /// such as sign-up, sign-in, and user management.
  static GoTrueClient get authManager => Supabase.instance.client.auth;
}
