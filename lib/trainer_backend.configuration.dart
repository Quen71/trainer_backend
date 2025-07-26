import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Defines the available environments for the backend.
enum TrainerBackendFlavor {
  /// The test environment, for development and staging.
  test,

  /// The production environment, for the live application.
  prod,
}

/// A singleton class for managing backend configuration.
///
/// This class is responsible for loading the correct Supabase URL and anon key
/// from a `.env` file based on the selected [TrainerBackendFlavor]. It must be

/// initialized using the [init] method before it can be accessed via [instance].
class TrainerBackendConfiguration {
  /// The constructor is private to create a singleton.
  const TrainerBackendConfiguration._({
    required this.flavor,
    required this.baseUrl,
    required this.anonKey,
  });

  /// The active environment flavor.
  final TrainerBackendFlavor flavor;

  /// The Supabase base URL for the active flavor.
  final String baseUrl;

  /// The Supabase anon key for the active flavor.
  final String anonKey;

  /// The single instance of this configuration.
  static TrainerBackendConfiguration? _instance;

  /// Provides access to the singleton instance.
  ///
  /// Throws an [Exception] if [init] has not been called first.
  static TrainerBackendConfiguration get instance {
    if (_instance == null) throw Exception('No instance build for TrainerBackendConfiguration');

    return _instance!;
  }

  /// Initializes the backend configuration and the Supabase client.
  ///
  /// This method must be called once at application startup. It loads the
  /// environment variables from the `.env` file located in the package,
  /// sets up the correct configuration instance based on the provided [flavor],
  /// and initializes the [Supabase] client.
  ///
  /// - [trainerBackendFlavor]: The environment to configure.
  static Future<void> init({required TrainerBackendFlavor trainerBackendFlavor}) async {
    final String envString = await rootBundle.loadString('packages/trainer_backend/.env');
    final Map<String, String> envMap = const Parser().parse(envString.split('\n'));

    switch (trainerBackendFlavor) {
      case TrainerBackendFlavor.test:
        _instance = TrainerBackendConfiguration._(
          flavor: TrainerBackendFlavor.test,
          baseUrl: envMap['TEST_BASE_URL'] ?? '',
          anonKey: envMap['TEST_ANON_KEY'] ?? '',
        );
        break;
      case TrainerBackendFlavor.prod:
        _instance = TrainerBackendConfiguration._(
          flavor: TrainerBackendFlavor.prod,
          baseUrl: envMap['PROD_BASE_URL'] ?? '',
          anonKey: envMap['PROD_ANON_KEY'] ?? '',
        );
        break;
    }

    await Supabase.initialize(
      url: instance.baseUrl,
      anonKey: instance.anonKey,
    );
  }
}
