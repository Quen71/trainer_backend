import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:trainer_backend/constants/subscription.constants.dart';
import 'package:trainer_backend/models/subscriptions/customer_info.dart';
import 'package:trainer_backend/models/subscriptions/entitlement_info.dart';
import 'package:trainer_backend/models/subscriptions/enums/package_type.dart';
import 'package:trainer_backend/models/subscriptions/enums/period_unit.dart';
import 'package:trainer_backend/models/subscriptions/introductory_price.dart';
import 'package:trainer_backend/models/subscriptions/offering.dart';
import 'package:trainer_backend/models/subscriptions/offerings.dart';
import 'package:trainer_backend/models/subscriptions/package.dart';
import 'package:trainer_backend/models/subscriptions/store_product.dart';

/// Mapper class for converting RevenueCat SDK types to backend models.
///
/// This class provides static methods to convert RevenueCat objects
/// (from `purchases_flutter` package) to backend model objects used
/// throughout the application.
class RevenueCatMapper {
  /// Private constructor to prevent instantiation.
  const RevenueCatMapper._();

  /// Converts a RevenueCat StoreProduct to a backend StoreProduct model.
  ///
  /// This method also converts the introductory price information if available.
  /// Note: The Test Store does NOT support introductory offers, so
  /// `introductoryPrice` will be null when using the Test Store.
  static StoreProduct convertStoreProduct(rc.StoreProduct rcStoreProduct) {
    IntroductoryPrice? introductoryPrice;

    if (rcStoreProduct.introductoryPrice != null) {
      introductoryPrice = convertIntroductoryPrice(rcStoreProduct.introductoryPrice!);
    }

    return StoreProduct(
      identifier: rcStoreProduct.identifier,
      title: rcStoreProduct.title,
      description: rcStoreProduct.description,
      price: rcStoreProduct.price,
      priceString: rcStoreProduct.priceString,
      currencyCode: rcStoreProduct.currencyCode,
      introductoryPrice: introductoryPrice,
    );
  }

  /// Converts a RevenueCat IntroductoryPrice to a backend IntroductoryPrice model.
  static IntroductoryPrice convertIntroductoryPrice(rc.IntroductoryPrice rcIntro) => IntroductoryPrice(
        price: rcIntro.price,
        priceString: rcIntro.priceString,
        period: rcIntro.period,
        cycles: rcIntro.cycles,
        periodUnit: convertPeriodUnit(rcIntro.periodUnit),
        periodNumberOfUnits: rcIntro.periodNumberOfUnits,
      );

  /// Converts a RevenueCat PeriodUnit to a backend PeriodUnit enum.
  static PeriodUnit convertPeriodUnit(rc.PeriodUnit rcPeriodUnit) {
    switch (rcPeriodUnit) {
      case rc.PeriodUnit.day:
        return PeriodUnit.day;
      case rc.PeriodUnit.week:
        return PeriodUnit.week;
      case rc.PeriodUnit.month:
        return PeriodUnit.month;
      case rc.PeriodUnit.year:
        return PeriodUnit.year;
      default:
        return PeriodUnit.unknown;
    }
  }

  /// Converts a RevenueCat PackageType to a backend PackageType enum.
  ///
  /// This method maps RevenueCat PackageType enum values to the backend
  /// PackageType enum for type-safe handling throughout the application.
  ///
  /// - [type]: The RevenueCat PackageType to convert.
  ///
  /// Returns the corresponding backend [PackageType] enum value.
  static PackageType convertPackageType(rc.PackageType type) {
    switch (type) {
      case rc.PackageType.monthly:
        return PackageType.monthly;
      case rc.PackageType.annual:
        return PackageType.annual;
      case rc.PackageType.weekly:
        return PackageType.weekly;
      case rc.PackageType.sixMonth:
        return PackageType.sixMonth;
      case rc.PackageType.threeMonth:
        return PackageType.threeMonth;
      case rc.PackageType.twoMonth:
        return PackageType.twoMonth;
      case rc.PackageType.lifetime:
        return PackageType.lifetime;
      case rc.PackageType.custom:
        return PackageType.custom;
      default:
        return PackageType.unknown;
    }
  }

  /// Converts a RevenueCat Package to a backend Package model.
  ///
  /// The entitlement identifier is determined by looking up the product
  /// identifier in [SubscriptionConstants].
  ///
  /// The packageType field contains a typed enum value representing
  /// the subscription period (e.g., PackageType.monthly, PackageType.annual).
  static Package convertPackage(rc.Package rcPackage) {
    final String productId = rcPackage.storeProduct.identifier;
    final String? entitlementIdentifier = SubscriptionConstants.productToEntitlement[productId];

    return Package(
      identifier: rcPackage.identifier,
      packageType: convertPackageType(rcPackage.packageType),
      storeProduct: convertStoreProduct(rcPackage.storeProduct),
      entitlementIdentifier: entitlementIdentifier,
    );
  }

  /// Converts a RevenueCat Offering to a backend Offering model.
  static Offering convertOffering(rc.Offering rcOffering) => Offering(
        identifier: rcOffering.identifier,
        serverDescription: rcOffering.serverDescription,
        availablePackages: rcOffering.availablePackages.map(convertPackage).toList(),
      );

  /// Converts a RevenueCat Offerings to a backend Offerings model.
  static Offerings convertOfferings(rc.Offerings rcOfferings) {
    final Map<String, Offering> allOfferings = <String, Offering>{};
    for (final MapEntry<String, rc.Offering> entry in rcOfferings.all.entries) {
      allOfferings[entry.key] = convertOffering(entry.value);
    }

    return Offerings(
      all: allOfferings,
      current: rcOfferings.current != null ? convertOffering(rcOfferings.current!) : null,
    );
  }

  /// Converts a RevenueCat EntitlementInfo to a backend EntitlementInfo model.
  static EntitlementInfo convertEntitlementInfo(rc.EntitlementInfo rcEntitlementInfo) => EntitlementInfo(
        identifier: rcEntitlementInfo.identifier,
        isActive: rcEntitlementInfo.isActive,
        willRenew: rcEntitlementInfo.willRenew,
        periodType: rcEntitlementInfo.periodType.toString(),
        latestPurchaseDate: DateTime.parse(rcEntitlementInfo.latestPurchaseDate),
        originalPurchaseDate: DateTime.parse(rcEntitlementInfo.originalPurchaseDate),
        expirationDate:
            rcEntitlementInfo.expirationDate != null ? DateTime.parse(rcEntitlementInfo.expirationDate!) : null,
        store: rcEntitlementInfo.store.toString(),
        productIdentifier: rcEntitlementInfo.productIdentifier,
      );

  /// Converts a RevenueCat CustomerInfo to a backend CustomerInfo model.
  static CustomerInfo convertCustomerInfo(rc.CustomerInfo rcCustomerInfo) {
    final Map<String, EntitlementInfo> entitlements = <String, EntitlementInfo>{};
    for (final MapEntry<String, rc.EntitlementInfo> entry in rcCustomerInfo.entitlements.active.entries) {
      entitlements[entry.key] = convertEntitlementInfo(entry.value);
    }

    return CustomerInfo(
      entitlements: entitlements,
      activeSubscriptions: rcCustomerInfo.activeSubscriptions.toList(),
      allPurchasedProductIdentifiers: rcCustomerInfo.allPurchasedProductIdentifiers.toList(),
      firstSeen: DateTime.parse(rcCustomerInfo.firstSeen),
      requestDate: DateTime.parse(rcCustomerInfo.requestDate),
      originalAppUserId: rcCustomerInfo.originalAppUserId,
      managementURL: rcCustomerInfo.managementURL,
    );
  }
}
