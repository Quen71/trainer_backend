// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProductSummaryCWProxy {
  ProductSummary id(String id);

  ProductSummary productId(String productId);

  ProductSummary vendor(String vendor);

  ProductSummary periodInterval(String? periodInterval);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProductSummary(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProductSummary(...).copyWith(id: 12, name: "My name")
  /// ```
  ProductSummary call({
    String id,
    String productId,
    String vendor,
    String? periodInterval,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProductSummary.copyWith(...)` or call `instanceOfProductSummary.copyWith.fieldName(value)` for a single field.
class _$ProductSummaryCWProxyImpl implements _$ProductSummaryCWProxy {
  const _$ProductSummaryCWProxyImpl(this._value);

  final ProductSummary _value;

  @override
  ProductSummary id(String id) => call(id: id);

  @override
  ProductSummary productId(String productId) => call(productId: productId);

  @override
  ProductSummary vendor(String vendor) => call(vendor: vendor);

  @override
  ProductSummary periodInterval(String? periodInterval) =>
      call(periodInterval: periodInterval);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProductSummary(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProductSummary(...).copyWith(id: 12, name: "My name")
  /// ```
  ProductSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? productId = const $CopyWithPlaceholder(),
    Object? vendor = const $CopyWithPlaceholder(),
    Object? periodInterval = const $CopyWithPlaceholder(),
  }) {
    return ProductSummary(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      productId: productId == const $CopyWithPlaceholder() || productId == null
          ? _value.productId
          // ignore: cast_nullable_to_non_nullable
          : productId as String,
      vendor: vendor == const $CopyWithPlaceholder() || vendor == null
          ? _value.vendor
          // ignore: cast_nullable_to_non_nullable
          : vendor as String,
      periodInterval: periodInterval == const $CopyWithPlaceholder()
          ? _value.periodInterval
          // ignore: cast_nullable_to_non_nullable
          : periodInterval as String?,
    );
  }
}

extension $ProductSummaryCopyWith on ProductSummary {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProductSummary.copyWith(...)` or `instanceOfProductSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProductSummaryCWProxy get copyWith => _$ProductSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSummary _$ProductSummaryFromJson(Map<String, dynamic> json) =>
    ProductSummary(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      vendor: json['vendor'] as String,
      periodInterval: json['period_interval'] as String?,
    );

Map<String, dynamic> _$ProductSummaryToJson(ProductSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'vendor': instance.vendor,
      'period_interval': instance.periodInterval,
    };
