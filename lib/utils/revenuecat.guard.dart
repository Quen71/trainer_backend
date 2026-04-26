import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:trainer_backend/exceptions/exceptions.export.dart';

/// Guards a RevenueCat SDK call and normalizes failures into the
/// [TrainerBackendException] hierarchy.
///
/// RevenueCat SDK errors are surfaced as [TrainerBackendPurchaseException].
/// Existing [TrainerBackendException] instances are rethrown unchanged, and any
/// unexpected error is wrapped in [TrainerBackendUnknownException].
class RevenueCatGuard {
  /// Private constructor to prevent instantiation.
  const RevenueCatGuard._();

  /// Executes [body] and maps RevenueCat errors into backend exceptions.
  ///
  /// - [operation]: The name of the calling service method, used as context in
  ///   every thrown exception.
  /// - [body]: The async function that performs the RevenueCat SDK call.
  static Future<T> run<T>({
    required String operation,
    required Future<T> Function() body,
  }) async {
    try {
      return await body();
    } on rc.PurchasesError catch (error) {
      throw TrainerBackendPurchaseException.fromPurchasesError(
        operation: operation,
        error: error,
      );
    } catch (error) {
      if (error is TrainerBackendException) rethrow;
      throw TrainerBackendUnknownException(
        operation: operation,
        message: 'An unexpected error occurred during $operation.',
        cause: error,
      );
    }
  }
}
