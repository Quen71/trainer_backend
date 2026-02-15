import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/subscriptions/enums/subscription_status.dart';

/// JSON converter for [SubscriptionStatus] enum.
///
/// Converts between PostgreSQL snake_case format (e.g., 'in_grace')
/// and Dart enum values (e.g., SubscriptionStatus.inGrace).
class SubscriptionStatusConverter implements JsonConverter<SubscriptionStatus, String> {
  /// Creates a new [SubscriptionStatusConverter].
  const SubscriptionStatusConverter();

  @override
  SubscriptionStatus fromJson(String json) {
    switch (json) {
      case 'active':
        return SubscriptionStatus.active;
      case 'trialing':
        return SubscriptionStatus.trialing;
      case 'in_grace':
        return SubscriptionStatus.inGrace;
      case 'paused':
        return SubscriptionStatus.paused;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'free':
        return SubscriptionStatus.free;
      default:
        return SubscriptionStatus.expired;
    }
  }

  @override
  String toJson(SubscriptionStatus object) {
    switch (object) {
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.trialing:
        return 'trialing';
      case SubscriptionStatus.inGrace:
        return 'in_grace';
      case SubscriptionStatus.paused:
        return 'paused';
      case SubscriptionStatus.cancelled:
        return 'cancelled';
      case SubscriptionStatus.expired:
        return 'expired';
      case SubscriptionStatus.free:
        return 'free';
    }
  }
}
