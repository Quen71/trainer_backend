import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/models/subscriptions/customer_info.dart';
import 'package:trainer_backend/models/subscriptions/entitlement_info.dart';
import 'package:trainer_backend/models/subscriptions/feature_access.dart';
import 'package:trainer_backend/models/subscriptions/offering.dart';
import 'package:trainer_backend/models/subscriptions/offerings.dart';
import 'package:trainer_backend/models/subscriptions/package.dart';
import 'package:trainer_backend/models/subscriptions/store_product.dart';
import 'package:trainer_backend/models/subscriptions/subscription_summary.dart';

/// A service class for managing user subscriptions.
///
/// This class provides static methods to retrieve subscription information,
/// check feature access, interact with subscription-related data, and manage
/// purchases through RevenueCat SDK. All database operations are performed
/// via RPC calls to Supabase, while purchase operations use RevenueCat SDK.
class SubscriptionsService {
  /// The constructor is private to prevent instantiation of the class.
  const SubscriptionsService._();

  /// A private getter for the Supabase client instance.
  static SupabaseClient get _client => TrainerAPI.client;

  /// Flag to track if RevenueCat SDK has been initialized.
  static bool _isRevenueCatInitialized = false;

  /// Configures the RevenueCat SDK with the provided API key and user ID.
  ///
  /// This method initializes the RevenueCat SDK and sets the app user ID
  /// to match the Supabase user UUID. It must be called once after user
  /// authentication and before any other RevenueCat operations.
  ///
  /// - [apiKey]: The RevenueCat API key (e.g., `test_...` for Test Store,
  ///   `appl_...` for iOS production, `goog_...` for Android production).
  /// - [userId]: The UUID of the Supabase user (`auth.uid()`).
  ///
  /// Throws a [PurchasesError] if the SDK configuration fails or if the
  /// API key is invalid. Throws an [Exception] if the userId is empty.
  static Future<void> configureRevenueCat({
    required String apiKey,
    required String userId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    final rc.PurchasesConfiguration configuration = rc.PurchasesConfiguration(apiKey)..appUserID = userId;

    await rc.Purchases.configure(configuration);

    _isRevenueCatInitialized = true;
  }

  /// Retrieves the active subscription summary for the current user.
  ///
  /// This method returns the user's active subscription along with
  /// entitlement and limits information. Only active, trialing, or
  /// in-grace subscriptions are returned.
  ///
  /// Returns a [Future] with a [SubscriptionSummary] containing subscription details,
  /// entitlement information, product information, and limits.
  /// Returns `null` if no active subscription is found.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<SubscriptionSummary?> getUserSubscriptionSummary() async {
    final dynamic response = await _client.rpc(
      'get_user_subscription_summary',
      params: <String, dynamic>{'p_user_id': null},
    );

    if (response == null) {
      return null;
    }

    return SubscriptionSummary.fromJson(response as Map<String, dynamic>);
  }

  /// Checks if the current user has access to a specific feature.
  ///
  /// - [featureKey]: The key identifying the feature to check access for.
  ///   This should match an entitlement key or feature identifier.
  ///
  /// Returns a [Future] with a [FeatureAccess] containing:
  /// - `hasAccess`: A boolean indicating if the user has access
  /// - `featureKey`: The feature key that was checked
  /// - `limits`: Subscription limits if access is granted
  ///
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<FeatureAccess> checkFeatureAccess({
    required String featureKey,
  }) async {
    final dynamic response = await _client.rpc(
      'check_feature_access',
      params: <String, dynamic>{
        'p_user_id': null,
        'p_feature_key': featureKey,
      },
    );

    if (response == null) {
      return FeatureAccess(
        hasAccess: false,
        featureKey: featureKey,
      );
    }

    return FeatureAccess.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves the available offerings (subscription packages) from RevenueCat.
  ///
  /// Returns a [Future] with an [Offerings] object containing all available
  /// offerings and their packages. Returns `null` if no offerings are available.
  ///
  /// The structure is: `Offerings` → `all` (`Map<String, Offering>`) →
  /// `Offering` → `availablePackages` (`List<Package>`).
  ///
  /// Throws a [rc.PurchasesError] if the RevenueCat SDK is not initialized or
  /// if a network error occurs.
  static Future<Offerings?> getOfferings() async {
    _checkRevenueCatInitialized();

    try {
      final rc.Offerings rcOfferings = await rc.Purchases.getOfferings();
      return _convertOfferings(rcOfferings);
    } on rc.PurchasesError catch (e) {
      throw Exception('Failed to get offerings: ${e.message}');
    }
  }

  /// Purchases a package from an offering.
  ///
  /// This method initiates the purchase flow for the specified package.
  /// After a successful purchase, RevenueCat will automatically send a webhook
  /// to Supabase to create/update the subscription in the database.
  ///
  /// **Note**: This method must fetch offerings from RevenueCat to find the
  /// original `rc.Package` object, as RevenueCat requires the original Package
  /// instance (not just the identifier) to perform purchases. The backend `Package`
  /// model cannot be converted back to a `rc.Package` because `rc.Package` contains
  /// internal references and complex objects that are only available from RevenueCat.
  ///
  /// - [package]: The [Package] (backend model) to purchase from an offering.
  ///
  /// Returns a [Future] with a [CustomerInfo] (backend model) object containing:
  /// - `entitlements`: Map of active entitlements (key = entitlement identifier,
  ///   value = `EntitlementInfo`)
  /// - `activeSubscriptions`: List of active subscription identifiers
  /// - `allPurchasedProductIdentifiers`: List of all purchased product IDs
  /// - `firstSeen`: Date when the customer was first seen
  /// - `requestDate`: Date of the request
  ///
  /// Throws a [rc.PurchasesError] with specific error codes:
  /// - `PURCHASE_CANCELLED`: User cancelled the purchase
  /// - `PURCHASE_NOT_ALLOWED`: Purchase is not allowed
  /// - `PRODUCT_NOT_AVAILABLE_FOR_PURCHASE`: Product is not available
  /// - Other network/StoreKit errors
  static Future<CustomerInfo> purchasePackage({
    required Package package,
  }) async {
    _checkRevenueCatInitialized();

    // We must fetch offerings from RevenueCat to get the original rc.Package object.
    // We cannot convert a backend Package to rc.Package because rc.Package contains
    // internal references and complex objects that are only available from RevenueCat.
    final rc.Offerings rcOfferings = await rc.Purchases.getOfferings();
    final rc.Package? rcPackage = _findRevenueCatPackage(rcOfferings, package.identifier);

    if (rcPackage == null) {
      throw Exception('Package not found in offerings: ${package.identifier}');
    }

    return _purchasePackageWithRevenueCatPackage(rcPackage);
  }

  /// Internal method to purchase a package using the RevenueCat Package directly.
  ///
  /// This method performs the actual purchase operation without needing to
  /// look up the package in offerings.
  static Future<CustomerInfo> _purchasePackageWithRevenueCatPackage(rc.Package rcPackage) async {
    try {
      final rc.PurchaseParams purchaseParams = rc.PurchaseParams.package(rcPackage);
      final rc.PurchaseResult purchaseResult = await rc.Purchases.purchase(purchaseParams);
      return _convertCustomerInfo(purchaseResult.customerInfo);
    } on rc.PurchasesError catch (e) {
      throw Exception('Purchase failed: ${e.message} (code: ${e.code})');
    }
  }

  /// Restores previous purchases associated with the current user ID.
  ///
  /// This method restores all previous purchases for the user and triggers
  /// RevenueCat webhooks for each restored subscription, which will update
  /// the Supabase database accordingly.
  ///
  /// Returns a [Future] with a [CustomerInfo] (backend model) object (same structure as
  /// [purchasePackage]) containing all restored entitlements and subscriptions.
  ///
  /// Throws a [rc.PurchasesError] if a network error occurs or if the RevenueCat
  /// SDK is not initialized.
  static Future<CustomerInfo> restorePurchases() async {
    _checkRevenueCatInitialized();

    try {
      final rc.CustomerInfo rcCustomerInfo = await rc.Purchases.restorePurchases();
      return _convertCustomerInfo(rcCustomerInfo);
    } on rc.PurchasesError catch (e) {
      throw Exception('Failed to restore purchases: ${e.message}');
    }
  }

  /// Retrieves the current customer information from RevenueCat.
  ///
  /// This method returns the current [CustomerInfo] (backend model) without performing any
  /// purchase action. It allows checking active entitlements and subscriptions
  /// without initiating a purchase flow.
  ///
  /// Returns a [Future] with a [CustomerInfo] (backend model) object (same structure as
  /// [purchasePackage] and [restorePurchases]) containing:
  /// - Active entitlements
  /// - Active subscriptions
  /// - All purchased product identifiers
  /// - Customer metadata
  ///
  /// The information is retrieved from cache or via a network request if needed.
  ///
  /// Throws a [rc.PurchasesError] if a network error occurs or if the RevenueCat
  /// SDK is not initialized.
  static Future<CustomerInfo> getCustomerInfo() async {
    _checkRevenueCatInitialized();

    try {
      final rc.CustomerInfo rcCustomerInfo = await rc.Purchases.getCustomerInfo();
      return _convertCustomerInfo(rcCustomerInfo);
    } on rc.PurchasesError catch (e) {
      throw Exception('Failed to get customer info: ${e.message}');
    }
  }

  /// Checks if RevenueCat SDK has been initialized.
  ///
  /// Throws an [Exception] if RevenueCat has not been initialized.
  static void _checkRevenueCatInitialized() {
    if (!_isRevenueCatInitialized) {
      throw Exception(
        'RevenueCat SDK not initialized. Call configureRevenueCat() first.',
      );
    }
  }

  /// Converts a RevenueCat StoreProduct to a backend StoreProduct model.
  static StoreProduct _convertStoreProduct(rc.StoreProduct rcStoreProduct) => StoreProduct(
        identifier: rcStoreProduct.identifier,
        title: rcStoreProduct.title,
        description: rcStoreProduct.description,
        price: rcStoreProduct.price,
        priceString: rcStoreProduct.priceString,
        currencyCode: rcStoreProduct.currencyCode,
      );

  /// Converts a RevenueCat Package to a backend Package model.
  static Package _convertPackage(rc.Package rcPackage) => Package(
        identifier: rcPackage.identifier,
        packageType: rcPackage.packageType.toString(),
        storeProduct: _convertStoreProduct(rcPackage.storeProduct),
      );

  /// Converts a RevenueCat Offering to a backend Offering model.
  static Offering _convertOffering(rc.Offering rcOffering) => Offering(
        identifier: rcOffering.identifier,
        serverDescription: rcOffering.serverDescription,
        availablePackages: rcOffering.availablePackages.map(_convertPackage).toList(),
      );

  /// Converts a RevenueCat Offerings to a backend Offerings model.
  static Offerings _convertOfferings(rc.Offerings rcOfferings) {
    final Map<String, Offering> allOfferings = <String, Offering>{};
    for (final MapEntry<String, rc.Offering> entry in rcOfferings.all.entries) {
      allOfferings[entry.key] = _convertOffering(entry.value);
    }

    return Offerings(
      all: allOfferings,
      current: rcOfferings.current != null ? _convertOffering(rcOfferings.current!) : null,
    );
  }

  /// Finds a RevenueCat Package by identifier in the offerings.
  static rc.Package? _findRevenueCatPackage(rc.Offerings rcOfferings, String identifier) {
    for (final rc.Offering offering in rcOfferings.all.values) {
      for (final rc.Package package in offering.availablePackages) {
        if (package.identifier == identifier) {
          return package;
        }
      }
    }
    return null;
  }

  /// Converts a RevenueCat EntitlementInfo to a backend EntitlementInfo model.
  static EntitlementInfo _convertEntitlementInfo(rc.EntitlementInfo rcEntitlementInfo) => EntitlementInfo(
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
  static CustomerInfo _convertCustomerInfo(rc.CustomerInfo rcCustomerInfo) {
    final Map<String, EntitlementInfo> entitlements = <String, EntitlementInfo>{};
    for (final MapEntry<String, rc.EntitlementInfo> entry in rcCustomerInfo.entitlements.active.entries) {
      entitlements[entry.key] = _convertEntitlementInfo(entry.value);
    }

    return CustomerInfo(
      entitlements: entitlements,
      activeSubscriptions: rcCustomerInfo.activeSubscriptions.toList(),
      allPurchasedProductIdentifiers: rcCustomerInfo.allPurchasedProductIdentifiers.toList(),
      firstSeen: DateTime.parse(rcCustomerInfo.firstSeen),
      requestDate: DateTime.parse(rcCustomerInfo.requestDate),
      originalAppUserId: rcCustomerInfo.originalAppUserId,
    );
  }
}
