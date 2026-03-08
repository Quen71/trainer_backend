import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:trainer_backend/models/subscriptions/package.dart';

part 'offering.g.dart';

/// Represents an offering containing available subscription packages.
///
/// An offering is a collection of packages that can be purchased.
/// It abstracts the RevenueCat Offering type to avoid direct dependencies.
@CopyWith()
class Offering {
  /// Creates an instance of [Offering].
  const Offering({
    required this.identifier,
    this.serverDescription,
    required this.availablePackages,
  });

  /// The unique identifier for this offering.
  final String identifier;

  /// Optional server-side description of the offering.
  final String? serverDescription;

  /// List of available packages in this offering.
  final List<Package> availablePackages;
}

