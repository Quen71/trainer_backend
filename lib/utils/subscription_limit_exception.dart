/// Exception class for parsing subscription limit errors from PostgreSQL.
///
/// This utility class helps parse structured error messages from the database
/// that indicate subscription limit violations. The error messages follow a
/// specific format with error codes and additional information.
class SubscriptionLimitException implements Exception {
  /// Creates a [SubscriptionLimitException] from a PostgreSQL error message.
  ///
  /// Parses error messages in the format:
  /// - `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y Message`
  /// - `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y Message`
  /// - `LIMIT_EXCEEDED:MAX_EXERCISES:X/Y Message`
  /// - `SUBSCRIPTION_INACTIVE Message`
  /// - `SUBSCRIPTION_EXPIRED Message`
  ///
  /// - [message]: The error message from PostgreSQL.
  factory SubscriptionLimitException.fromMessage(String message) {
    // Parse LIMIT_EXCEEDED errors
    if (message.startsWith('LIMIT_EXCEEDED:')) {
      final List<String> parts = message.split(':');
      if (parts.length >= 3) {
        final String limitType = parts[1]; // MAX_PROGRAMS, MAX_SESSIONS, MAX_EXERCISES
        final String counts = parts[2].split(' ')[0]; // X/Y
        final List<String> countParts = counts.split('/');
        final int? current = int.tryParse(countParts[0]);
        final int? max = countParts.length > 1 ? int.tryParse(countParts[1]) : null;
        final String userMessage = parts.length > 2
            ? parts.sublist(2).join(':').split(' ').skip(1).join(' ')
            : message;

        return SubscriptionLimitException._(
          errorCode: 'LIMIT_EXCEEDED:$limitType',
          limitType: limitType,
          currentCount: current,
          maxAllowed: max,
          message: userMessage,
          originalMessage: message,
        );
      }
    }

    // Parse SUBSCRIPTION_INACTIVE errors
    if (message.startsWith('SUBSCRIPTION_INACTIVE')) {
      final String userMessage = message.replaceFirst('SUBSCRIPTION_INACTIVE', '').trim();
      return SubscriptionLimitException._(
        errorCode: 'SUBSCRIPTION_INACTIVE',
        limitType: null,
        currentCount: null,
        maxAllowed: null,
        message: userMessage,
        originalMessage: message,
      );
    }

    // Parse SUBSCRIPTION_EXPIRED errors
    if (message.startsWith('SUBSCRIPTION_EXPIRED')) {
      final String userMessage = message.replaceFirst('SUBSCRIPTION_EXPIRED', '').trim();
      return SubscriptionLimitException._(
        errorCode: 'SUBSCRIPTION_EXPIRED',
        limitType: null,
        currentCount: null,
        maxAllowed: null,
        message: userMessage,
        originalMessage: message,
      );
    }

    // Fallback for unrecognized format
    return SubscriptionLimitException._(
      errorCode: 'UNKNOWN',
      limitType: null,
      currentCount: null,
      maxAllowed: null,
      message: message,
      originalMessage: message,
    );
  }

  /// Private constructor.
  const SubscriptionLimitException._({
    required this.errorCode,
    this.limitType,
    this.currentCount,
    this.maxAllowed,
    required this.message,
    required this.originalMessage,
  });

  /// The error code (e.g., 'LIMIT_EXCEEDED:MAX_PROGRAMS', 'SUBSCRIPTION_INACTIVE').
  final String errorCode;

  /// The type of limit that was exceeded (e.g., 'MAX_PROGRAMS', 'MAX_SESSIONS', 'MAX_EXERCISES').
  /// Null for non-limit errors.
  final String? limitType;

  /// The current count when the limit was hit.
  /// Null if not applicable.
  final int? currentCount;

  /// The maximum allowed count.
  /// Null if not applicable.
  final int? maxAllowed;

  /// The user-friendly error message.
  final String message;

  /// The original error message from PostgreSQL.
  final String originalMessage;

  @override
  String toString() => originalMessage;

  /// Checks if this is a limit exceeded error.
  bool get isLimitExceeded => errorCode.startsWith('LIMIT_EXCEEDED');

  /// Checks if this is a subscription inactive error.
  bool get isSubscriptionInactive => errorCode == 'SUBSCRIPTION_INACTIVE';

  /// Checks if this is a subscription expired error.
  bool get isSubscriptionExpired => errorCode == 'SUBSCRIPTION_EXPIRED';
}
