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
/// This state holds the [user] object from Supabase.
class AppAuthenticated extends AppAuthState {
  const AppAuthenticated(this.user);

  /// The Supabase user object.
  final User user;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppAuthenticated && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

/// A state indicating that the user is not authenticated.
///
/// This is the state when no user is signed in or after a user has successfully
/// signed out.
class AppUnauthenticated extends AppAuthState {
  const AppUnauthenticated();
}
