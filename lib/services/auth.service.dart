import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/models/models.export.dart';

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
  /// This can be used to listen for user sign-in and sign-out events in real-time.
  static Stream<AuthState> get onAuthStateChange => TrainerAPI.authManager.onAuthStateChange;

  /// Retrieves the full user profile along with an initial set of their
  /// programs and session logs.
  ///
  /// This method is ideal for fetching the initial data needed when a user
  /// logs in or opens the app.
  ///
  /// - [limit]: The maximum number of programs and session logs to retrieve.
  ///
  /// Returns a [Profile] object populated with the user's data.
  /// Throws an [Exception] if the RPC call fails or returns no data.
  static Future<Profile> getProfileWithInitialData({required int limit}) async {
    try {
      final dynamic response = await TrainerAPI.client.rpc(
        'get_profile_with_initial_data',
        params: <String, dynamic>{'p_limit': limit},
      );

      if (response == null) {
        throw Exception('Failed to retrieve profile: No data returned.');
      }

      return Profile.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to retrieve profile: $e');
    }
  }

  /// Signs up a new user with email, password, and username.
  ///
  /// - [email]: The user's email address.
  /// - [password]: The user's chosen password.
  /// - [username]: The user's unique username.
  /// - [fullName]: An optional full name for the user.
  ///
  /// Throws an [AuthException] if sign-up fails.
  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      final AuthResponse response = await TrainerAPI.authManager.signUp(
        email: email,
        password: password,
        data: <String, dynamic>{
          'username': username,
          'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw const AuthException('User is null after sign up.');
      }
    } on AuthException {
      rethrow;
    }
  }

  /// Signs in an existing user with their email and password.
  ///
  /// - [email]: The email address of the user.
  /// - [password]: The password of the user.
  ///
  /// Throws an [AuthException] if sign-in fails.
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await TrainerAPI.authManager.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException {
      rethrow;
    }
  }

  /// Signs out the currently signed-in user.
  ///
  /// Throws an [AuthException] if sign-out fails.
  static Future<void> signOut() async {
    try {
      await TrainerAPI.authManager.signOut();
    } on AuthException {
      rethrow;
    }
  }

  /// Initiates the Google OAuth sign-in flow.
  ///
  /// Throws an [AuthException] if the process fails.
  static Future<void> signInWithGoogle() async {
    try {
      await TrainerAPI.authManager.signInWithOAuth(OAuthProvider.google);
    } on AuthException {
      rethrow;
    }
  }

  /// Initiates the Apple OAuth sign-in flow.
  ///
  /// Throws an [AuthException] if the process fails.
  static Future<void> signInWithApple() async {
    try {
      await TrainerAPI.authManager.signInWithOAuth(OAuthProvider.apple);
    } on AuthException {
      rethrow;
    }
  }

  /// Deletes the user's account from the database.
  ///
  /// This is a permanent action and cannot be undone.
  ///
  /// Throws an [Exception] if the operation fails.
  static Future<void> deleteAccount() async {
    try {
      await TrainerAPI.client.rpc('delete_user_account');
    } catch (e) {
      // It's better to catch a generic exception here as RPC can throw various errors.
      throw Exception('Failed to delete account: $e');
    }
  }

  // --- Account Confirmation (OTP) ---

  /// Verifies the OTP sent to the user's email after signing up.
  ///
  /// - [email]: The user's email address.
  /// - [token]: The OTP token received by the user.
  ///
  /// Throws an [AuthException] if OTP verification fails.
  static Future<void> confirmSignUp({
    required String email,
    required String token,
  }) async {
    try {
      final AuthResponse response = await TrainerAPI.authManager.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      if (response.session == null) {
        throw const AuthException('No session received after sign up confirmation.');
      }
    } on AuthException {
      rethrow;
    }
  }

  /// Resends the confirmation code to the user's email.
  ///
  /// - [email]: The email address to which the code should be resent.
  ///
  /// Throws an [AuthException] if the operation fails.
  static Future<void> resendConfirmationCode({required String email}) async {
    try {
      await TrainerAPI.authManager.resend(
        email: email,
        type: OtpType.signup,
      );
    } on AuthException {
      rethrow;
    }
  }

  // --- Password Reset (OTP) ---

  /// Triggers the sending of a password reset code to the user's email.
  ///
  /// IMPORTANT: For this to work, you must edit the "Password Reset"
  /// email template in your Supabase project to send the `{{ .Token }}`
  /// instead of a confirmation link.
  ///
  /// - [email]: The user's email address.
  ///
  /// Throws an [AuthException] if the operation fails.
  static Future<void> sendPasswordResetCode({required String email}) async {
    try {
      await TrainerAPI.authManager.resetPasswordForEmail(email);
    } on AuthException {
      rethrow;
    }
  }

  /// Verifies the password reset code and signs the user in.
  ///
  /// - [email]: The user's email address.
  /// - [token]: The OTP token received by the user.
  ///
  /// Throws an [AuthException] if verification fails.
  static Future<void> verifyPasswordResetCode({
    required String email,
    required String token,
  }) async {
    try {
      final AuthResponse response = await TrainerAPI.authManager.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      if (response.session == null) {
        throw const AuthException('No session received after password reset verification.');
      }
    } on AuthException {
      rethrow;
    }
  }

  /// Updates the password for the currently signed-in user.
  ///
  /// - [newPassword]: The new password to set for the user.
  ///
  /// Throws an [AuthException] if the update fails.
  static Future<void> updatePassword({required String newPassword}) async {
    try {
      await TrainerAPI.authManager.updateUser(UserAttributes(password: newPassword));
    } on AuthException {
      rethrow;
    }
  }
}
