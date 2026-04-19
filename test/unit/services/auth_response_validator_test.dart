import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/exceptions/trainer_backend_exception.dart';
import 'package:trainer_backend/services/auth_response_validator.dart';

void main() {
  group('validateSignUpResponse', () {
    test('throws unknown when Supabase returns no user', () {
      expect(
        () => validateSignUpResponse(AuthResponse()),
        throwsA(
          isA<TrainerBackendUnknownException>().having(
            (TrainerBackendUnknownException error) => error.operation,
            'operation',
            'signUp',
          ),
        ),
      );
    });

    test('throws email already used for obfuscated duplicate sign-up response', () {
      final AuthResponse response = AuthResponse(user: _buildUser(identities: const <UserIdentity>[]));

      expect(
        () => validateSignUpResponse(response),
        throwsA(
          isA<TrainerBackendAuthException>().having(
            (TrainerBackendAuthException error) => error.code,
            'code',
            TrainerBackendAuthErrorCode.emailAlreadyUsed,
          ),
        ),
      );
    });

    test('accepts a regular confirmation-pending sign-up response', () {
      final AuthResponse response = AuthResponse(user: _buildUser(identities: <UserIdentity>[_buildIdentity()]));

      expect(() => validateSignUpResponse(response), returnsNormally);
    });
  });
}

User _buildUser({required List<UserIdentity> identities}) => User(
  id: 'user-id',
  appMetadata: const <String, dynamic>{'provider': 'email'},
  userMetadata: const <String, dynamic>{'username': 'new-user'},
  aud: 'authenticated',
  email: 'test@example.com',
  createdAt: '2026-04-14T12:00:00.000Z',
  identities: identities,
);

UserIdentity _buildIdentity() => const UserIdentity(
  id: 'identity-id',
  userId: 'user-id',
  identityData: <String, dynamic>{'email': 'test@example.com'},
  identityId: 'identity-email-id',
  provider: 'email',
  createdAt: '2026-04-14T12:00:00.000Z',
  lastSignInAt: '2026-04-14T12:00:00.000Z',
);
