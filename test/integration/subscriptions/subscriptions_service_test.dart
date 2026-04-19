import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/models/subscriptions/subscription_summary.dart';
import 'package:trainer_backend/services/subscriptions.service.dart';

import '../../fixtures/test_accounts.dart';
import '../test_setup.dart';

/// Integration tests for [SubscriptionsService] (Supabase-only methods).
///
/// Covers:
/// - [SubscriptionsService.getUserSubscriptionSummary]
///
/// RevenueCat methods (getOfferings, purchasePackage, etc.) are excluded
/// as they require a real App Store environment and cannot be automated.
void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    supabase = await TestSetup.initializeSupabase();
  });

  // ---------------------------------------------------------------------------
  // getUserSubscriptionSummary
  // ---------------------------------------------------------------------------

  group('getUserSubscriptionSummary - Free Plan', () {
    setUp(() async {
      await TestSetup.signInAndCleanup(supabase, TestAccounts.freeUser);
    });

    test('should return a non-null summary with valid structure', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert: Core fields are populated
      expect(summary.userId, isNotEmpty);
      expect(summary.entitlement.entitlementKey, isNotEmpty);
      expect(summary.limits, isNotNull);
    });

    test('should return the Free entitlement', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert: Entitlement key matches the Free plan
      expect(
        summary.entitlement.entitlementKey.toLowerCase(),
        equals(TestAccounts.freeUser.plan!.toLowerCase()),
      );
    });

    test('should return non-null limits for Free plan', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert
      expect(summary.limits.maxPrograms, isNotNull);
      expect(summary.limits.maxSessionsPerProgram, isNotNull);
      expect(summary.limits.maxExercisesPerSession, isNotNull);
    });
  });

  group('getUserSubscriptionSummary - Basic Plan', () {
    setUp(() async {
      await TestSetup.signInAndCleanup(supabase, TestAccounts.basicUser);
    });

    test('should return a non-null summary with valid structure', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert
      expect(summary.userId, isNotEmpty);
      expect(summary.entitlement.entitlementKey, isNotEmpty);
      expect(summary.limits, isNotNull);
    });

    test('should return the Basic entitlement', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert
      expect(
        summary.entitlement.entitlementKey.toLowerCase(),
        equals(TestAccounts.basicUser.plan!.toLowerCase()),
      );
    });
  });

  group('getUserSubscriptionSummary - Premium Plan', () {
    setUp(() async {
      await TestSetup.signInAndCleanup(supabase, TestAccounts.premiumUser);
    });

    test('should return a non-null summary with valid structure', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert
      expect(summary.userId, isNotEmpty);
      expect(summary.entitlement.entitlementKey, isNotEmpty);
      expect(summary.limits, isNotNull);
    });

    test('should return the Premium entitlement', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert
      expect(
        summary.entitlement.entitlementKey.toLowerCase(),
        equals(TestAccounts.premiumUser.plan!.toLowerCase()),
      );
    });

    test('should return virtually unlimited limits for Premium plan', () async {
      // Act
      final SubscriptionSummary summary =
          await SubscriptionsService.getUserSubscriptionSummary();

      // Assert: Premium limits are set to 999999
      expect(summary.limits.maxPrograms, equals(999999));
      expect(summary.limits.maxSessionsPerProgram, equals(999999));
      expect(summary.limits.maxExercisesPerSession, equals(999999));
    });
  });
}
