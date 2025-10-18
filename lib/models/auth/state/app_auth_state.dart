import 'package:supabase_flutter/supabase_flutter.dart';

/// A sealed class representing the various states of user authentication
/// within the application.
///
/// This class provides a structured way to handle different authentication
/// scenarios, such as when a user is signed in, signed out, or when an
/// authentication operation is in progress or has failed.
sealed class AppAuthState {
  const AppAuthState();
}

/// The initial state of authentication, before any authentication process has started.
class AppAuthInitial extends AppAuthState {
  const AppAuthInitial();
}

/// A state indicating that an authentication operation is currently in progress.
///
/// This is typically used to show loading indicators in the UI while the app
/// is, for example, signing in or signing up a user.
class AppAuthLoading extends AppAuthState {
  const AppAuthLoading();
}

/// The state representing a successfully authenticated user.
///
/// This state holds the [user] object from Supabase and includes metadata
/// to distinguish between different authentication events.
///
/// The [isTokenRefresh] flag is used to differentiate automatic token refresh
/// events from actual user sign-in events. This distinction is important because:
/// - Token refresh happens automatically every hour and should be transparent to the user
/// - Sign-in events require UI updates, data fetching, and user notifications
///
/// Example usage in UI layer:
/// ```dart
/// if (state is AppAuthenticated && !state.isTokenRefresh) {
///   // This is a real sign-in, fetch user data and show welcome message
///   fetchUserData();
///   showWelcomeMessage();
/// } else if (state is AppAuthenticated && state.isTokenRefresh) {
///   // This is just a token refresh, do nothing (keep existing state)
///   return;
/// }
/// ```
class AppAuthenticated extends AppAuthState {
  const AppAuthenticated(this.user, {this.isTokenRefresh = false});

  /// The Supabase user object containing user identity and session information.
  final User user;

  /// Indicates if this authentication state change is due to an automatic token refresh.
  ///
  /// When `true`, this state was triggered by Supabase automatically refreshing
  /// the authentication token (typically every 3600 seconds). The UI should:
  /// - NOT trigger data refetches
  /// - NOT show login/welcome messages
  /// - NOT navigate to a different screen
  /// - Keep the existing user state as-is
  ///
  /// When `false`, this is a real authentication event (sign-in, initial session, etc.)
  /// and the UI should perform all normal authentication actions.
  ///
  /// Defaults to `false`.
  final bool isTokenRefresh;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppAuthenticated && other.user == user && other.isTokenRefresh == isTokenRefresh;
  }

  @override
  int get hashCode => Object.hash(user, isTokenRefresh);
}

/// A state indicating that the user is not authenticated.
///
/// This is the state when no user is signed in or after a user has successfully
/// signed out.
class AppUnauthenticated extends AppAuthState {
  const AppUnauthenticated();
}

/// A state indicating that the user has authenticated via a recovery method (e.g., OTP)
/// and needs to update their password before proceeding.
///
/// This state holds the [user] object from Supabase.
class AppAuthPasswordRecovery extends AppAuthState {
  const AppAuthPasswordRecovery(this.user);

  /// The Supabase user object.
  final User user;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppAuthPasswordRecovery && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}
