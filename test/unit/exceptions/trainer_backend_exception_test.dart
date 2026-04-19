import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/trainer_backend.dart';

void main() {
  group('TrainerBackendAuthException.fromAuthException', () {
    test('maps invalid credentials from API code', () {
      final AuthApiException error = AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.invalidCredentials);
      expect(result.cause, error);
    });

    test('maps email not confirmed from API code', () {
      final AuthApiException error = AuthApiException(
        'Email not confirmed',
        statusCode: '403',
        code: 'email_not_confirmed',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.emailNotConfirmed);
    });

    test('maps weak password from API code', () {
      final AuthApiException error = AuthApiException(
        'Password is too weak',
        statusCode: '400',
        code: 'weak_password',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.weakPassword);
    });

    test('maps email already used from API code', () {
      final AuthApiException error = AuthApiException(
        'A user with this email address has already been registered',
        statusCode: '422',
        code: 'user_already_exists',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.emailAlreadyUsed);
    });

    test('maps invalid email from validation_failed payload', () {
      final AuthApiException error = AuthApiException(
        'Email address is invalid',
        statusCode: '422',
        code: 'validation_failed',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.invalidEmail);
    });

    test('maps invalid otp from validation_failed payload', () {
      final AuthApiException error = AuthApiException(
        'Token has expired or is invalid',
        statusCode: '422',
        code: 'validation_failed',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.invalidOtp);
    });

    test('maps ambiguous otp_expired payload to invalid otp', () {
      final AuthApiException error = AuthApiException(
        'Token has expired or is invalid',
        statusCode: '422',
        code: 'otp_expired',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.invalidOtp);
    });

    test('maps expired otp from API code', () {
      final AuthApiException error = AuthApiException(
        'OTP has expired',
        statusCode: '422',
        code: 'otp_expired',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.expiredOtp);
    });

    test('maps rate limit from API code', () {
      final AuthApiException error = AuthApiException(
        'Rate limit exceeded',
        statusCode: '429',
        code: 'over_request_rate_limit',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.tooManyRequests);
    });

    test('maps unauthorized from status code fallback', () {
      const AuthException error = AuthException(
        'Unauthorized',
        statusCode: '401',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.unauthorized);
    });

    test('maps weak password from SDK fallback', () {
      final AuthWeakPasswordException error = AuthWeakPasswordException(
        message: 'Password is too weak',
        statusCode: '400',
        reasons: <String>['length'],
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.weakPassword);
    });

    test('maps network from SDK fallback', () {
      final AuthRetryableFetchException error = AuthRetryableFetchException(
        message: 'Failed host lookup',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.network);
    });

    test('maps session missing from SDK fallback', () {
      final AuthSessionMissingException error = AuthSessionMissingException();

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.sessionMissing);
    });

    test('falls back to unknown when no documented signal exists', () {
      const AuthException error = AuthException(
        'Unexpected auth failure',
        statusCode: '500',
      );

      final TrainerBackendAuthException result =
          TrainerBackendAuthException.fromAuthException(error);

      expect(result.code, TrainerBackendAuthErrorCode.unknown);
    });
  });

  group('TrainerBackendAuthException.sessionMissing', () {
    test('preserves the manual wrapper invariant contract', () {
      const TrainerBackendAuthException error =
          TrainerBackendAuthException.sessionMissing(
            message: 'No session received after sign up confirmation.',
          );

      expect(error.code, TrainerBackendAuthErrorCode.sessionMissing);
      expect(error.message, 'No session received after sign up confirmation.');
    });
  });

  group('TrainerBackendRpcException.fromPostgrestException', () {
    test('keeps operation and payload details', () {
      const PostgrestException error = PostgrestException(
        message: 'RPC failed',
        code: 'PGRST001',
        details: 'details',
        hint: 'hint',
      );

      final TrainerBackendRpcException result =
          TrainerBackendRpcException.fromPostgrestException(
            operation: 'getProfileWithInitialData',
            exception: error,
          );

      expect(result.operation, 'getProfileWithInitialData');
      expect(result.code, 'PGRST001');
      expect(result.details, 'details');
      expect(result.hint, 'hint');
      expect(result.cause, error);
    });
  });
}
