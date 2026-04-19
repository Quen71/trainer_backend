import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/exceptions/trainer_backend_exception.dart';
import 'package:trainer_backend/models/models.export.dart' hide Session;
import 'package:trainer_backend/services/auth_response_validator.dart';

/// A service class for handling user authentication with Supabase.
///
/// This class provides static methods to manage user sign-up, sign-in,
/// sign-out, and other authentication-related functionalities like password
/// resets and account deletion. It serves as a layer of abstraction over the
/// Supabase authentication client.
class AuthService {
  /// The constructor is private to prevent instantiation of the class.
  const AuthService._();

  /// Gets the currently signed-in user.
  ///
  /// Returns the [User] object if a user is currently signed in,
  /// otherwise returns `null`.
  static User? get currentUser => TrainerAPI.authManager.currentUser;

  /// A stream that notifies of changes in the authentication state.
  ///
  /// This stream listens to Supabase authentication events and converts them into
  /// [AppAuthState] objects that can be consumed by the application layer.
  ///
  /// The stream handles different authentication events with specific behaviors:
  ///
  /// **Token Refresh Events** ([AuthChangeEvent.tokenRefreshed]):
  /// - Occurs automatically every ~3600 seconds (1 hour) by default
  /// - Emits [AppAuthenticated] with `isTokenRefresh: true`
  /// - Does NOT emit [AppAuthLoading] to avoid UI flicker
  /// - Should be handled silently by the UI (no data refetch, no notifications)
  ///
  /// **Sign-in Events** (signedIn, initialSession, etc.):
  /// - Emits [AppAuthLoading] followed by [AppAuthenticated] with `isTokenRefresh: false`
  /// - UI should respond by fetching user data and showing welcome messages
  ///
  /// **Sign-out Events** (signedOut, userDeleted):
  /// - Emits [AppAuthLoading] followed by [AppUnauthenticated]
  /// - UI should clear user data and redirect to login screen
  ///
  /// Example usage:
  /// ```dart
  /// AuthService.onAuthStateChange.listen((state) {
  ///   if (state is AppAuthenticated) {
  ///     if (!state.isTokenRefresh) {
  ///       // Real sign-in event: fetch data, show messages
  ///       fetchUserData();
  ///     } else {
  ///       // Token refresh: do nothing, keep existing state
  ///     }
  ///   }
  /// });
  /// ```
  static Stream<AppAuthState> get onAuthStateChange async* {
    yield const AppAuthInitial();

    await for (final AuthState data
        in TrainerAPI.authManager.onAuthStateChange) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.passwordRecovery:
          // User is recovering their password via OTP
          yield const AppAuthLoading();
          if (session != null) {
            yield AppAuthPasswordRecovery(session.user);
          }
          break;

        case AuthChangeEvent.tokenRefreshed:
          // Automatic token refresh - should be transparent to the user
          // No loading state to avoid UI flicker
          // The isTokenRefresh flag tells the UI to skip data refetch
          if (session != null) {
            yield AppAuthenticated(session.user, isTokenRefresh: true);
          } else {
            yield const AppUnauthenticated();
          }
          break;

        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.mfaChallengeVerified:
          // Real authentication events that require full UI response
          // Show loading state, then authenticated state with isTokenRefresh: false
          yield const AppAuthLoading();
          if (session != null) {
            yield AppAuthenticated(session.user, isTokenRefresh: false);
          } else {
            yield const AppUnauthenticated();
          }
          break;

        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          // User explicitly signed out or account was deleted
          yield const AppAuthLoading();
          yield const AppUnauthenticated();
          break;
      }
    }
  }

  /// Retrieves the full user profile along with an initial set of their
  /// programs and session logs.
  ///
  /// This method is ideal for fetching the initial data needed when a user
  /// logs in or opens the app.
  ///
  /// - [limit]: The maximum number of programs and session logs to retrieve.
  ///
  /// Returns a [Profile] object populated with the user's data.
  ///
  /// Throws a [TrainerBackendRpcException] or [TrainerBackendUnknownException]
  /// if the RPC call fails or returns no data.
  static Future<Profile> getProfileWithInitialData({required int limit}) async {
    try {
      final dynamic response = await TrainerAPI.client.rpc(
        'get_profile_with_initial_data',
        params: <String, dynamic>{'p_limit': limit},
      );

      if (response == null) {
        throw const TrainerBackendUnknownException(
          operation: 'getProfileWithInitialData',
          message: 'Failed to retrieve profile: No data returned.',
        );
      }

      return Profile.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw TrainerBackendRpcException.fromPostgrestException(
        operation: 'getProfileWithInitialData',
        exception: error,
      );
    } catch (error) {
      if (error is TrainerBackendException) {
        rethrow;
      }

      if (_isNetworkIssue(error)) {
        throw TrainerBackendNetworkException(
          operation: 'getProfileWithInitialData',
          message: 'Failed to retrieve profile because of a network error.',
          cause: error,
        );
      }

      throw TrainerBackendUnknownException(
        operation: 'getProfileWithInitialData',
        message: 'Failed to retrieve profile.',
        cause: error,
      );
    }
  }

  /// Signs up a new user with email, password, and username.
  ///
  /// - [email]: The user's email address.
  /// - [password]: The user's chosen password.
  /// - [username]: The user's unique username.
  /// - [fullName]: An optional full name for the user.
  ///
  /// Throws a [TrainerBackendAuthException] if sign-up fails.
  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    final AuthResponse response = await _runAuthOperation(
      () => TrainerAPI.authManager.signUp(
        email: email,
        password: password,
        data: <String, dynamic>{'username': username, 'full_name': fullName},
      ),
    );
    validateSignUpResponse(response);
  }

  /// Signs in an existing user with their email and password.
  ///
  /// - [email]: The email address of the user.
  /// - [password]: The password of the user.
  ///
  /// Throws a [TrainerBackendAuthException] if sign-in fails.
  static Future<void> signIn({
    required String email,
    required String password,
  }) async => _runAuthOperation(
    () => TrainerAPI.authManager.signInWithPassword(
      email: email,
      password: password,
    ),
  );

  /// Signs out the currently signed-in user.
  ///
  /// Throws a [TrainerBackendAuthException] if sign-out fails.
  static Future<void> signOut() async =>
      _runAuthOperation(TrainerAPI.authManager.signOut);

  /// Initiates the Google OAuth sign-in flow.
  ///
  /// Throws a [TrainerBackendAuthException] if the process fails.
  static Future<void> signInWithGoogle() async => _runAuthOperation(
    () => TrainerAPI.authManager.signInWithOAuth(OAuthProvider.google),
  );

  /// Initiates the Apple OAuth sign-in flow.
  ///
  /// Throws a [TrainerBackendAuthException] if the process fails.
  static Future<void> signInWithApple() async => _runAuthOperation(
    () => TrainerAPI.authManager.signInWithOAuth(OAuthProvider.apple),
  );

  /// Deletes the user's account from the database.
  ///
  /// This is a permanent action and cannot be undone.
  ///
  /// Throws a [TrainerBackendRpcException] or [TrainerBackendUnknownException]
  /// if the operation fails.
  static Future<void> deleteAccount() async {
    try {
      await TrainerAPI.client.rpc('delete_user_account');
    } on PostgrestException catch (error) {
      throw TrainerBackendRpcException.fromPostgrestException(
        operation: 'deleteAccount',
        exception: error,
      );
    } catch (error) {
      if (_isNetworkIssue(error)) {
        throw TrainerBackendNetworkException(
          operation: 'deleteAccount',
          message: 'Failed to delete account because of a network error.',
          cause: error,
        );
      }

      throw TrainerBackendUnknownException(
        operation: 'deleteAccount',
        message: 'Failed to delete account.',
        cause: error,
      );
    }
  }

  // --- Account Confirmation (OTP) ---

  /// Verifies the OTP sent to the user's email after signing up.
  ///
  /// - [email]: The user's email address.
  /// - [token]: The OTP token received by the user.
  ///
  /// Throws a [TrainerBackendAuthException] if OTP verification fails.
  static Future<void> confirmSignUp({
    required String email,
    required String token,
  }) async {
    final AuthResponse response = await _runAuthOperation(
      () => TrainerAPI.authManager.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      ),
    );

    if (response.session == null) {
      // Wrapper-level invariant: Supabase accepted the OTP flow but did not
      // return the session required by the app to continue.
      throw const TrainerBackendAuthException.sessionMissing(
        message: 'No session received after sign up confirmation.',
      );
    }
  }

  /// Resends the confirmation code to the user's email.
  ///
  /// - [email]: The email address to which the code should be resent.
  ///
  /// Throws a [TrainerBackendAuthException] if the operation fails.
  static Future<void> resendConfirmationCode({required String email}) async =>
      _runAuthOperation(
        () => TrainerAPI.authManager.resend(email: email, type: OtpType.signup),
      );

  // --- Password Reset (OTP) ---

  /// Triggers the sending of a password reset code to the user's email.
  ///
  /// IMPORTANT: For this to work, you must edit the "Password Reset"
  /// email template in your Supabase project to send the `{{ .Token }}`
  /// instead of a confirmation link.
  ///
  /// - [email]: The user's email address.
  ///
  /// Throws a [TrainerBackendAuthException] if the operation fails.
  static Future<void> sendPasswordResetCode({required String email}) async =>
      _runAuthOperation(
        () => TrainerAPI.authManager.resetPasswordForEmail(email),
      );

  /// Verifies the password reset code and signs the user in.
  ///
  /// - [email]: The user's email address.
  /// - [token]: The OTP token received by the user.
  ///
  /// Throws a [TrainerBackendAuthException] if verification fails.
  static Future<void> verifyPasswordResetCode({
    required String email,
    required String token,
  }) async {
    final AuthResponse response = await _runAuthOperation(
      () => TrainerAPI.authManager.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      ),
    );

    if (response.session == null) {
      // Wrapper-level invariant: Supabase accepted the OTP flow but did not
      // return the recovery session required by the app to update the password.
      throw const TrainerBackendAuthException.sessionMissing(
        message: 'No session received after password reset verification.',
      );
    }
  }

  /// Updates the password for the currently signed-in user.
  ///
  /// - [newPassword]: The new password to set for the user.
  ///
  /// Throws a [TrainerBackendAuthException] if the update fails.
  static Future<void> updatePassword({required String newPassword}) async =>
      _runAuthOperation(
        () => TrainerAPI.authManager.updateUser(
          UserAttributes(password: newPassword),
        ),
      );

  static Future<T> _runAuthOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on AuthException catch (error) {
      throw TrainerBackendAuthException.fromAuthException(error);
    } catch (error) {
      if (_isNetworkIssue(error)) {
        throw TrainerBackendNetworkException(
          operation: 'authOperation',
          message: 'An unexpected network error occurred.',
          cause: error,
        );
      }

      throw TrainerBackendUnknownException(
        operation: 'authOperation',
        message: 'An unexpected authentication error occurred.',
        cause: error,
      );
    }
  }

  static bool _isNetworkIssue(Object error) {
    final String normalizedError = error.toString().toLowerCase();

    return normalizedError.contains('failed host lookup') ||
        normalizedError.contains('network') ||
        normalizedError.contains('connection') ||
        normalizedError.contains('socketexception') ||
        normalizedError.contains('timeout');
  }
}
