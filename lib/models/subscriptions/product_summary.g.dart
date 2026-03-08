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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProductSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProductSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  ProductSummary call({
    String id,
    String productId,
    String vendor,
    String? periodInterval,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProductSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProductSummary.copyWith.fieldName(...)`
class _$ProductSummaryCWProxyImpl implements _$ProductSummaryCWProxy {
  const _$ProductSummaryCWProxyImpl(this._value);

  final ProductSummary _value;

  @override
  ProductSummary id(String id) => this(id: id);

  @override
  ProductSummary productId(String productId) => this(productId: productId);

  @override
  ProductSummary vendor(String vendor) => this(vendor: vendor);

  @override
  ProductSummary periodInterval(String? periodInterval) =>
      this(periodInterval: periodInterval);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProductSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProductSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  ProductSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? productId = const $CopyWithPlaceholder(),
    Object? vendor = const $CopyWithPlaceholder(),
    Object? periodInterval = const $CopyWithPlaceholder(),
  }) {
    return ProductSummary(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      productId: productId == const $CopyWithPlaceholder()
          ? _value.productId
          // ignore: cast_nullable_to_non_nullable
          : productId as String,
      vendor: vendor == const $CopyWithPlaceholder()
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
  /// Returns a callable class that can be used as follows: `instanceOfProductSummary.copyWith(...)` or like so:`instanceOfProductSummary.copyWith.fieldName(...)`.
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
