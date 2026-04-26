import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/exceptions/trainer_backend_exception.dart';

/// Error codes for authentication failures.
enum TrainerBackendAuthErrorCode {
  /// The provided credentials (email/password) are incorrect.
  invalidCredentials,

  /// The email address format is invalid.
  invalidEmail,

  /// The email address is already registered.
  emailAlreadyUsed,

  /// The password does not meet minimum strength requirements.
  weakPassword,

  /// The account email has not been confirmed yet.
  emailNotConfirmed,

  /// The OTP token provided is invalid.
  invalidOtp,

  /// The OTP token has expired.
  expiredOtp,

  /// Too many requests have been made in a short period.
  tooManyRequests,

  /// No active session was found when one was required.
  sessionMissing,

  /// The operation requires authentication that is missing or insufficient.
  unauthorized,

  /// A network-level error prevented the request from completing.
  network,

  /// An unrecognised authentication error occurred.
  unknown,
}

/// An exception raised when an authentication operation fails.
///
/// Wraps Supabase [AuthException] into a stable, testable domain exception.
/// Use [TrainerBackendAuthException.fromAuthException] to construct from a
/// raw Supabase error, or [TrainerBackendAuthException.sessionMissing] for
/// wrapper-level invariant violations.
final class TrainerBackendAuthException extends TrainerBackendException {
  const TrainerBackendAuthException({
    required this.code,
    required super.message,
    this.statusCode,
    super.cause,
  });

  factory TrainerBackendAuthException.fromAuthException(
    AuthException exception,
  ) =>
      _mapAuthApiException(exception) ??
      _mapAuthStatusCode(exception) ??
      _mapClientAuthException(exception) ??
      _mapLegacyMessageFallback(exception) ??
      TrainerBackendAuthException(
        code: TrainerBackendAuthErrorCode.unknown,
        message: exception.message,
        statusCode: exception.statusCode,
        cause: exception,
      );

  /// Used for invariants enforced by this wrapper when Supabase returns a
  /// successful auth response without the session the app requires.
  const TrainerBackendAuthException.sessionMissing({
    super.message = 'Authentication session is missing.',
    this.statusCode,
    super.cause,
  }) : code = TrainerBackendAuthErrorCode.sessionMissing;

  /// The normalised error code for this authentication failure.
  final TrainerBackendAuthErrorCode code;

  /// The HTTP status code returned by Supabase, if available.
  final String? statusCode;

  static TrainerBackendAuthException? _mapAuthApiException(
    AuthException exception,
  ) {
    final String? code = exception.code?.toLowerCase();
    if (code == null) return null;

    return switch (code) {
      'invalid_credentials' =>
        _build(TrainerBackendAuthErrorCode.invalidCredentials, exception),
      'email_not_confirmed' =>
        _build(TrainerBackendAuthErrorCode.emailNotConfirmed, exception),
      'weak_password' =>
        _build(TrainerBackendAuthErrorCode.weakPassword, exception),
      'email_exists' ||
      'user_already_exists' =>
        _build(TrainerBackendAuthErrorCode.emailAlreadyUsed, exception),
      'otp_expired' => _mapOtpExpiredCode(exception),
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' ||
      'over_sms_send_rate_limit' =>
        _build(TrainerBackendAuthErrorCode.tooManyRequests, exception),
      'no_authorization' ||
      'not_admin' =>
        _build(TrainerBackendAuthErrorCode.unauthorized, exception),
      // `validation_failed` is shared by multiple API validation errors.
      'validation_failed' => _mapValidationFailure(exception),
      _ => null,
    };
  }

  static TrainerBackendAuthException? _mapValidationFailure(
    AuthException exception,
  ) {
    final String normalizedMessage = exception.message.toLowerCase();

    if (_looksLikeInvalidEmail(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.invalidEmail, exception);
    }

    if (_looksLikeInvalidOtp(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.invalidOtp, exception);
    }

    if (_looksLikeExpiredOtp(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.expiredOtp, exception);
    }

    return null;
  }

  static TrainerBackendAuthException? _mapAuthStatusCode(
    AuthException exception,
  ) => switch (exception.statusCode) {
    '429' => _build(TrainerBackendAuthErrorCode.tooManyRequests, exception),
    '401' || '403' => _build(TrainerBackendAuthErrorCode.unauthorized, exception),
    _ => null,
  };

  static TrainerBackendAuthException? _mapClientAuthException(
    AuthException exception,
  ) {
    if (exception is AuthRetryableFetchException ||
        exception is AuthUnknownException &&
            _isNetworkIssue(exception.message.toLowerCase())) {
      return _build(TrainerBackendAuthErrorCode.network, exception);
    }

    if (exception is AuthSessionMissingException) {
      return _build(TrainerBackendAuthErrorCode.sessionMissing, exception);
    }

    if (exception is AuthWeakPasswordException) {
      return _build(TrainerBackendAuthErrorCode.weakPassword, exception);
    }

    return null;
  }

  static TrainerBackendAuthException? _mapLegacyMessageFallback(
    AuthException exception,
  ) {
    final String normalizedMessage = exception.message.toLowerCase();

    // Last-resort compatibility fallback when the SDK does not provide a stable
    // code. Keep this narrow and delete branches as soon as Supabase exposes a
    // first-class code for the scenario.
    if (_looksLikeInvalidEmail(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.invalidEmail, exception);
    }

    if (_looksLikeInvalidOtp(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.invalidOtp, exception);
    }

    if (_looksLikeExpiredOtp(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.expiredOtp, exception);
    }

    if (_looksLikeEmailAlreadyUsed(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.emailAlreadyUsed, exception);
    }

    if (_looksLikeInvalidCredentials(normalizedMessage)) {
      return _build(
        TrainerBackendAuthErrorCode.invalidCredentials,
        exception,
      );
    }

    if (_isNetworkIssue(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.network, exception);
    }

    return null;
  }

  static TrainerBackendAuthException _build(
    TrainerBackendAuthErrorCode code,
    AuthException exception,
  ) => TrainerBackendAuthException(
    code: code,
    message: exception.message,
    statusCode: exception.statusCode,
    cause: exception,
  );

  static TrainerBackendAuthException _mapOtpExpiredCode(
    AuthException exception,
  ) {
    final String normalizedMessage = exception.message.toLowerCase();

    if (_looksLikeInvalidOtp(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.invalidOtp, exception);
    }

    return _build(TrainerBackendAuthErrorCode.expiredOtp, exception);
  }

  static bool _looksLikeInvalidEmail(String normalizedMessage) =>
      normalizedMessage.contains('invalid email') ||
      normalizedMessage.contains('email address is invalid');

  static bool _looksLikeInvalidOtp(String normalizedMessage) =>
      normalizedMessage.contains('invalid otp') ||
      normalizedMessage.contains('token has expired or is invalid');

  static bool _looksLikeExpiredOtp(String normalizedMessage) =>
      normalizedMessage.contains('expired') &&
      !normalizedMessage.contains('invalid');

  static bool _looksLikeEmailAlreadyUsed(String normalizedMessage) =>
      normalizedMessage.contains('already registered') ||
      normalizedMessage.contains('already been registered') ||
      normalizedMessage.contains('already exists') ||
      normalizedMessage.contains('user already registered');

  static bool _looksLikeInvalidCredentials(String normalizedMessage) =>
      normalizedMessage.contains('invalid login credentials') ||
      normalizedMessage.contains('invalid credentials') ||
      normalizedMessage.contains('invalid email or password');

  static bool _isNetworkIssue(String normalizedMessage) =>
      normalizedMessage.contains('failed host lookup') ||
      normalizedMessage.contains('network') ||
      normalizedMessage.contains('connection') ||
      normalizedMessage.contains('socketexception') ||
      normalizedMessage.contains('timeout');
}
