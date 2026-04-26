import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/exceptions/trainer_backend_exception.dart';

/// Error codes for subscription limit and status failures.
enum TrainerBackendSubscriptionErrorCode {
  /// The maximum number of programs allowed by the subscription has been reached.
  limitExceededMaxPrograms,

  /// The maximum number of sessions per program has been reached.
  limitExceededMaxSessions,

  /// The maximum number of exercises per session has been reached.
  limitExceededMaxExercisesPerSession,

  /// The user's subscription is not in an active state.
  subscriptionInactive,

  /// The user's subscription has expired.
  subscriptionExpired,

  /// An unrecognized subscription-related error occurred.
  unknown,
}

/// An exception raised when a Supabase RPC call fails due to a subscription
/// limit violation or an inactive / expired subscription.
///
/// The Supabase RPC functions raise errors with structured prefixes such as
/// `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y` or `SUBSCRIPTION_INACTIVE`. This class
/// parses those messages and exposes a stable [code] for consumer discrimination.
///
/// Use [TrainerBackendSubscriptionException.isSubscriptionError] to detect
/// whether a [PostgrestException] should be wrapped by this type before
/// falling back to [TrainerBackendRpcException].
final class TrainerBackendSubscriptionException extends TrainerBackendException {
  const TrainerBackendSubscriptionException({
    required this.code,
    required this.operation,
    required super.message,
    this.currentCount,
    this.maxAllowed,
    super.cause,
  });

  factory TrainerBackendSubscriptionException.fromPostgrestException({
    required String operation,
    required PostgrestException exception,
  }) {
    final String msg = exception.message;
    final TrainerBackendSubscriptionErrorCode code = _parseCode(msg);
    final ({int? current, int? max}) counts = _parseCounts(msg);

    return TrainerBackendSubscriptionException(
      code: code,
      operation: operation,
      message: msg,
      currentCount: counts.current,
      maxAllowed: counts.max,
      cause: exception,
    );
  }

  /// Returns `true` when [exception] carries a subscription-related message
  /// and should be wrapped in [TrainerBackendSubscriptionException] rather
  /// than [TrainerBackendRpcException].
  static bool isSubscriptionError(PostgrestException exception) {
    final String msg = exception.message;
    return msg.startsWith('LIMIT_EXCEEDED:') ||
        msg.startsWith('SUBSCRIPTION_INACTIVE') ||
        msg.startsWith('SUBSCRIPTION_EXPIRED');
  }

  /// The normalized error code for this subscription failure.
  final TrainerBackendSubscriptionErrorCode code;

  /// The name of the service method that triggered the failure.
  final String operation;

  /// The current resource count when the limit was hit, if available.
  final int? currentCount;

  /// The maximum allowed resource count, if available.
  final int? maxAllowed;

  static TrainerBackendSubscriptionErrorCode _parseCode(String message) {
    if (message.startsWith('LIMIT_EXCEEDED:MAX_PROGRAMS')) {
      return TrainerBackendSubscriptionErrorCode.limitExceededMaxPrograms;
    }
    if (message.startsWith('LIMIT_EXCEEDED:MAX_SESSIONS')) {
      return TrainerBackendSubscriptionErrorCode.limitExceededMaxSessions;
    }
    if (message.startsWith('LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION')) {
      return TrainerBackendSubscriptionErrorCode.limitExceededMaxExercisesPerSession;
    }
    if (message.startsWith('SUBSCRIPTION_INACTIVE')) {
      return TrainerBackendSubscriptionErrorCode.subscriptionInactive;
    }
    if (message.startsWith('SUBSCRIPTION_EXPIRED')) {
      return TrainerBackendSubscriptionErrorCode.subscriptionExpired;
    }
    return TrainerBackendSubscriptionErrorCode.unknown;
  }

  /// Parses the `X/Y` counts embedded in `LIMIT_EXCEEDED:TYPE:X/Y ...` messages.
  static ({int? current, int? max}) _parseCounts(String message) {
    if (!message.startsWith('LIMIT_EXCEEDED:')) {
      return (current: null, max: null);
    }

    final List<String> parts = message.split(':');
    if (parts.length < 3) return (current: null, max: null);

    final String countsPart = parts[2].split(' ').first;
    final List<String> counts = countsPart.split('/');
    final int? current = int.tryParse(counts.firstOrNull ?? '');
    final int? max = counts.length > 1 ? int.tryParse(counts[1]) : null;

    return (current: current, max: max);
  }
}
