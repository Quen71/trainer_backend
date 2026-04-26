import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:trainer_backend/exceptions/trainer_backend_exception.dart';

/// Error codes for in-app purchase failures.
enum TrainerBackendPurchaseErrorCode {
  /// The user explicitly cancelled the purchase flow.
  purchaseCancelled,

  /// The device or account is not permitted to make purchases.
  purchaseNotAllowed,

  /// The requested product is not available in the store.
  productNotAvailable,

  /// The RevenueCat SDK has not been initialized yet.
  notInitialized,

  /// The requested package could not be found in the current offerings.
  packageNotFound,

  /// A network error prevented the purchase from completing.
  network,

  /// An unrecognized purchase error occurred.
  unknown,
}

/// An exception raised when a RevenueCat purchase operation fails.
///
/// Wraps [rc.PurchasesError] (and related validation failures) into a stable,
/// testable domain exception. Use [TrainerBackendPurchaseException.fromPurchasesError]
/// to construct from a raw RevenueCat error.
final class TrainerBackendPurchaseException extends TrainerBackendException {
  const TrainerBackendPurchaseException({
    required this.code,
    required this.operation,
    required super.message,
    super.cause,
  });

  factory TrainerBackendPurchaseException.fromPurchasesError({
    required String operation,
    required rc.PurchasesError error,
  }) => TrainerBackendPurchaseException(
    code: _mapErrorCode(error.code),
    operation: operation,
    message: error.message,
    cause: error,
  );

  /// Builds a [TrainerBackendPurchaseException] for a not-initialized error.
  const TrainerBackendPurchaseException.notInitialized({
    required this.operation,
    super.message = 'RevenueCat SDK not initialized.',
    super.cause,
  }) : code = TrainerBackendPurchaseErrorCode.notInitialized;

  /// Builds a [TrainerBackendPurchaseException] for a missing package error.
  const TrainerBackendPurchaseException.packageNotFound({required this.operation, required super.message, super.cause})
    : code = TrainerBackendPurchaseErrorCode.packageNotFound;

  /// The normalized error code for this purchase failure.
  final TrainerBackendPurchaseErrorCode code;

  /// The name of the service method that triggered the failure.
  final String operation;

  static TrainerBackendPurchaseErrorCode _mapErrorCode(rc.PurchasesErrorCode rcCode) => switch (rcCode) {
    rc.PurchasesErrorCode.purchaseCancelledError => TrainerBackendPurchaseErrorCode.purchaseCancelled,
    rc.PurchasesErrorCode.purchaseNotAllowedError ||
    rc.PurchasesErrorCode.insufficientPermissionsError => TrainerBackendPurchaseErrorCode.purchaseNotAllowed,
    rc.PurchasesErrorCode.productNotAvailableForPurchaseError => TrainerBackendPurchaseErrorCode.productNotAvailable,
    rc.PurchasesErrorCode.networkError ||
    rc.PurchasesErrorCode.offlineConnectionError => TrainerBackendPurchaseErrorCode.network,
    _ => TrainerBackendPurchaseErrorCode.unknown,
  };
}
