// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_access.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FeatureAccessCWProxy {
  FeatureAccess hasAccess(bool hasAccess);

  FeatureAccess featureKey(String featureKey);

  FeatureAccess limits(SubscriptionSummaryLimits? limits);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeatureAccess(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeatureAccess(...).copyWith(id: 12, name: "My name")
  /// ````
  FeatureAccess call({
    bool hasAccess,
    String featureKey,
    SubscriptionSummaryLimits? limits,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFeatureAccess.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFeatureAccess.copyWith.fieldName(...)`
class _$FeatureAccessCWProxyImpl implements _$FeatureAccessCWProxy {
  const _$FeatureAccessCWProxyImpl(this._value);

  final FeatureAccess _value;

  @override
  FeatureAccess hasAccess(bool hasAccess) => this(hasAccess: hasAccess);

  @override
  FeatureAccess featureKey(String featureKey) => this(featureKey: featureKey);

  @override
  FeatureAccess limits(SubscriptionSummaryLimits? limits) =>
      this(limits: limits);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeatureAccess(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeatureAccess(...).copyWith(id: 12, name: "My name")
  /// ````
  FeatureAccess call({
    Object? hasAccess = const $CopyWithPlaceholder(),
    Object? featureKey = const $CopyWithPlaceholder(),
    Object? limits = const $CopyWithPlaceholder(),
  }) {
    return FeatureAccess(
      hasAccess: hasAccess == const $CopyWithPlaceholder()
          ? _value.hasAccess
          // ignore: cast_nullable_to_non_nullable
          : hasAccess as bool,
      featureKey: featureKey == const $CopyWithPlaceholder()
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
  /// Returns a callable class that can be used as follows: `instanceOfFeatureAccess.copyWith(...)` or like so:`instanceOfFeatureAccess.copyWith.fieldName(...)`.
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
