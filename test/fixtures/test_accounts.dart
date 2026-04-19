import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Test account fixtures for integration tests.
///
/// Credentials are loaded from environment variables (unit-test.env file).
/// These accounts must be created manually in Supabase before running tests.
/// See test/README.md for setup instructions.
///
/// IMPORTANT: TestSetup.initializeSupabase() must be called before accessing
/// these accounts to ensure unit-test.env is loaded into dotenv.
class TestAccounts {
  TestAccounts._();

  static String _env(String key) {
    // Reads from dotenv.env which is populated from unit-test.env
    // via TestSetup.initializeSupabase()
    final String value = dotenv.env[key] ?? Platform.environment[key] ?? '';
    if (value.isEmpty) {
      throw Exception(
        'Missing $key. Ensure TestSetup.initializeSupabase() was called to load unit-test.env. '
        'If the file is missing, create unit-test.env at the project root. See test/README.md.',
      );
    }
    return value;
  }

  /// User account with Free subscription (limits: 1 program, 2 sessions, 6 exercises).
  static TestAccount get freeUser => TestAccount(
    email: _env('TEST_FREE_EMAIL'),
    password: _env('TEST_FREE_PASSWORD'),
    userId: '',
    plan: 'Free',
  );

  /// User account with Basic subscription (limits: 5 programs, 10 sessions, 15 exercises).
  static TestAccount get basicUser => TestAccount(
    email: _env('TEST_BASIC_EMAIL'),
    password: _env('TEST_BASIC_PASSWORD'),
    userId: '',
    plan: 'Basic',
  );

  /// User account with Premium subscription (limits: unlimited programs, 30 sessions, 20 exercises).
  static TestAccount get premiumUser => TestAccount(
    email: _env('TEST_PREMIUM_EMAIL'),
    password: _env('TEST_PREMIUM_PASSWORD'),
    userId: '',
    plan: 'Premium',
  );
}

/// Represents a test account with its credentials and metadata.
class TestAccount {
  const TestAccount({
    required this.email,
    required this.password,
    required this.userId,
    required this.plan,
  });

  /// Email address of the test account.
  final String email;

  /// Password of the test account.
  final String password;

  /// User UUID (filled after sign-in).
  final String userId;

  /// Expected subscription plan (null = no subscription).
  final String? plan;

  /// Returns a copy with updated userId.
  TestAccount copyWith({String? userId}) => TestAccount(
    email: email,
    password: password,
    userId: userId ?? this.userId,
    plan: plan,
  );
}
