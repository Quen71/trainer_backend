import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class for cleaning up test data after each test.
///
/// Removes all data created by a user to avoid interference between tests.
class CleanupHelper {
  CleanupHelper._();

  /// Cleans up all data for a specific user.
  ///
  /// Deletes in order:
  /// 1. Programs (cascades to sessions and exercises)
  /// 2. Subscription limit monitoring events
  ///
  /// - [supabase]: Supabase client instance
  /// - [userId]: UUID of the user to clean up
  static Future<void> cleanupUserData(
    SupabaseClient supabase,
    String userId,
  ) async {
    try {
      // Delete programs (cascades to sessions and exercises)
      await supabase.from('programs').delete().eq('user_id', userId);

      // Delete monitoring events
      await supabase.from('subscription_limit_events').delete().eq('user_id', userId);
    } catch (e) {
      // Ignore cleanup errors (may be called even if no data exists)
      // Log for debug if necessary
      print('Warning: Cleanup error for user $userId: $e');
    }
  }

  /// Cleans up user data and signs out.
  ///
  /// Convenience method that combines cleanup and signOut.
  static Future<void> cleanupAndSignOut(
    SupabaseClient supabase,
    String userId,
  ) async {
    await cleanupUserData(supabase, userId);
    await supabase.auth.signOut();
  }
}
