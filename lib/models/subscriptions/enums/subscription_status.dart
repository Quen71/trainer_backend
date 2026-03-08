import 'package:json_annotation/json_annotation.dart';

/// Represents the status of a subscription.
@JsonEnum()
enum SubscriptionStatus {
  /// The subscription is active and the user has access to premium features.
  active,

  /// The subscription is in trial period.
  trialing,

  /// The subscription is in grace period (payment failed but access temporarily maintained).
  inGrace,

  /// The subscription is paused (Google Play specific).
  paused,

  /// The subscription has been cancelled but is still valid until expiration.
  cancelled,

  /// The subscription has expired and the user no longer has access.
  expired,

  /// The user is on the free plan with no active subscription.
  free,
}
