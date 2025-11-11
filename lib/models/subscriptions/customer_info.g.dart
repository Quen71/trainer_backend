// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerInfoCWProxy {
  CustomerInfo entitlements(Map<String, EntitlementInfo> entitlements);

  CustomerInfo activeSubscriptions(List<String> activeSubscriptions);

  CustomerInfo allPurchasedProductIdentifiers(
      List<String> allPurchasedProductIdentifiers);

  CustomerInfo firstSeen(DateTime firstSeen);

  CustomerInfo requestDate(DateTime requestDate);

  CustomerInfo originalAppUserId(String originalAppUserId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerInfo call({
    Map<String, EntitlementInfo> entitlements,
    List<String> activeSubscriptions,
    List<String> allPurchasedProductIdentifiers,
    DateTime firstSeen,
    DateTime requestDate,
    String originalAppUserId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerInfo.copyWith.fieldName(...)`
class _$CustomerInfoCWProxyImpl implements _$CustomerInfoCWProxy {
  const _$CustomerInfoCWProxyImpl(this._value);

  final CustomerInfo _value;

  @override
  CustomerInfo entitlements(Map<String, EntitlementInfo> entitlements) =>
      this(entitlements: entitlements);

  @override
  CustomerInfo activeSubscriptions(List<String> activeSubscriptions) =>
      this(activeSubscriptions: activeSubscriptions);

  @override
  CustomerInfo allPurchasedProductIdentifiers(
          List<String> allPurchasedProductIdentifiers) =>
      this(allPurchasedProductIdentifiers: allPurchasedProductIdentifiers);

  @override
  CustomerInfo firstSeen(DateTime firstSeen) => this(firstSeen: firstSeen);

  @override
  CustomerInfo requestDate(DateTime requestDate) =>
      this(requestDate: requestDate);

  @override
  CustomerInfo originalAppUserId(String originalAppUserId) =>
      this(originalAppUserId: originalAppUserId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerInfo call({
    Object? entitlements = const $CopyWithPlaceholder(),
    Object? activeSubscriptions = const $CopyWithPlaceholder(),
    Object? allPurchasedProductIdentifiers = const $CopyWithPlaceholder(),
    Object? firstSeen = const $CopyWithPlaceholder(),
    Object? requestDate = const $CopyWithPlaceholder(),
    Object? originalAppUserId = const $CopyWithPlaceholder(),
  }) {
    return CustomerInfo(
      entitlements: entitlements == const $CopyWithPlaceholder()
          ? _value.entitlements
          // ignore: cast_nullable_to_non_nullable
          : entitlements as Map<String, EntitlementInfo>,
      activeSubscriptions: activeSubscriptions == const $CopyWithPlaceholder()
          ? _value.activeSubscriptions
          // ignore: cast_nullable_to_non_nullable
          : activeSubscriptions as List<String>,
      allPurchasedProductIdentifiers:
          allPurchasedProductIdentifiers == const $CopyWithPlaceholder()
              ? _value.allPurchasedProductIdentifiers
              // ignore: cast_nullable_to_non_nullable
              : allPurchasedProductIdentifiers as List<String>,
      firstSeen: firstSeen == const $CopyWithPlaceholder()
          ? _value.firstSeen
          // ignore: cast_nullable_to_non_nullable
          : firstSeen as DateTime,
      requestDate: requestDate == const $CopyWithPlaceholder()
          ? _value.requestDate
          // ignore: cast_nullable_to_non_nullable
          : requestDate as DateTime,
      originalAppUserId: originalAppUserId == const $CopyWithPlaceholder()
          ? _value.originalAppUserId
          // ignore: cast_nullable_to_non_nullable
          : originalAppUserId as String,
    );
  }
}

extension $CustomerInfoCopyWith on CustomerInfo {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerInfo.copyWith(...)` or like so:`instanceOfCustomerInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerInfoCWProxy get copyWith => _$CustomerInfoCWProxyImpl(this);
}
