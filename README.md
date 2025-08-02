<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Trainer Backend

A Flutter package providing a complete client-side SDK to interact with the Trainer app's Supabase backend. It handles authentication, training program management, session logging, and more.

## Features

- **Authentication**: Full auth suite including email/password, Google, and Apple sign-in. Supports OTP verification and password management.
- **Program Management**: Full CRUD operations for multi-session training programs.
- **Session & Exercise Management**: Detailed control over session structure, exercise ordering, and parameters.
- **Progressive Overload**: Support for defining and updating template and objective parameters for exercises.
- **Workout Logging**: Comprehensive system for logging completed sessions and exercises.
- **Typed Models**: Strongly-typed data models for all backend entities, ensuring type safety and reducing runtime errors.
- **Environment Configuration**: Easy setup for different environments (e.g., test, production) via a `.env` file.

## Getting Started

### Prerequisites

- A configured Supabase project.
- A Flutter environment.

### Installation

1.  Add `trainer_backend` to your `pubspec.yaml` dependencies.

    **Option A: From pub.dev (if available)**
    ```yaml
    dependencies:
      trainer_backend: ^1.0.0 # Replace with the latest version
    ```

    **Option B: From GitHub**
    This is useful if you want to use the latest development version or if the package is private.

    ```yaml
    dependencies:
      trainer_backend:
        git:
          url: https://github.com/your-username/trainer_backend.git
          # Optionally, specify a branch, tag, or commit hash:
          # ref: main
          # ref: v1.2.3
    ```

2.  Create a `.env` file in the root of your project. This file will store your Supabase credentials.

    ```
    # Test Environment
    TEST_BASE_URL=YOUR_TEST_SUPABASE_URL
    TEST_ANON_KEY=YOUR_TEST_SUPABASE_ANON_KEY

    # Production Environment
    PROD_BASE_URL=YOUR_PROD_SUPABASE_URL
    PROD_ANON_KEY=YOUR_PROD_SUPABASE_ANON_KEY
    ```

3.  **Important**: The package needs access to this `.env` file. Ensure you declare it in your `pubspec.yaml` assets. The package loader specifically looks for `packages/trainer_backend/.env`.

    ```yaml
    flutter:
      assets:
        - packages/trainer_backend/.env
    ```

### Initialization

Before using any of the services, you must initialize the backend configuration in your `main.dart` file.

```dart
import 'package:flutter/material.dart';
import 'package:trainer_backend/trainer_backend.dart';

void main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the backend with the desired flavor.
  await TrainerBackendConfiguration.init(
    trainerBackendFlavor: TrainerBackendFlavor.prod, // Or .test
  );

  runApp(const MyApp());
}
```

## Usage

All functionalities are exposed through static methods on service classes.

### Authentication (`AuthService`)

Listen to authentication state changes to react to sign-ins and sign-outs.

```dart
AuthService.onAuthStateChange.listen((authState) {
  final event = authState.event;
  final session = authState.session;
  if (event == AuthChangeEvent.signedIn) {
    // handle user sign in
  } else if (event == AuthChangeEvent.signedOut) {
    // handle user sign out
  }
});
```

Sign up a new user:

```dart
try {
  await AuthService.signUp(
    email: 'test@example.com',
    password: 'securepassword123',
    username: 'testuser',
  );
  // On success, you may need to confirm the signup via OTP.
} on AuthException catch (e) {
  // Handle error
}
```

### Programs (`ProgramsService`)

Fetch a list of the user's training programs.

```dart
try {
  final List<Program> programs = await ProgramsService.fetchUserPrograms(page: 0, pageSize: 10);
  // Display programs in your UI
} catch (e) {
  // Handle error
}
```

Create a new, complete program.

```dart
// First, build your Program object with its Sessions and Exercises.
final newProgram = Program.forCreation(
  name: 'My New Program',
  sessions: [
    //... your session objects
  ],
);

try {
  final Program createdProgram = await ProgramsService.createFullProgram(newProgram);
  // Use the returned program, now with IDs from the database.
} catch (e) {
  // Handle error
}
```

### History (`HistoryService`)

Log a completed session.

```dart
// Build your SessionLog object from the user's performance data.
final sessionLog = ClassicSessionLog.forCreation(
  sessionId: 123,
  startedAt: DateTime.now().subtract(const Duration(minutes: 45)),
  endedAt: DateTime.now(),
  rounds: [
    //... your round and exercise logs
  ],
);

try {
  final SessionLog createdLog = await HistoryService.createSessionLog(sessionLog);
  // Log was successfully saved.
} catch (e) {
  // Handle error
}
```

### Sessions (`SessionsService`)

Update a full session, for instance after a user modifies it in the UI. This is useful for reordering exercises, changing parameters, or adding new ones.

```dart
// Assume `updatedSession` is a Session object with modified data.
try {
  final SessionApiResponse response = await SessionsService.updateFullSession(updatedSession);
  // The session was successfully updated.
  // The `response` contains the updated session, including any new IDs
  // for newly added exercises.
  final Session authoritativeSession = response.session;
} catch (e) {
  // Handle error
}
```

## Data Models

The package includes a comprehensive set of data models to represent all backend entities:
- **`Program`**: A collection of `Session` objects.
- **`Session`**: A single workout day, composed of `Exercise` objects. Exists as a sealed class (`ClassicSession`, `AmrapSession`, etc.).
- **`Exercise`**: A specific exercise within a session, with `templateParameters` and optional `objectiveParameters` for progression.
- **`SessionLog`**: A record of a completed workout, containing `RoundLog` and `ExerciseLog` data.

All models are strongly-typed and include `fromJson`/`toJson` methods for easy serialization.

## Additional Information

To report a bug or request a feature, please file an issue on the project's repository. We appreciate your contributions!
