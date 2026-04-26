import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/exceptions/exceptions.export.dart';

/// Guards a Supabase RPC call and normalizes all exceptions into the
/// [TrainerBackendException] hierarchy.
///
/// Every RPC call in the services follows the same error-handling contract:
/// 1. [PostgrestException] with a subscription message →
///    [TrainerBackendSubscriptionException]
/// 2. Other [PostgrestException] → [TrainerBackendRpcException]
/// 3. Any network-level error → [TrainerBackendNetworkException]
/// 4. Any other error → [TrainerBackendUnknownException]
///
/// Usage:
/// ```dart
/// return RpcGuard.run(
///   operation: 'createFullProgram',
///   body: () async { ... },
/// );
/// ```
class RpcGuard {
  const RpcGuard._();

  /// Executes [body] and maps any exception into a [TrainerBackendException].
  ///
  /// - [operation]: The name of the calling service method, used as context in
  ///   every thrown exception.
  /// - [body]: The async function that performs the RPC call.
  static Future<T> run<T>({
    required String operation,
    required Future<T> Function() body,
  }) async {
    try {
      return await body();
    } on PostgrestException catch (error) {
      if (TrainerBackendSubscriptionException.isSubscriptionError(error)) {
        throw TrainerBackendSubscriptionException.fromPostgrestException(
          operation: operation,
          exception: error,
        );
      }
      throw TrainerBackendRpcException.fromPostgrestException(
        operation: operation,
        exception: error,
      );
    } catch (error) {
      if (error is TrainerBackendException) rethrow;
      if (_isNetworkIssue(error)) {
        throw TrainerBackendNetworkException(
          operation: operation,
          message: 'A network error occurred during $operation.',
          cause: error,
        );
      }
      throw TrainerBackendUnknownException(
        operation: operation,
        message: 'An unexpected error occurred during $operation.',
        cause: error,
      );
    }
  }

  static bool _isNetworkIssue(Object error) {
    final String normalized = error.toString().toLowerCase();
    return normalized.contains('failed host lookup') ||
        normalized.contains('network') ||
        normalized.contains('connection') ||
        normalized.contains('socketexception') ||
        normalized.contains('timeout');
  }
}
