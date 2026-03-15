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

- **Authentication**: Full auth suite including email/password, Google, and Apple sign-in. Supports OTP verification and password management. Includes optimized token refresh handling for seamless user experience.
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

Listen to authentication state changes. The stream emits `AppAuthState` objects (sealed class):

```dart
AuthService.onAuthStateChange.listen((state) {
  if (state is AppAuthenticated) {
    if (!state.isTokenRefresh) {
      // Real sign-in: fetch user data, show welcome screen
    }
    // Token refresh (isTokenRefresh == true): keep current state, no action needed
  } else if (state is AppUnauthenticated) {
    // Signed out or account deleted: redirect to login
  } else if (state is AppAuthPasswordRecovery) {
    // User initiated a password reset
  } else if (state is AppAuthLoading) {
    // Transitioning between states
  }
});
```

Sign up and confirm via OTP:

```dart
try {
  await AuthService.signUp(
    email: 'test@example.com',
    password: 'securepassword123',
    username: 'testuser',
  );

  // Then confirm with the OTP sent by email
  await AuthService.confirmSignUp(email: 'test@example.com', token: '123456');
} on AuthException catch (e) {
  // Handle error
}
```

Other available methods:

| Method | Description |
|---|---|
| `signIn(email, password)` | Email/password sign-in |
| `signInWithGoogle()` | Google OAuth sign-in |
| `signInWithApple()` | Apple OAuth sign-in |
| `signOut()` | Sign out the current user |
| `deleteAccount()` | Permanently delete the user account |
| `resendConfirmationCode(email)` | Resend the OTP confirmation code |
| `sendPasswordResetCode(email)` | Send a password reset OTP |
| `verifyPasswordResetCode(email, token)` | Verify the password reset OTP |
| `updatePassword(newPassword)` | Update the current user's password |
| `getProfileWithInitialData(limit)` | Fetch user profile with initial programs and session logs |
| `currentUser` | Getter for the currently signed-in `User?` |

### Programs (`ProgramsService`)

Full lifecycle management for training programs (CRUD, sessions, favorites).

```dart
// Fetch paginated programs
final List<Program> programs = await ProgramsService.fetchUserPrograms(page: 0, pageSize: 10);

// Create a complete program with sessions and exercises
final Program created = await ProgramsService.createFullProgram(newProgram);

// Update program metadata and session order
final Program updated = await ProgramsService.updateFullProgram(program);

// Add a session to an existing program
final Program withNewSession = await ProgramsService.addSessionToProgram(
  programId: 42,
  session: newSession,
);

// Delete a session (returns the updated program)
final Program afterDelete = await ProgramsService.deleteSession(sessionId);

// Delete a program entirely (returns the deleted program ID)
final int deletedId = await ProgramsService.deleteProgram(programId);

// Favorites
final Program faved = await ProgramsService.addProgramToFavorites(programId);
final Program unfaved = await ProgramsService.removeProgramFromFavorites(programId);
```

> **Subscription limits**: `createFullProgram` and `addSessionToProgram` may throw `PostgrestException` with codes like `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y`, `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y`, `LIMIT_EXCEEDED:MAX_EXERCISES:X/Y`, `SUBSCRIPTION_INACTIVE`, or `SUBSCRIPTION_EXPIRED`.

### Sessions (`SessionsService`)

Update a full session (exercises, parameters, ordering):

```dart
final SessionApiResponse response = await SessionsService.updateFullSession(updatedSession);
final Session authoritativeSession = response.session;
```

> **Subscription limits**: `updateFullSession` may throw `PostgrestException` with codes `LIMIT_EXCEEDED:MAX_EXERCISES:X/Y`, `SUBSCRIPTION_INACTIVE`, or `SUBSCRIPTION_EXPIRED` when adding new exercises.

### History (`HistoryService`)

Log a completed session and retrieve past logs:

```dart
// Log a session
final CreateSessionLogResponse response = await HistoryService.createSessionLog(sessionLog);
// response contains the created log and an updated session preview

// Fetch paginated session logs
final List<SessionLog> logs = await HistoryService.fetchUserSessionsLogs(page: 0, pageSize: 10);
```

### Subscriptions (`SubscriptionsService`)

Complete subscription management combining **Supabase** (limits, entitlements, usage) and **RevenueCat** (purchases, offerings, customer info).

#### Setup

RevenueCat must be configured once after user authentication:

```dart
await SubscriptionsService.configureRevenueCat(
  apiKey: 'your_revenuecat_api_key', // test_, appl_, or goog_ prefix
  userId: AuthService.currentUser!.id,
);
```

#### Subscription info (Supabase)

```dart
// Get the active subscription summary (falls back to Free if none)
final SubscriptionSummary summary = await SubscriptionsService.getUserSubscriptionSummary();

// Check if the user can access a specific feature
final FeatureAccess access = await SubscriptionsService.checkFeatureAccess(featureKey: 'premium_feature');
if (access.hasAccess) {
  // Grant access
}

// Get limits with current usage counts (programs, exercises, sessions)
final SubscriptionLimitsWithUsage usage = await SubscriptionsService.getUserLimitsWithUsage();
```

#### Purchases (RevenueCat)

```dart
// Fetch available offerings and packages
final Offerings? offerings = await SubscriptionsService.getOfferings();

// Purchase a package (returns a SubscriptionSummary for immediate UI update)
final SubscriptionSummary result = await SubscriptionsService.purchasePackage(package: selectedPackage);

// Restore previous purchases
final CustomerInfo restored = await SubscriptionsService.restorePurchases();

// Get current customer info
final CustomerInfo info = await SubscriptionsService.getCustomerInfo();

// Get the platform subscription management URL (App Store / Play Store)
final String? managementUrl = await SubscriptionsService.getManagementURL();
```

## Data Models

The package includes a comprehensive set of data models to represent all backend entities:
- **`Program`**: A collection of `Session` objects.
- **`Session`**: A single workout day, composed of `Exercise` objects. Exists as a sealed class (`ClassicSession`, `AmrapSession`, etc.).
- **`Exercise`**: A specific exercise within a session, with `templateParameters` and optional `objectiveParameters` for progression.
- **`SessionLog`**: A record of a completed workout, containing `RoundLog` and `ExerciseLog` data.
- **`SubscriptionSummary`**: Active subscription with entitlement, product info, and limits.
- **`FeatureAccess`**: Result of a feature access check (`hasAccess`, `featureKey`, `limits`).
- **`SubscriptionLimitsWithUsage`**: Subscription limits combined with current usage counts.
- **`CustomerInfo`**: RevenueCat customer data (entitlements, active subscriptions).
- **`Offerings`** / **`Package`**: RevenueCat offerings and purchasable packages.

All models are strongly-typed and include `fromJson`/`toJson` methods for easy serialization.

## Adding a New Subscription Product

When a new subscription product is added in the App Store Connect, Google Play Console, or RevenueCat dashboard, the following file **must** be updated in this package:

### `lib/constants/subscription.constants.dart`

This file contains `SubscriptionConstants.productToEntitlement`, a static map that associates each **RevenueCat product identifier** to its **entitlement key** (`Premium`, `Basic`, etc.).

```dart
static const Map<String, String> productToEntitlement = <String, String>{
  // Test Store & App Store (iOS)
  'premium_monthly_subscription': 'Premium',
  'premium_annual_subscription': 'Premium',
  'basic_monthly_subscription': 'Basic',
  'basic_annual_subscription': 'Basic',

  // Play Store (Android)
  'premium_monthly:pm': 'Premium',
  'premium_annual:pa': 'Premium',
  'basic_monthly:bm': 'Basic',
  'basic_annual:ba': 'Basic',
};
```

### Step-by-step process

1. **Create the product** in the relevant store console (App Store Connect and/or Google Play Console).
2. **Create or attach the product** in the RevenueCat dashboard, linking it to the appropriate entitlement (`Premium`, `Basic`, etc.).
3. **Add a new entry** in `productToEntitlement` using the exact product identifier from RevenueCat as the key and the entitlement lookup key as the value.
4. **Note on identifiers**:
   - iOS / Test Store products use flat identifiers (e.g., `premium_monthly_subscription`).
   - Android (Play Store) products use the `product:basePlan` format (e.g., `premium_monthly:pm`).
5. **Publish** a new version of the package so the consuming app picks up the mapping.

> **Why is this needed?** RevenueCat's `getOfferings()` returns packages without entitlement information. This local mapping is used by the SDK to enrich each package with its `entitlementIdentifier`, which is required before calling `purchasePackage()`.

## Additional Information

To report a bug or request a feature, please file an issue on the project's repository. We appreciate your contributions!
