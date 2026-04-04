import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:trainer_backend/trainer_backend.dart';

/// Test screen for demonstrating subscription-related features.
///
/// This screen allows testing of subscription service methods including
/// retrieving subscription summaries and checking feature access.
class SubscriptionsTestScreen extends StatefulWidget {
  const SubscriptionsTestScreen({super.key});

  @override
  State<SubscriptionsTestScreen> createState() => _SubscriptionsTestScreenState();
}

class _SubscriptionsTestScreenState extends State<SubscriptionsTestScreen> {
  SubscriptionSummary? _subscriptionSummary;
  SubscriptionLimitsWithUsage? _limitsWithUsage;
  Offerings? _offerings;
  CustomerInfo? _customerInfo;
  bool _isLoadingSummary = false;
  bool _isLoadingLimitsWithUsage = false;
  bool _isLoadingOfferings = false;
  bool _isLoadingPurchase = false;
  bool _isLoadingRestore = false;
  bool _isLoadingCustomerInfo = false;
  String? _errorMessage;

  Future<void> _testGetSubscriptionSummary() async {
    setState(() {
      _isLoadingSummary = true;
      _errorMessage = null;
      _subscriptionSummary = null;
    });

    try {
      final SubscriptionSummary summary = await SubscriptionsService.getUserSubscriptionSummary();

      log(
        name: 'Subscriptions',
        'Subscription Summary retrieved (always returns at least Free): ${const JsonEncoder.withIndent('  ').convert(summary.toJson())}',
      );

      setState(() {
        _subscriptionSummary = summary;
        _isLoadingSummary = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingSummary = false;
      });
    }
  }

  Future<void> _testGetLimitsWithUsage() async {
    setState(() {
      _isLoadingLimitsWithUsage = true;
      _errorMessage = null;
      _limitsWithUsage = null;
    });

    try {
      final SubscriptionLimitsWithUsage limitsWithUsage = await SubscriptionsService.getUserLimitsWithUsage();

      log(
        name: 'Subscriptions',
        'Limits with Usage retrieved: ${const JsonEncoder.withIndent('  ').convert(limitsWithUsage.toJson())}',
      );

      setState(() {
        _limitsWithUsage = limitsWithUsage;
        _isLoadingLimitsWithUsage = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingLimitsWithUsage = false;
      });
    }
  }

  Future<void> _testGetOfferings() async {
    setState(() {
      _isLoadingOfferings = true;
      _errorMessage = null;
      _offerings = null;
    });

    try {
      final Offerings? offerings = await SubscriptionsService.getOfferings();

      if (offerings != null) {
        log(
          name: 'RevenueCat',
          'Offerings retrieved: ${offerings.all.length} offerings found',
        );
        for (final Offering offering in offerings.all.values) {
          log(
            name: 'RevenueCat',
            'Offering "${offering.identifier}": ${offering.availablePackages.length} packages',
          );
          for (final Package package in offering.availablePackages) {
            log(
              name: 'RevenueCat',
              'Package "${package.identifier}": ${package.storeProduct.title} - ${package.storeProduct.priceString} (Entitlement: ${package.entitlementIdentifier ?? 'N/A'})',
            );
          }
        }
        log(
          name: 'RevenueCat',
          'Offerings JSON: ${const JsonEncoder.withIndent('  ').convert(_offeringsToJson(offerings))}',
        );
      } else {
        log(name: 'RevenueCat', 'No offerings available');
      }

      setState(() {
        _offerings = offerings;
        _isLoadingOfferings = false;
      });
    } catch (e) {
      log(name: 'RevenueCat', 'Error getting offerings: $e', error: e);
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingOfferings = false;
      });
    }
  }

  Future<void> _testPurchasePackage(Package package) async {
    setState(() {
      _isLoadingPurchase = true;
      _errorMessage = null;
      _subscriptionSummary = null;
    });

    try {
      log(
        name: 'RevenueCat',
        'Attempting to purchase package: ${package.identifier} - ${package.storeProduct.title}',
      );

      final SubscriptionSummary subscriptionSummary = await SubscriptionsService.purchasePackage(
        package: package,
      );

      log(
        name: 'RevenueCat',
        'Purchase successful for package: ${package.identifier}',
      );
      log(
        name: 'RevenueCat',
        'Subscription Summary after purchase: ${const JsonEncoder.withIndent('  ').convert(subscriptionSummary.toJson())}',
      );

      setState(() {
        _subscriptionSummary = subscriptionSummary;
        _isLoadingPurchase = false;
      });
    } catch (e) {
      log(name: 'RevenueCat', 'Purchase failed: $e', error: e);
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingPurchase = false;
      });
    }
  }

  Future<void> _testRestorePurchases() async {
    setState(() {
      _isLoadingRestore = true;
      _errorMessage = null;
      _customerInfo = null;
    });

    try {
      log(name: 'RevenueCat', 'Restoring purchases...');

      final CustomerInfo customerInfo = await SubscriptionsService.restorePurchases();

      log(
        name: 'RevenueCat',
        'Purchases restored successfully',
      );
      log(
        name: 'RevenueCat',
        'Customer Info after restore: ${const JsonEncoder.withIndent('  ').convert(_customerInfoToJson(customerInfo))}',
      );

      setState(() {
        _customerInfo = customerInfo;
        _isLoadingRestore = false;
      });
    } catch (e) {
      log(name: 'RevenueCat', 'Restore purchases failed: $e', error: e);
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingRestore = false;
      });
    }
  }

  Future<void> _testGetCustomerInfo() async {
    setState(() {
      _isLoadingCustomerInfo = true;
      _errorMessage = null;
      _customerInfo = null;
    });

    try {
      log(name: 'RevenueCat', 'Fetching customer info...');

      final CustomerInfo customerInfo = await SubscriptionsService.getCustomerInfo();

      log(
        name: 'RevenueCat',
        'Customer Info retrieved: ${const JsonEncoder.withIndent('  ').convert(_customerInfoToJson(customerInfo))}',
      );

      setState(() {
        _customerInfo = customerInfo;
        _isLoadingCustomerInfo = false;
      });
    } catch (e) {
      log(name: 'RevenueCat', 'Get customer info failed: $e', error: e);
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingCustomerInfo = false;
      });
    }
  }

  Map<String, dynamic> _offeringsToJson(Offerings offerings) => <String, dynamic>{
        'all': offerings.all.map(
          (String key, Offering offering) => MapEntry<String, dynamic>(
            key,
            <String, dynamic>{
              'identifier': offering.identifier,
              'serverDescription': offering.serverDescription,
              'availablePackages': offering.availablePackages
                  .map(
                    (Package package) => <String, dynamic>{
                      'identifier': package.identifier,
                      'packageType': package.packageType,
                      'entitlementIdentifier': package.entitlementIdentifier,
                      'product': <String, dynamic>{
                        'identifier': package.storeProduct.identifier,
                        'title': package.storeProduct.title,
                        'description': package.storeProduct.description,
                        'price': package.storeProduct.price,
                        'priceString': package.storeProduct.priceString,
                        'currencyCode': package.storeProduct.currencyCode,
                      },
                    },
                  )
                  .toList(),
            },
          ),
        ),
        'current': offerings.current?.identifier,
      };

  Map<String, dynamic> _customerInfoToJson(CustomerInfo customerInfo) => <String, dynamic>{
        'entitlements': customerInfo.entitlements.map(
          (String key, EntitlementInfo entitlement) => MapEntry<String, dynamic>(
            key,
            <String, dynamic>{
              'identifier': entitlement.identifier,
              'isActive': entitlement.isActive,
              'willRenew': entitlement.willRenew,
              'periodType': entitlement.periodType,
              'latestPurchaseDate': entitlement.latestPurchaseDate.toIso8601String(),
              'originalPurchaseDate': entitlement.originalPurchaseDate.toIso8601String(),
              'expirationDate': entitlement.expirationDate?.toIso8601String(),
              'store': entitlement.store,
              'productIdentifier': entitlement.productIdentifier,
            },
          ),
        ),
        'activeSubscriptions': customerInfo.activeSubscriptions,
        'allPurchasedProductIdentifiers': customerInfo.allPurchasedProductIdentifiers,
        'firstSeen': customerInfo.firstSeen.toIso8601String(),
        'requestDate': customerInfo.requestDate.toIso8601String(),
        'originalAppUserId': customerInfo.originalAppUserId,
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Subscriptions Test'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Subscription Service Tests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoadingSummary ? null : _testGetSubscriptionSummary,
                child: _isLoadingSummary
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Subscription Summary (with Free fallback)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoadingLimitsWithUsage ? null : _testGetLimitsWithUsage,
                child: _isLoadingLimitsWithUsage
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Limits with Usage'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Test Feature Access:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade100,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
              if (_subscriptionSummary != null) ...<Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Subscription Summary:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Status: ${_subscriptionSummary!.status.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_subscriptionSummary!.status == SubscriptionStatus.free)
                        const Text(
                          'Note: Free plan fallback (no active subscription)',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.blue,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        const JsonEncoder.withIndent('  ').convert(_subscriptionSummary!.toJson()),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              if (_limitsWithUsage != null) ...<Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Limits with Usage:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Programs: ${_limitsWithUsage!.usage.programsCount} / ${_limitsWithUsage!.limits.maxPrograms ?? 'unlimited'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Max Exercises Per Session: ${_limitsWithUsage!.limits.maxExercisesPerSession ?? 'unlimited'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        const JsonEncoder.withIndent('  ').convert(_limitsWithUsage!.toJson()),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'RevenueCat Purchase Tests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoadingOfferings ? null : _testGetOfferings,
                child: _isLoadingOfferings
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Offerings'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoadingCustomerInfo ? null : _testGetCustomerInfo,
                child: _isLoadingCustomerInfo
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Customer Info'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoadingRestore ? null : _testRestorePurchases,
                child: _isLoadingRestore
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Restore Purchases'),
              ),
              if (_offerings != null) ...<Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Available Packages:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._offerings!.all.values.expand(
                  (Offering offering) => offering.availablePackages.map(
                    (Package package) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          title: Text(package.storeProduct.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${package.storeProduct.priceString} - ${package.identifier}'),
                              if (package.entitlementIdentifier != null)
                                Text(
                                  'Entitlement: ${package.entitlementIdentifier}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: _isLoadingPurchase
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : ElevatedButton(
                                  onPressed: () => _testPurchasePackage(package),
                                  child: const Text('Purchase'),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (_customerInfo != null) ...<Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Customer Info:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert(_customerInfoToJson(_customerInfo!)),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
