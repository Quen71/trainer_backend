# Test Fixtures

This directory contains fixtures used to create standardized test data.

## test_programs.dart

The `TestPrograms` class provides utility methods to create properly formatted training programs for tests.

### Main Methods

#### Simple Programs

```dart
// Create a simple program with a single Classic session
final program = TestPrograms.createSimpleProgram(
  name: 'My Program',
  sessionName: 'Session 1',
  style: SessionStyle.weights,
  exerciseCount: 5,
);
```

#### Programs with Multiple Sessions

```dart
// Create a program with N sessions of the same type
final program = TestPrograms.createProgramWithMultipleSessions(
  name: 'Complete Program',
  sessionCount: 5,
  exercisesPerSession: 3,
  style: SessionStyle.weights,
);
```

#### Programs with Mixed Session Types

```dart
// Create a program with different session types (Classic, AMRAP, EMOM, HIIT)
final program = TestPrograms.createMixedTypeProgram(
  name: 'Mixed Program',
  includeClassic: true,
  includeAmrap: true,
  includeEmom: true,
  includeHiit: true,
  exercisesPerSession: 2,
);
```

#### Mixed Sessions Program (for Premium volume tests)

```dart
// Create a program with N sessions cycling through Classic, AMRAP, EMOM, HIIT
final program = TestPrograms.createMixedSessionsProgram(
  name: 'Premium Mixed',
  sessionCount: 50,
  exercisesPerSession: 1,
);
```

### Limit Testing

#### Session Limit Test

```dart
// Create a program with exactly N sessions to test limits
final program = TestPrograms.createProgramForSessionLimitTest(
  name: 'Limit Test',
  sessionCount: 10,
  sessionType: 'classic', // 'classic', 'amrap', 'emom', 'hiit'
  exercisesPerSession: 1,
);
```

#### Exercise Limit Test

```dart
// Create a program with exactly N exercises to test limits
final program = TestPrograms.createProgramForExerciseLimitTest(
  name: 'Exercise Limit Test',
  exerciseCount: 15,
  sessionType: 'classic',
);
```

### Individual Session Creation

Create individual sessions to add to existing programs:

```dart
// Classic session
final classicSession = TestPrograms.createClassicSession(
  name: 'My Session',
  orderInProgram: 1,
  style: SessionStyle.weights,
  exerciseCount: 5,
);

// AMRAP session
final amrapSession = TestPrograms.createAmrapSession(
  name: 'AMRAP Session',
  orderInProgram: 2,
  duration: Duration(minutes: 20),
  style: SessionStyle.bodyweight,
  exerciseCount: 3,
);

// EMOM session
final emomSession = TestPrograms.createEmomSession(
  name: 'EMOM Session',
  orderInProgram: 3,
  roundNumber: 10,
  style: SessionStyle.bodyweight,
  exerciseCount: 4,
);

// HIIT session
final hiitSession = TestPrograms.createHiitSession(
  name: 'HIIT Session',
  orderInProgram: 4,
  roundNumber: 8,
  style: SessionStyle.bodyweight,
  exerciseCount: 2,
);
```

## test_accounts.dart

Provides test accounts for different subscription types. Credentials are loaded from environment variables (`.env` file) to avoid committing secrets to git.

### Required environment variables (in `unit-test.env`)

- `TEST_FREE_EMAIL` / `TEST_FREE_PASSWORD`
- `TEST_BASIC_EMAIL` / `TEST_BASIC_PASSWORD`
- `TEST_PREMIUM_EMAIL` / `TEST_PREMIUM_PASSWORD`

See `test/README.md` for setup instructions.

### Usage

```dart
// Sign in with Basic account (credentials from .env)
await supabase.auth.signInWithPassword(
  email: TestAccounts.basicUser.email,
  password: TestAccounts.basicUser.password,
);

// Sign in with Premium account
await supabase.auth.signInWithPassword(
  email: TestAccounts.premiumUser.email,
  password: TestAccounts.premiumUser.password,
);
```

## Best Practices

1. **Use fixtures**: Always use fixtures to create test data rather than manually constructing objects. This ensures consistency and simplifies maintenance.

2. **Explicit naming**: Give descriptive names to your test programs for easier debugging.

3. **Configurable parameters**: Use optional parameters to customize fixtures based on your test needs.

4. **Limit tests**: Use dedicated methods (`createProgramForSessionLimitTest`, `createProgramForExerciseLimitTest`) for subscription limit testing.

## Usage Examples

### Program Creation Test

```dart
test('should create a program successfully', () async {
  final program = TestPrograms.createSimpleProgram(name: 'Test Program');
  final created = await ProgramsService.createFullProgram(program);
  
  expect(created.id, greaterThan(0));
  expect(created.name, equals('Test Program'));
});
```

### Session Limit Test

```dart
test('should enforce session limit', () async {
  final program = TestPrograms.createProgramForSessionLimitTest(
    name: 'Max Sessions Program',
    sessionCount: 10,
  );
  
  await ProgramsService.createFullProgram(program);
  
  // Attempting to add an extra session should fail
  final newSession = TestPrograms.createClassicSession(
    name: 'Extra Session',
    orderInProgram: 11,
  );
  
  expect(
    () => ProgramsService.addSessionToProgram(
      programId: program.id,
      session: newSession,
    ),
    throwsA(isA<PostgrestException>()),
  );
});
```

### Mixed Program Test

```dart
test('should create mixed type program', () async {
  final program = TestPrograms.createMixedTypeProgram(
    name: 'Complete Program',
    exercisesPerSession: 3,
  );
  
  final created = await ProgramsService.createFullProgram(program);
  
  expect(created.sessions.length, equals(4));
  expect(created.sessions[0], isA<ClassicSession>());
  expect(created.sessions[1], isA<AmrapSession>());
  expect(created.sessions[2], isA<EmomSession>());
  expect(created.sessions[3], isA<HiitSession>());
});
```
