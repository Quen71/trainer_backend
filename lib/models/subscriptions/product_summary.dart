import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_summary.g.dart';

/// Represents product information within a subscription summary.
///
/// This model contains basic product details returned from the
/// subscription summary RPC call.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class ProductSummary {
  /// Creates an instance of [ProductSummary].
  const ProductSummary({
    required this.id,
    required this.productId,
    required this.vendor,
    this.periodInterval,
  });

  /// Creates a [ProductSummary] from a JSON object.
  factory ProductSummary.fromJson(Map<String, dynamic> json) => _$ProductSummaryFromJson(json);

  /// The unique identifier for the product.
  final String id;

  /// The product identifier from the store (App Store, Play Store, etc.).
  @JsonKey(name: 'product_id')
  final String productId;

  /// The vendor name (e.g., 'app_store', 'play_store', 'stripe').
  final String vendor;

  /// The period interval for the subscription (e.g., 'month', 'year').
  @JsonKey(name: 'period_interval')
  final String? periodInterval;

  /// Converts this [ProductSummary] to a JSON object.
  Map<String, dynamic> toJson() => _$ProductSummaryToJson(this);
}
