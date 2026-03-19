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

  CustomerInfo managementURL(String? managementURL);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CustomerInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CustomerInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  CustomerInfo call({
    Map<String, EntitlementInfo> entitlements,
    List<String> activeSubscriptions,
    List<String> allPurchasedProductIdentifiers,
    DateTime firstSeen,
    DateTime requestDate,
    String originalAppUserId,
    String? managementURL,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCustomerInfo.copyWith(...)` or call `instanceOfCustomerInfo.copyWith.fieldName(value)` for a single field.
class _$CustomerInfoCWProxyImpl implements _$CustomerInfoCWProxy {
  const _$CustomerInfoCWProxyImpl(this._value);

  final CustomerInfo _value;

  @override
  CustomerInfo entitlements(Map<String, EntitlementInfo> entitlements) =>
      call(entitlements: entitlements);

  @override
  CustomerInfo activeSubscriptions(List<String> activeSubscriptions) =>
      call(activeSubscriptions: activeSubscriptions);

  @override
  CustomerInfo allPurchasedProductIdentifiers(
          List<String> allPurchasedProductIdentifiers) =>
      call(allPurchasedProductIdentifiers: allPurchasedProductIdentifiers);

  @override
  CustomerInfo firstSeen(DateTime firstSeen) => call(firstSeen: firstSeen);

  @override
  CustomerInfo requestDate(DateTime requestDate) =>
      call(requestDate: requestDate);

  @override
  CustomerInfo originalAppUserId(String originalAppUserId) =>
      call(originalAppUserId: originalAppUserId);

  @override
  CustomerInfo managementURL(String? managementURL) =>
      call(managementURL: managementURL);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CustomerInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CustomerInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  CustomerInfo call({
    Object? entitlements = const $CopyWithPlaceholder(),
    Object? activeSubscriptions = const $CopyWithPlaceholder(),
    Object? allPurchasedProductIdentifiers = const $CopyWithPlaceholder(),
    Object? firstSeen = const $CopyWithPlaceholder(),
    Object? requestDate = const $CopyWithPlaceholder(),
    Object? originalAppUserId = const $CopyWithPlaceholder(),
    Object? managementURL = const $CopyWithPlaceholder(),
  }) {
    return CustomerInfo(
      entitlements:
          entitlements == const $CopyWithPlaceholder() || entitlements == null
              ? _value.entitlements
              // ignore: cast_nullable_to_non_nullable
              : entitlements as Map<String, EntitlementInfo>,
      activeSubscriptions:
          activeSubscriptions == const $CopyWithPlaceholder() ||
                  activeSubscriptions == null
              ? _value.activeSubscriptions
              // ignore: cast_nullable_to_non_nullable
              : activeSubscriptions as List<String>,
      allPurchasedProductIdentifiers:
          allPurchasedProductIdentifiers == const $CopyWithPlaceholder() ||
                  allPurchasedProductIdentifiers == null
              ? _value.allPurchasedProductIdentifiers
              // ignore: cast_nullable_to_non_nullable
              : allPurchasedProductIdentifiers as List<String>,
      firstSeen: firstSeen == const $CopyWithPlaceholder() || firstSeen == null
          ? _value.firstSeen
          // ignore: cast_nullable_to_non_nullable
          : firstSeen as DateTime,
      requestDate:
          requestDate == const $CopyWithPlaceholder() || requestDate == null
              ? _value.requestDate
              // ignore: cast_nullable_to_non_nullable
              : requestDate as DateTime,
      originalAppUserId: originalAppUserId == const $CopyWithPlaceholder() ||
              originalAppUserId == null
          ? _value.originalAppUserId
          // ignore: cast_nullable_to_non_nullable
          : originalAppUserId as String,
      managementURL: managementURL == const $CopyWithPlaceholder()
          ? _value.managementURL
          // ignore: cast_nullable_to_non_nullable
          : managementURL as String?,
    );
  }
}

extension $CustomerInfoCopyWith on CustomerInfo {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCustomerInfo.copyWith(...)` or `instanceOfCustomerInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerInfoCWProxy get copyWith => _$CustomerInfoCWProxyImpl(this);
}
