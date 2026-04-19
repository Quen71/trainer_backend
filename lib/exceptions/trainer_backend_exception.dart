import 'package:supabase_flutter/supabase_flutter.dart';

enum TrainerBackendAuthErrorCode {
  invalidCredentials,
  invalidEmail,
  emailAlreadyUsed,
  weakPassword,
  emailNotConfirmed,
  invalidOtp,
  expiredOtp,
  tooManyRequests,
  sessionMissing,
  unauthorized,
  network,
  unknown,
}

sealed class TrainerBackendException implements Exception {
  const TrainerBackendException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType(message: $message, cause: $cause)';
}

final class TrainerBackendAuthException extends TrainerBackendException {
  const TrainerBackendAuthException({required this.code, required super.message, this.statusCode, super.cause});

  factory TrainerBackendAuthException.fromAuthException(AuthException exception) =>
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
    String message = 'Authentication session is missing.',
    this.statusCode,
    Object? cause,
  }) : code = TrainerBackendAuthErrorCode.sessionMissing,
       super(message: message, cause: cause);

  final TrainerBackendAuthErrorCode code;
  final String? statusCode;

  static TrainerBackendAuthException? _mapAuthApiException(AuthException exception) {
    final String? code = exception.code?.toLowerCase();
    if (code == null) return null;

    return switch (code) {
      'invalid_credentials' => _build(TrainerBackendAuthErrorCode.invalidCredentials, exception),
      'email_not_confirmed' => _build(TrainerBackendAuthErrorCode.emailNotConfirmed, exception),
      'weak_password' => _build(TrainerBackendAuthErrorCode.weakPassword, exception),
      'email_exists' || 'user_already_exists' => _build(TrainerBackendAuthErrorCode.emailAlreadyUsed, exception),
      'otp_expired' => _mapOtpExpiredCode(exception),
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' ||
      'over_sms_send_rate_limit' => _build(TrainerBackendAuthErrorCode.tooManyRequests, exception),
      'no_authorization' || 'not_admin' => _build(TrainerBackendAuthErrorCode.unauthorized, exception),
      // `validation_failed` is shared by multiple API validation errors.
      'validation_failed' => _mapValidationFailure(exception),
      _ => null,
    };
  }

  static TrainerBackendAuthException? _mapValidationFailure(AuthException exception) {
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

  static TrainerBackendAuthException? _mapAuthStatusCode(AuthException exception) => switch (exception.statusCode) {
    '429' => _build(TrainerBackendAuthErrorCode.tooManyRequests, exception),
    '401' || '403' => _build(TrainerBackendAuthErrorCode.unauthorized, exception),
    _ => null,
  };

  static TrainerBackendAuthException? _mapClientAuthException(AuthException exception) {
    if (exception is AuthRetryableFetchException ||
        exception is AuthUnknownException && _isNetworkIssue(exception.message.toLowerCase())) {
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

  static TrainerBackendAuthException? _mapLegacyMessageFallback(AuthException exception) {
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
      return _build(TrainerBackendAuthErrorCode.invalidCredentials, exception);
    }

    if (_isNetworkIssue(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.network, exception);
    }

    return null;
  }

  static TrainerBackendAuthException _build(TrainerBackendAuthErrorCode code, AuthException exception) =>
      TrainerBackendAuthException(
        code: code,
        message: exception.message,
        statusCode: exception.statusCode,
        cause: exception,
      );

  static TrainerBackendAuthException _mapOtpExpiredCode(AuthException exception) {
    final String normalizedMessage = exception.message.toLowerCase();

    if (_looksLikeInvalidOtp(normalizedMessage)) {
      return _build(TrainerBackendAuthErrorCode.invalidOtp, exception);
    }

    return _build(TrainerBackendAuthErrorCode.expiredOtp, exception);
  }

  static bool _looksLikeInvalidEmail(String normalizedMessage) =>
      normalizedMessage.contains('invalid email') || normalizedMessage.contains('email address is invalid');

  static bool _looksLikeInvalidOtp(String normalizedMessage) =>
      normalizedMessage.contains('invalid otp') || normalizedMessage.contains('token has expired or is invalid');

  static bool _looksLikeExpiredOtp(String normalizedMessage) =>
      normalizedMessage.contains('expired') && !normalizedMessage.contains('invalid');

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

final class TrainerBackendRpcException extends TrainerBackendException {
  const TrainerBackendRpcException({
    required this.operation,
    required super.message,
    this.code,
    this.details,
    this.hint,
    super.cause,
  });

  factory TrainerBackendRpcException.fromPostgrestException({
    required String operation,
    required PostgrestException exception,
  }) => TrainerBackendRpcException(
    operation: operation,
    message: exception.message,
    code: exception.code,
    details: exception.details,
    hint: exception.hint,
    cause: exception,
  );

  final String operation;
  final String? code;
  final Object? details;
  final String? hint;
}

final class TrainerBackendNetworkException extends TrainerBackendException {
  const TrainerBackendNetworkException({required this.operation, required super.message, super.cause});

  final String operation;
}

final class TrainerBackendUnknownException extends TrainerBackendException {
  const TrainerBackendUnknownException({required this.operation, required super.message, super.cause});

  final String operation;
}
