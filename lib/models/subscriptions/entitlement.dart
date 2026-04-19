import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement.g.dart';

/// Represents an entitlement that grants access to specific features.
///
/// An entitlement is a feature flag that can be unlocked through subscriptions.
/// Multiple products can grant the same entitlement.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class Entitlement {
  /// Creates an instance of [Entitlement].
  const Entitlement({
    required this.id,
    required this.entitlementKey,
    required this.name,
    required this.createdAt,
  });

  /// Creates an [Entitlement] from a JSON object.
  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);

  /// The unique identifier for the entitlement.
  final String id;

  /// The unique key that identifies this entitlement (e.g., 'Premium', 'Pro').
  @JsonKey(name: 'entitlement_key')
  final String entitlementKey;

  /// The display name of the entitlement.
  final String name;

  /// The timestamp when the entitlement was created.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Converts this [Entitlement] to a JSON object.
  Map<String, dynamic> toJson() => _$EntitlementToJson(this);
}
