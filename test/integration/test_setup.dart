import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/clients/trainer.api.dart';

import '../fixtures/test_accounts.dart';
import '../helpers/cleanup_helper.dart';

/// In-memory storage implementation for PKCE tokens in tests.
///
/// This storage doesn't persist data and is suitable for test environments
/// where platform plugins like shared_preferences are not available.
class InMemoryGotrueAsyncStorage implements GotrueAsyncStorage {
  final Map<String, String> _storage = <String, String>{};

  @override
  Future<String?> getItem({required String key}) => Future<String?>.value(_storage[key]);

  @override
  Future<void> setItem({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _storage.remove(key);
  }
}

/// Common setup for integration tests.
///
  /// Initializes Supabase client with test credentials from unit-test.env file.
/// This setup must be called in setUpAll() of each test file.
class TestSetup {
  TestSetup._();

  /// Initializes Supabase for testing.
  ///
  /// Loads environment variables from unit-test.env file at project root
  /// and initializes Supabase client with in-memory storage.
  ///
  /// Throws [Exception] if .env file or required credentials are not found.
  static Future<SupabaseClient> initializeSupabase() async {
    // Find unit-test.env at the project root
    // Start from the test file location and navigate up to find the project root
    final Uri testFileUri = Platform.script;
    final File testFile = File.fromUri(testFileUri);
    Directory? projectRoot = testFile.parent;
    File? envFile;

    while (projectRoot != null) {
      final File candidateEnvFile = File('${projectRoot.path}/unit-test.env');
      if (await candidateEnvFile.exists()) {
        envFile = candidateEnvFile;
        break;
      }
      final Directory parent = projectRoot.parent;
      if (parent.path == projectRoot.path) {
        break;
      }
      projectRoot = parent;
    }

    // Load the unit-test.env file - it must exist at the project root
    if (envFile == null) {
      throw Exception(
        'Could not find unit-test.env at the project root. '
        'Create unit-test.env with your test credentials. '
        'See test/README.md for setup instructions.',
      );
    }

    await dotenv.load(fileName: envFile.path);

    // Get Supabase credentials from environment variables
    // Priority: dotenv file > system environment variables
    final String supabaseUrl = dotenv.env['TEST_BASE_URL'] ?? Platform.environment['TEST_BASE_URL'] ?? '';

    final String supabaseAnonKey = dotenv.env['TEST_ANON_KEY'] ?? Platform.environment['TEST_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not found. Please ensure TEST_BASE_URL and TEST_ANON_KEY '
        'are set in unit-test.env at the project root.',
      );
    }

    // Initialize Supabase with in-memory storage for tests
    // This avoids the need for platform plugins like shared_preferences
    // EmptyLocalStorage is provided by supabase_flutter for test environments
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        pkceAsyncStorage: InMemoryGotrueAsyncStorage(),
        localStorage: const EmptyLocalStorage(),
      ),
    );

    return TrainerAPI.client;
  }

  /// Signs in with the given test account and cleans up existing user data.
  ///
  /// Skips sign-in if already authenticated with the same account.
  /// Adds delays to respect Supabase rate limits.
  ///
  /// - [supabase]: The Supabase client instance.
  /// - [account]: The test account to sign in with.
  static Future<void> signInAndCleanup(
    SupabaseClient supabase,
    TestAccount account,
  ) async {
    final User? currentUser = supabase.auth.currentUser;
    if (currentUser?.email != account.email) {
      await supabase.auth.signInWithPassword(
        email: account.email,
        password: account.password,
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    await CleanupHelper.cleanupUserData(supabase, supabase.auth.currentUser!.id);
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
