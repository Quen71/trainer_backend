import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/mappers/revenuecat.mapper.dart';
import 'package:trainer_backend/models/subscriptions/customer_info.dart';
import 'package:trainer_backend/models/subscriptions/offerings.dart';
import 'package:trainer_backend/models/subscriptions/package.dart';
import 'package:trainer_backend/models/subscriptions/subscription_limits_with_usage.dart';
import 'package:trainer_backend/models/subscriptions/subscription_summary.dart';
import 'package:trainer_backend/utils/revenuecat.utils.dart';
import 'package:trainer_backend/utils/subscription_summary.utils.dart';

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

    final rc.PurchasesConfiguration configuration = rc.PurchasesConfiguration(
      apiKey,
    )..appUserID = userId;

    await rc.Purchases.configure(configuration);

    _isRevenueCatInitialized = true;
  }

  /// Retrieves the active subscription summary for the current user.
  ///
  /// This method returns the user's active subscription along with
  /// entitlement and limits information. If no active subscription exists,
  /// it automatically falls back to the Free entitlement with default limits.
  ///
  /// Returns a [Future] with a [SubscriptionSummary] containing subscription details,
  /// entitlement information, product information, and limits.
  /// Never returns null - always returns at least the Free entitlement.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<SubscriptionSummary> getUserSubscriptionSummary() async {
    final dynamic response = await _client.rpc(
      'get_user_subscription_summary',
      params: <String, dynamic>{'p_user_id': null},
    );

    return SubscriptionSummary.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves the available offerings (subscription packages) from RevenueCat.
  ///
  /// Returns a [Future] with an [Offerings] object containing all available
  /// offerings and their packages. Returns `null` if no offerings are available.
  ///
  /// The structure is: `Offerings` → `all` (`Map<String, Offering>`) →
  /// `Offering` → `availablePackages` (`List<Package>`).
  ///
  /// **Entitlement Information**: This method enriches packages with entitlement
  /// information using local configuration mapping. Each package will have its
  /// `entitlementIdentifier` field populated based on the product identifier.
  ///
  /// Throws a [rc.PurchasesError] if the RevenueCat SDK is not initialized or
  /// if a network error occurs.
  static Future<Offerings?> getOfferings() async {
    _checkRevenueCatInitialized();

    try {
      final rc.Offerings rcOfferings = await rc.Purchases.getOfferings();
      return RevenueCatMapper.convertOfferings(rcOfferings);
    } on rc.PurchasesError catch (e) {
      throw Exception('Failed to get offerings: ${e.message}');
    }
  }

  /// Purchases a package from an offering.
  ///
  /// This method initiates the purchase flow for the specified package and
  /// returns a complete [SubscriptionSummary] for immediate UI updates.
  ///
  /// **Note**: This method fetches entitlement limits from Supabase directly
  /// (via RPC) without waiting for the RevenueCat webhook. This allows for
  /// immediate feedback after a successful purchase.
  ///
  /// - [package]: The [Package] (backend model) to purchase from an offering.
  ///
  /// Returns a [Future] with a [SubscriptionSummary] containing:
  /// - Subscription status and dates from RevenueCat
  /// - Entitlement information
  /// - Product information
  /// - Subscription limits from Supabase
  ///
  /// Note: The `id` and `entitlement.id` fields will be empty strings as they
  /// are generated by Supabase when the webhook creates the subscription record.
  ///
  /// Throws an [Exception] with specific error messages:
  /// - `PURCHASE_CANCELLED`: User cancelled the purchase
  /// - `PURCHASE_NOT_ALLOWED`: Purchase is not allowed
  /// - `PRODUCT_NOT_AVAILABLE_FOR_PURCHASE`: Product is not available
  /// - Other network/StoreKit errors
  static Future<SubscriptionSummary> purchasePackage({
    required Package package,
  }) async {
    _checkRevenueCatInitialized();

    // Validate entitlement identifier
    final String? entitlementKey = package.entitlementIdentifier;
    if (entitlementKey == null || entitlementKey.isEmpty) {
      throw Exception(
        'Package has no entitlement identifier. '
        'Product: ${package.storeProduct.identifier}',
      );
    }

    // We must fetch offerings from RevenueCat to get the original rc.Package object.
    // We cannot convert a backend Package to rc.Package because rc.Package contains
    // internal references and complex objects that are only available from RevenueCat.
    final rc.Offerings rcOfferings = await rc.Purchases.getOfferings();

    // Use storeProduct.identifier (the unique product ID) instead of package.identifier
    // because package.identifier (e.g., "$rc_monthly") is shared across offerings,
    // while storeProduct.identifier (e.g., "basic_monthly_subscription") is unique.
    final rc.Package? rcPackage = RevenueCatUtils.findPackageByProductId(
      rcOfferings,
      package.storeProduct.identifier,
    );

    if (rcPackage == null) {
      throw Exception(
        'Package not found in offerings for product: ${package.storeProduct.identifier}',
      );
    }

    // 1. Purchase via RevenueCat
    final CustomerInfo customerInfo =
        await _purchasePackageWithRevenueCatPackage(rcPackage);

    // 2. Fetch limits from Supabase (independent of webhook)
    final SubscriptionSummaryLimits limits =
        await SubscriptionSummaryUtils.getEntitlementLimits(entitlementKey);

    // 3. Build and return SubscriptionSummary
    return SubscriptionSummaryUtils.buildFromCustomerInfo(
      customerInfo: customerInfo,
      limits: limits,
      package: package,
      entitlementKey: entitlementKey,
    );
  }

  /// Internal method to purchase a package using the RevenueCat Package directly.
  ///
  /// This method performs the actual purchase operation without needing to
  /// look up the package in offerings.
  static Future<CustomerInfo> _purchasePackageWithRevenueCatPackage(
    rc.Package rcPackage,
  ) async {
    try {
      final rc.PurchaseParams purchaseParams = rc.PurchaseParams.package(
        rcPackage,
      );
      final rc.PurchaseResult purchaseResult = await rc.Purchases.purchase(
        purchaseParams,
      );
      return RevenueCatMapper.convertCustomerInfo(purchaseResult.customerInfo);
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
      final rc.CustomerInfo rcCustomerInfo =
          await rc.Purchases.restorePurchases();
      return RevenueCatMapper.convertCustomerInfo(rcCustomerInfo);
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
      final rc.CustomerInfo rcCustomerInfo =
          await rc.Purchases.getCustomerInfo();
      return RevenueCatMapper.convertCustomerInfo(rcCustomerInfo);
    } on rc.PurchasesError catch (e) {
      throw Exception('Failed to get customer info: ${e.message}');
    }
  }

  /// Gets the URL to the platform's subscription management page.
  ///
  /// This URL can be used to redirect users to their App Store or Play Store
  /// subscription management page. The URL is retrieved from the current
  /// customer info.
  ///
  /// Returns the management URL as a [String], or null if not available.
  /// Throws an [Exception] if the RevenueCat SDK is not initialized.
  static Future<String?> getManagementURL() async {
    _checkRevenueCatInitialized();

    try {
      final rc.CustomerInfo rcCustomerInfo =
          await rc.Purchases.getCustomerInfo();
      return rcCustomerInfo.managementURL;
    } on rc.PurchasesError catch (e) {
      throw Exception('Failed to get management URL: ${e.message}');
    }
  }

  /// Retrieves subscription limits with current usage counts for the current user.
  ///
  /// This method returns subscription summary information plus current usage statistics
  /// including the number of programs, exercises, and sessions per program.
  /// If no active subscription exists, it automatically falls back to the Free entitlement.
  ///
  /// Returns a [Future] with a [SubscriptionLimitsWithUsage] containing:
  /// - Subscription summary (status, entitlement, limits)
  /// - Current usage counts (programs, exercises, sessions per program)
  ///
  /// Never returns null - always returns at least the Free entitlement with usage data.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<SubscriptionLimitsWithUsage> getUserLimitsWithUsage() async {
    final dynamic response = await _client.rpc(
      'get_user_limits_with_usage',
      params: <String, dynamic>{'p_user_id': null},
    );

    return SubscriptionLimitsWithUsage.fromJson(
      response as Map<String, dynamic>,
    );
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
