import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';

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

  /// Retrieves the active subscription summary for the current user.
  ///
  /// This method returns the user's active subscription along with
  /// entitlement and limits information. Only active, trialing, or
  /// in-grace subscriptions are returned.
  ///
  /// Returns a [Future] with a [Map] containing subscription details,
  /// entitlement information, product information, and limits.
  /// Returns `null` if no active subscription is found.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<Map<String, dynamic>?> getUserSubscriptionSummary() async {
    final dynamic response = await _client.rpc(
      'get_user_subscription_summary',
      params: <String, dynamic>{'p_user_id': null},
    );

    if (response == null) {
      return null;
    }

    return response as Map<String, dynamic>;
  }

  /// Checks if the current user has access to a specific feature.
  ///
  /// - [featureKey]: The key identifying the feature to check access for.
  ///   This should match an entitlement key or feature identifier.
  ///
  /// Returns a [Future] with a [Map] containing:
  /// - `has_access`: A boolean indicating if the user has access
  /// - `feature_key`: The feature key that was checked
  /// - `limits`: A map containing subscription limits if access is granted
  ///
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<Map<String, dynamic>> checkFeatureAccess({
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
      return <String, dynamic>{
        'has_access': false,
        'feature_key': featureKey,
        'limits': <String, dynamic>{},
      };
    }

    return response as Map<String, dynamic>;
  }

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

    final PurchasesConfiguration configuration = PurchasesConfiguration(apiKey)..appUserID = userId;

    await Purchases.configure(configuration);

    _isRevenueCatInitialized = true;
  }

  /// Retrieves the available offerings (subscription packages) from RevenueCat.
  ///
  /// Returns a [Future] with an [Offerings] object containing all available
  /// offerings and their packages. Returns `null` if no offerings are available.
  ///
  /// The structure is: `Offerings` → `offeringMap` (Map<String, Offering>) →
  /// `Offering` → `availablePackages` (List<Package>).
  ///
  /// Throws a [PurchasesError] if the RevenueCat SDK is not initialized or
  /// if a network error occurs.
  static Future<Offerings?> getOfferings() async {
    _checkRevenueCatInitialized();

    try {
      final Offerings offerings = await Purchases.getOfferings();
      return offerings;
    } on PurchasesError catch (e) {
      throw Exception('Failed to get offerings: ${e.message}');
    }
  }

  /// Purchases a package from an offering.
  ///
  /// This method initiates the purchase flow for the specified package.
  /// After a successful purchase, RevenueCat will automatically send a webhook
  /// to Supabase to create/update the subscription in the database.
  ///
  /// - [package]: The [Package] to purchase from an offering.
  ///
  /// Returns a [Future] with a [CustomerInfo] object containing:
  /// - `entitlements`: Map of active entitlements (key = entitlement identifier,
  ///   value = `EntitlementInfo`)
  /// - `activeSubscriptions`: Set of active subscription identifiers
  /// - `allPurchasedProductIdentifiers`: Set of all purchased product IDs
  /// - `firstSeen`: Date when the customer was first seen
  /// - `requestDate`: Date of the request
  ///
  /// Throws a [PurchasesError] with specific error codes:
  /// - `PURCHASE_CANCELLED`: User cancelled the purchase
  /// - `PURCHASE_NOT_ALLOWED`: Purchase is not allowed
  /// - `PRODUCT_NOT_AVAILABLE_FOR_PURCHASE`: Product is not available
  /// - Other network/StoreKit errors
  static Future<CustomerInfo> purchasePackage({
    required Package package,
  }) async {
    _checkRevenueCatInitialized();

    try {
      final PurchaseParams purchaseParams = PurchaseParams.package(package);
      final PurchaseResult purchaseResult = await Purchases.purchase(purchaseParams);
      return purchaseResult.customerInfo;
    } on PurchasesError catch (e) {
      throw Exception('Purchase failed: ${e.message} (code: ${e.code})');
    }
  }

  /// Restores previous purchases associated with the current user ID.
  ///
  /// This method restores all previous purchases for the user and triggers
  /// RevenueCat webhooks for each restored subscription, which will update
  /// the Supabase database accordingly.
  ///
  /// Returns a [Future] with a [CustomerInfo] object (same structure as
  /// [purchasePackage]) containing all restored entitlements and subscriptions.
  ///
  /// Throws a [PurchasesError] if a network error occurs or if the RevenueCat
  /// SDK is not initialized.
  static Future<CustomerInfo> restorePurchases() async {
    _checkRevenueCatInitialized();

    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } on PurchasesError catch (e) {
      throw Exception('Failed to restore purchases: ${e.message}');
    }
  }

  /// Retrieves the current customer information from RevenueCat.
  ///
  /// This method returns the current [CustomerInfo] without performing any
  /// purchase action. It allows checking active entitlements and subscriptions
  /// without initiating a purchase flow.
  ///
  /// Returns a [Future] with a [CustomerInfo] object (same structure as
  /// [purchasePackage] and [restorePurchases]) containing:
  /// - Active entitlements
  /// - Active subscriptions
  /// - All purchased product identifiers
  /// - Customer metadata
  ///
  /// The information is retrieved from cache or via a network request if needed.
  ///
  /// Throws a [PurchasesError] if a network error occurs or if the RevenueCat
  /// SDK is not initialized.
  static Future<CustomerInfo> getCustomerInfo() async {
    _checkRevenueCatInitialized();

    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } on PurchasesError catch (e) {
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
}
