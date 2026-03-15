import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:trainer_backend/models/models.export.dart';
import 'package:trainer_backend/services/auth.service.dart';
import 'package:trainer_backend/services/subscriptions.service.dart';
import 'package:trainer_backend/trainer_backend.configuration.dart';
import 'package:trainer_backend_example/auth_test.screen.dart';
import 'package:trainer_backend_example/home_test.screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TrainerBackendConfiguration.init(trainerBackendFlavor: TrainerBackendFlavor.test);

  log(name: 'ENV', 'flavor: ${TrainerBackendConfiguration.instance.flavor.name}');
  log(name: 'ENV', 'baseUrl: ${TrainerBackendConfiguration.instance.baseUrl}');
  log(name: 'ENV', 'anonKey: ${TrainerBackendConfiguration.instance.anonKey}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Trainer Backend Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: StreamBuilder<AppAuthState>(
          stream: AuthService.onAuthStateChange,
          builder: (BuildContext context, AsyncSnapshot<AppAuthState> snapshot) {
            switch (snapshot.data) {
              case AppAuthenticated():
                // Initialize RevenueCat SDK after authentication
                final String? userId = AuthService.currentUser?.id;
                if (userId != null && userId.isNotEmpty) {
                  try {
                    SubscriptionsService.configureRevenueCat(
                      // apiKey: 'appl_vqLRQXywqzbNdKdQzNMTLQbFWoi',
                      apiKey: 'goog_vessnrpBHCSiEhLQyheoNUzoQyd',
                      // apiKey: 'test_BGEVjwYIZHblYEkAgZCBHLiHeax',
                      userId: userId,
                    ).then((_) {
                      log(name: 'RevenueCat', 'SDK initialized successfully');
                    }).catchError((Object error) {
                      log(name: 'RevenueCat', 'Failed to initialize: $error');
                    });
                  } catch (e) {
                    log(name: 'RevenueCat', 'Error initializing: $e');
                  }
                }
                return const HomeTestScreen();
              case AppAuthPasswordRecovery():
              case AppUnauthenticated():
                return const AuthTestScreen();
              case AppAuthInitial():
              case AppAuthLoading():
              case null:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
            }
          },
        ),
      );
}
