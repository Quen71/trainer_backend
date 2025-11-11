import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:trainer_backend/models/subscriptions/offering.dart';

part 'offerings.g.dart';

/// Represents all available offerings from RevenueCat.
///
/// This model contains all offerings and the current offering if available.
/// It abstracts the RevenueCat Offerings type to avoid direct dependencies.
@CopyWith()
class Offerings {
  /// Creates an instance of [Offerings].
  const Offerings({
    required this.all,
    this.current,
  });

  /// Map of all available offerings, keyed by identifier.
  final Map<String, Offering> all;

  /// The current offering if one is set.
  final Offering? current;
}
