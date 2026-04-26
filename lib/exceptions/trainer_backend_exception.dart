import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for all exceptions raised by the `trainer_backend` package.
///
/// Subclasses cover specific failure domains:
/// - [TrainerBackendAuthException] — authentication errors
/// - [TrainerBackendSubscriptionException] — subscription limit / status errors
/// - [TrainerBackendPurchaseException] — in-app purchase errors
/// - [TrainerBackendRpcException] — Supabase RPC / Postgres errors
/// - [TrainerBackendNetworkException] — network-level failures
/// - [TrainerBackendUnknownException] — unexpected errors
abstract class TrainerBackendException implements Exception {
  const TrainerBackendException({required this.message, this.cause});

  /// Human-readable description of the error (English, technical).
  final String message;

  /// The original exception that caused this one, if any.
  final Object? cause;

  @override
  String toString() => '$runtimeType(message: $message, cause: $cause)';
}

/// An exception raised when a Supabase RPC call fails with a [PostgrestException].
///
/// The [code] and [details] fields mirror the Postgres error returned by
/// Supabase and can be used for fine-grained error discrimination.
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

  /// The name of the service method that triggered the failure.
  final String operation;

  /// The Postgres error code, if provided.
  final String? code;

  /// Additional details from the Postgres error, if provided.
  final Object? details;

  /// A hint from the Postgres error, if provided.
  final String? hint;
}

/// An exception raised when a network-level error prevents an operation.
final class TrainerBackendNetworkException extends TrainerBackendException {
  const TrainerBackendNetworkException({
    required this.operation,
    required super.message,
    super.cause,
  });

  /// The name of the service method that triggered the failure.
  final String operation;
}

/// An exception raised when an unexpected error occurs during an operation.
final class TrainerBackendUnknownException extends TrainerBackendException {
  const TrainerBackendUnknownException({
    required this.operation,
    required super.message,
    super.cause,
  });

  /// The name of the service method that triggered the failure.
  final String operation;
}
