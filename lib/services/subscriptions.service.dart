import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/exceptions/exceptions.export.dart';
import 'package:trainer_backend/mappers/revenuecat.mapper.dart';
import 'package:trainer_backend/models/subscriptions/customer_info.dart';
import 'package:trainer_backend/models/subscriptions/offerings.dart';
import 'package:trainer_backend/models/subscriptions/package.dart';
import 'package:trainer_backend/models/subscriptions/subscription_limits_with_usage.dart';
import 'package:trainer_backend/models/subscriptions/subscription_summary.dart';
import 'package:trainer_backend/utils/revenuecat.guard.dart';
import 'package:trainer_backend/utils/revenuecat.utils.dart';
import 'package:trainer_backend/utils/rpc.guard.dart';
import 'package:trainer_backend/utils/subscription_summary.utils.dart';

/// A service class for managing user subscriptions.
///
/// This class provides static methods to retrieve subscription information,
/// check feature access, interact with subscription-related data, and manage
/// purchases through RevenueCat SDK. All database operations are performed
/// via RPC calls to Supabase using [RpcGuard], while purchase operations use
/// the RevenueCat SDK directly.
///
/// RPC failures are surfaced as [TrainerBackendRpcException],
/// [TrainerBackendNetworkException], or [TrainerBackendUnknownException].
/// RevenueCat failures are surfaced as [TrainerBackendPurchaseException].
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
  /// Throws a [TrainerBackendPurchaseException] if the SDK configuration fails,
  /// the API key is invalid, or the [userId] is empty.
  static Future<void> configureRevenueCat({required String apiKey, required String userId}) async {
    await RevenueCatGuard.run<void>(
      operation: 'configureRevenueCat',
      body: () async {
        if (userId.isEmpty) {
          throw const TrainerBackendPurchaseException.notInitialized(
            operation: 'configureRevenueCat',
            message: 'User ID cannot be empty.',
          );
        }

        final rc.PurchasesConfiguration configuration = rc.PurchasesConfiguration(apiKey)..appUserID = userId;

        await rc.Purchases.configure(configuration);
        _isRevenueCatInitialized = true;
      },
    );
  }

  /// Retrieves the active subscription summary for the current user.
  ///
  /// This method returns the user's active subscription along with
  /// entitlement and limits information. If no active subscription exists,
  /// it automatically falls back to the Free entitlement with default limits.
  ///
  /// Returns a [Future] with a [SubscriptionSummary] containing subscription
  /// details, entitlement information, product information, and limits.
  /// Never returns null — always returns at least the Free entitlement.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<SubscriptionSummary> getUserSubscriptionSummary() => RpcGuard.run(
    operation: 'getUserSubscriptionSummary',
    body: () async {
      final dynamic response = await _client.rpc(
        'get_user_subscription_summary',
        params: <String, dynamic>{'p_user_id': null},
      );
      return SubscriptionSummary.fromJson(response as Map<String, dynamic>);
    },
  );

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
  /// Throws a [TrainerBackendPurchaseException] with code
  /// [TrainerBackendPurchaseErrorCode.notInitialized] if the SDK is not ready.
  /// Throws a [TrainerBackendPurchaseException] for any RevenueCat error.
  static Future<Offerings?> getOfferings() async {
    _ensureRevenueCatInitialized('getOfferings');
    return RevenueCatGuard.run(
      operation: 'getOfferings',
      body: () async {
        final rc.Offerings rcOfferings = await rc.Purchases.getOfferings();
        return RevenueCatMapper.convertOfferings(rcOfferings);
      },
    );
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
  /// Returns a [Future] with a [SubscriptionSummary] containing subscription
  /// status and dates, entitlement information, product information, and
  /// subscription limits.
  ///
  /// Note: The `id` and `entitlement.id` fields will be empty strings as they
  /// are generated by Supabase when the webhook creates the subscription record.
  ///
  /// Throws a [TrainerBackendPurchaseException] with code
  /// [TrainerBackendPurchaseErrorCode.notInitialized] if the SDK is not ready.
  /// Throws a [TrainerBackendPurchaseException] with code
  /// [TrainerBackendPurchaseErrorCode.packageNotFound] if the product is not
  /// found in the current offerings.
  /// Throws a [TrainerBackendPurchaseException] for any RevenueCat error.
  /// Throws a [TrainerBackendRpcException] if the limits RPC call fails.
  static Future<SubscriptionSummary> purchasePackage({required Package package}) async {
    _ensureRevenueCatInitialized('purchasePackage');

    final String? entitlementKey = package.entitlementIdentifier;
    if (entitlementKey == null || entitlementKey.isEmpty) {
      throw TrainerBackendPurchaseException.packageNotFound(
        operation: 'purchasePackage',
        message:
            'Package has no entitlement identifier. '
            'Product: ${package.storeProduct.identifier}',
      );
    }

    try {
      final CustomerInfo customerInfo = await RevenueCatGuard.run(
        operation: 'purchasePackage',
        body: () async {
          final rc.Offerings rcOfferings = await rc.Purchases.getOfferings();

          final rc.Package? rcPackage = RevenueCatUtils.findPackageByProductId(
            rcOfferings,
            package.storeProduct.identifier,
          );

          if (rcPackage == null) {
            throw TrainerBackendPurchaseException.packageNotFound(
              operation: 'purchasePackage',
              message:
                  'Package not found in offerings for product: '
                  '${package.storeProduct.identifier}',
            );
          }

          return _purchasePackageWithRevenueCatPackage(rcPackage);
        },
      );

      final SubscriptionSummaryLimits limits = await RpcGuard.run(
        operation: 'purchasePackage',
        body: () => SubscriptionSummaryUtils.getEntitlementLimits(entitlementKey),
      );

      return SubscriptionSummaryUtils.buildFromCustomerInfo(
        customerInfo: customerInfo,
        limits: limits,
        package: package,
        entitlementKey: entitlementKey,
      );
    } catch (error) {
      if (error is TrainerBackendException) rethrow;
      throw TrainerBackendUnknownException(
        operation: 'purchasePackage',
        message: 'An unexpected error occurred during purchasePackage.',
        cause: error,
      );
    }
  }

  /// Internal method to purchase a package using the RevenueCat Package directly.
  ///
  /// This method performs the actual purchase operation without needing to
  /// look up the package in offerings.
  static Future<CustomerInfo> _purchasePackageWithRevenueCatPackage(rc.Package rcPackage) async {
    final rc.PurchaseParams purchaseParams = rc.PurchaseParams.package(rcPackage);
    final rc.PurchaseResult purchaseResult = await rc.Purchases.purchase(purchaseParams);
    return RevenueCatMapper.convertCustomerInfo(purchaseResult.customerInfo);
  }

  /// Restores previous purchases associated with the current user ID.
  ///
  /// This method restores all previous purchases for the user and triggers
  /// RevenueCat webhooks for each restored subscription, which will update
  /// the Supabase database accordingly.
  ///
  /// Returns a [Future] with a [CustomerInfo] (backend model) object containing
  /// all restored entitlements and subscriptions.
  ///
  /// Throws a [TrainerBackendPurchaseException] with code
  /// [TrainerBackendPurchaseErrorCode.notInitialized] if the SDK is not ready.
  /// Throws a [TrainerBackendPurchaseException] for any RevenueCat error.
  static Future<CustomerInfo> restorePurchases() async {
    _ensureRevenueCatInitialized('restorePurchases');
    return RevenueCatGuard.run(
      operation: 'restorePurchases',
      body: () async {
        final rc.CustomerInfo rcCustomerInfo = await rc.Purchases.restorePurchases();
        return RevenueCatMapper.convertCustomerInfo(rcCustomerInfo);
      },
    );
  }

  /// Retrieves the current customer information from RevenueCat.
  ///
  /// This method returns the current [CustomerInfo] (backend model) without
  /// performing any purchase action. It allows checking active entitlements and
  /// subscriptions without initiating a purchase flow.
  ///
  /// The information is retrieved from cache or via a network request if needed.
  ///
  /// Throws a [TrainerBackendPurchaseException] with code
  /// [TrainerBackendPurchaseErrorCode.notInitialized] if the SDK is not ready.
  /// Throws a [TrainerBackendPurchaseException] for any RevenueCat error.
  static Future<CustomerInfo> getCustomerInfo() async {
    _ensureRevenueCatInitialized('getCustomerInfo');
    return RevenueCatGuard.run(
      operation: 'getCustomerInfo',
      body: () async {
        final rc.CustomerInfo rcCustomerInfo = await rc.Purchases.getCustomerInfo();
        return RevenueCatMapper.convertCustomerInfo(rcCustomerInfo);
      },
    );
  }

  /// Gets the URL to the platform's subscription management page.
  ///
  /// This URL can be used to redirect users to their App Store or Play Store
  /// subscription management page. The URL is retrieved from the current
  /// customer info.
  ///
  /// Returns the management URL as a [String], or null if not available.
  ///
  /// Throws a [TrainerBackendPurchaseException] with code
  /// [TrainerBackendPurchaseErrorCode.notInitialized] if the SDK is not ready.
  /// Throws a [TrainerBackendPurchaseException] for any RevenueCat error.
  static Future<String?> getManagementURL() async {
    _ensureRevenueCatInitialized('getManagementURL');
    return RevenueCatGuard.run(
      operation: 'getManagementURL',
      body: () async {
        final rc.CustomerInfo rcCustomerInfo = await rc.Purchases.getCustomerInfo();
        return rcCustomerInfo.managementURL;
      },
    );
  }

  /// Retrieves subscription limits with current usage counts for the current user.
  ///
  /// This method returns subscription summary information plus current usage
  /// statistics including the number of programs, exercises, and sessions per
  /// program. If no active subscription exists, it automatically falls back to
  /// the Free entitlement.
  ///
  /// Returns a [Future] with a [SubscriptionLimitsWithUsage] containing
  /// subscription summary and current usage counts.
  /// Never returns null — always returns at least the Free entitlement with
  /// usage data.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<SubscriptionLimitsWithUsage> getUserLimitsWithUsage() => RpcGuard.run(
    operation: 'getUserLimitsWithUsage',
    body: () async {
      final dynamic response = await _client.rpc(
        'get_user_limits_with_usage',
        params: <String, dynamic>{'p_user_id': null},
      );
      return SubscriptionLimitsWithUsage.fromJson(response as Map<String, dynamic>);
    },
  );

  /// Throws [TrainerBackendPurchaseException.notInitialized] if the RevenueCat
  /// SDK has not been configured yet.
  static void _ensureRevenueCatInitialized(String operation) {
    if (!_isRevenueCatInitialized) {
      throw TrainerBackendPurchaseException.notInitialized(
        operation: operation,
        message: 'RevenueCat SDK not initialized. Call configureRevenueCat() first.',
      );
    }
  }
}
