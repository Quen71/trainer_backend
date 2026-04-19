import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/exceptions/trainer_backend_exception.dart';

void validateSignUpResponse(AuthResponse response) {
  final User? user = response.user;

  if (user == null) {
    throw const TrainerBackendUnknownException(
      operation: 'signUp',
      message: 'Failed to sign up: User is null after sign up.',
    );
  }

  if (_isExistingUserEmailSignUpResponse(response)) {
    throw const TrainerBackendAuthException(
      code: TrainerBackendAuthErrorCode.emailAlreadyUsed,
      message: 'An account already exists for this email address.',
    );
  }
}

bool _isExistingUserEmailSignUpResponse(AuthResponse response) {
  final User? user = response.user;
  if (user == null) return false;

  // Supabase can mask duplicate-email sign-up attempts by returning a user
  // without a session and with an empty identities list instead of throwing.
  return response.session == null && user.identities?.isEmpty == true;
}
