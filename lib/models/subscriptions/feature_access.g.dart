// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_access.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FeatureAccessCWProxy {
  FeatureAccess hasAccess(bool hasAccess);

  FeatureAccess featureKey(String featureKey);

  FeatureAccess limits(SubscriptionSummaryLimits? limits);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FeatureAccess(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FeatureAccess(...).copyWith(id: 12, name: "My name")
  /// ```
  FeatureAccess call({
    bool hasAccess,
    String featureKey,
    SubscriptionSummaryLimits? limits,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfFeatureAccess.copyWith(...)` or call `instanceOfFeatureAccess.copyWith.fieldName(value)` for a single field.
class _$FeatureAccessCWProxyImpl implements _$FeatureAccessCWProxy {
  const _$FeatureAccessCWProxyImpl(this._value);

  final FeatureAccess _value;

  @override
  FeatureAccess hasAccess(bool hasAccess) => call(hasAccess: hasAccess);

  @override
  FeatureAccess featureKey(String featureKey) => call(featureKey: featureKey);

  @override
  FeatureAccess limits(SubscriptionSummaryLimits? limits) =>
      call(limits: limits);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FeatureAccess(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FeatureAccess(...).copyWith(id: 12, name: "My name")
  /// ```
  FeatureAccess call({
    Object? hasAccess = const $CopyWithPlaceholder(),
    Object? featureKey = const $CopyWithPlaceholder(),
    Object? limits = const $CopyWithPlaceholder(),
  }) {
    return FeatureAccess(
      hasAccess: hasAccess == const $CopyWithPlaceholder() || hasAccess == null
          ? _value.hasAccess
          // ignore: cast_nullable_to_non_nullable
          : hasAccess as bool,
      featureKey:
          featureKey == const $CopyWithPlaceholder() || featureKey == null
              ? _value.featureKey
              // ignore: cast_nullable_to_non_nullable
              : featureKey as String,
      limits: limits == const $CopyWithPlaceholder()
          ? _value.limits
          // ignore: cast_nullable_to_non_nullable
          : limits as SubscriptionSummaryLimits?,
    );
  }
}

extension $FeatureAccessCopyWith on FeatureAccess {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfFeatureAccess.copyWith(...)` or `instanceOfFeatureAccess.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FeatureAccessCWProxy get copyWith => _$FeatureAccessCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureAccess _$FeatureAccessFromJson(Map<String, dynamic> json) =>
    FeatureAccess(
      hasAccess: json['has_access'] as bool,
      featureKey: json['feature_key'] as String,
      limits: json['limits'] == null
          ? null
          : SubscriptionSummaryLimits.fromJson(
              json['limits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeatureAccessToJson(FeatureAccess instance) =>
    <String, dynamic>{
      'has_access': instance.hasAccess,
      'feature_key': instance.featureKey,
      'limits': instance.limits,
    };
