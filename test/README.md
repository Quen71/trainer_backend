# Integration tests (`test/`)

This directory contains **integration tests** for the `trainer_backend` package against a real Supabase project (via the Flutter client / PostgREST). They cover:

1. **`lib/services`** — CRUD flows and RPCs aligned with the app (programs, sessions, history, subscriptions).
2. **Subscription limits** (Free / Basic / Premium) — quotas enforced in the database and verified via `ProgramsService` and usage counters.

**RevenueCat** methods on `SubscriptionsService` (offerings, purchases, etc.) are **not** tested here: they require a real store environment. There is no dedicated test file for `AuthService` in this folder.

## Structure

```
test/
├── fixtures/
│   ├── test_accounts.dart       # Test accounts (Free / Basic / Premium)
│   ├── test_programs.dart       # Test programs and sessions
│   ├── test_session_logs.dart   # Session logs (history)
│   └── README.md                # Fixtures documentation
├── helpers/
│   └── cleanup_helper.dart      # Test data cleanup
├── integration/
│   ├── test_setup.dart          # Supabase init + sign-in / cleanup
│   ├── programs/
│   │   └── programs_service_test.dart    # ProgramsService
│   ├── sessions/
│   │   └── sessions_service_test.dart    # SessionsService
│   ├── history/
│   │   └── history_service_test.dart     # HistoryService
│   └── subscriptions/
│       ├── subscriptions_service_test.dart  # getUserSubscriptionSummary (Supabase)
│       ├── free_plan_limits_test.dart
│       ├── basic_plan_limits_test.dart
│       └── premium_plan_limits_test.dart
└── README.md                    # This file
```

## Coverage by service

| Test file | Service(s) | Main methods / theme |
|-----------|------------|----------------------|
| `integration/programs/programs_service_test.dart` | `ProgramsService` | `createFullProgram`, `fetchUserPrograms`, `updateFullProgram`, `addSessionToProgram`, `deleteSession`, `deleteProgram`, favorites — Classic, AMRAP, EMOM, HIIT session types |
| `integration/sessions/sessions_service_test.dart` | `SessionsService` (+ creation via `ProgramsService`) | `updateFullSession` for all four session types |
| `integration/history/history_service_test.dart` | `HistoryService` | `createSessionLog`, `fetchUserSessionsLogs` for all four log types |
| `integration/subscriptions/subscriptions_service_test.dart` | `SubscriptionsService` | `getUserSubscriptionSummary` (Free, Basic, Premium) |
| `integration/subscriptions/*_plan_limits_test.dart` | `ProgramsService`, `SubscriptionsService` | Per-plan caps (programs, sessions, exercises, counters) |

**Programs / sessions / history** service tests usually use the **Premium** account (`TestAccounts.premiumUser`) to avoid quota interference. Each test registers `addTearDown` to delete the data it creates.

### Parallel execution

These files share the same Premium user. For more deterministic results when multiple files run in parallel (test explorer, CI), prefer:

```bash
flutter test test/integration/ --concurrency=1
```

## Prerequisites

1. **Dedicated Supabase test project** (recommended)
   - Migrations applied
   - Entitlements configured (Free, Basic, Premium)

2. **Environment file**
   - Create a `unit-test.env` file at the project root (gitignored) with the Supabase URL, anon key, and test account credentials

## Test account setup

### 1. Create users

Create accounts in Supabase Auth whose **emails and passwords** match `unit-test.env`. Credentials must never be committed.

| Plan | `unit-test.env` variables | Expected plan |
|------|---------------------------|---------------|
| Free | `TEST_FREE_EMAIL` / `TEST_FREE_PASSWORD` | Free |
| Basic | `TEST_BASIC_EMAIL` / `TEST_BASIC_PASSWORD` | Basic |
| Premium | `TEST_PREMIUM_EMAIL` / `TEST_PREMIUM_PASSWORD` | Premium |

### 2. Subscriptions in the database

#### Free account
- Replace `YOUR_FREE_EMAIL` with the value of `TEST_FREE_EMAIL`.
- No explicit subscription required — falls back to Free automatically.

#### Basic account
- Replace `YOUR_BASIC_EMAIL` with `TEST_BASIC_EMAIL`.

```sql
SELECT id FROM auth.users WHERE email = 'YOUR_BASIC_EMAIL';

INSERT INTO subscriptions (user_id, entitlement_key, status, started_at, expires_at, is_trial)
VALUES (
  'USER_ID',
  'Basic',
  'active',
  NOW(),
  NOW() + INTERVAL '30 days',
  false
);
```

#### Premium account
- Replace `YOUR_PREMIUM_EMAIL` with `TEST_PREMIUM_EMAIL`.

```sql
SELECT id FROM auth.users WHERE email = 'YOUR_PREMIUM_EMAIL';

INSERT INTO subscriptions (user_id, entitlement_key, status, started_at, expires_at, is_trial)
VALUES (
  'USER_ID',
  'Premium',
  'active',
  NOW(),
  NOW() + INTERVAL '30 days',
  false
);
```

### 3. Verify entitlements

```sql
SELECT * FROM entitlements WHERE entitlement_key IN ('Free', 'Basic', 'Premium');
```

Expected limits (adjust if your schema differs):

| Entitlement | max_programs | max_sessions_per_program | max_exercises_per_session | history_days |
|-------------|--------------|--------------------------|---------------------------|--------------|
| Free | 1 | 2 | 6 | 7 |
| Basic | 5 | 10 | 15 | 30 |
| Premium | NULL (unlimited / large caps in app) | 30 | 20 | 365 |

### 4. Optional helper SQL script

After creating users via Auth:

```sql
CREATE OR REPLACE FUNCTION create_test_subscription(
  p_email TEXT,
  p_entitlement_key TEXT,
  p_status TEXT,
  p_expires_at TIMESTAMPTZ
) RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = p_email;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found: %', p_email;
  END IF;

  INSERT INTO subscriptions (user_id, entitlement_key, status, started_at, expires_at, is_trial)
  VALUES (v_user_id, p_entitlement_key, p_status, NOW(), p_expires_at, false)
  ON CONFLICT (user_id) DO UPDATE
  SET entitlement_key = p_entitlement_key,
      status = p_status,
      expires_at = p_expires_at;

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

SELECT create_test_subscription('YOUR_BASIC_EMAIL', 'Basic', 'active', NOW() + INTERVAL '30 days');
SELECT create_test_subscription('YOUR_PREMIUM_EMAIL', 'Premium', 'active', NOW() + INTERVAL '30 days');

DROP FUNCTION create_test_subscription(TEXT, TEXT, TEXT, TIMESTAMPTZ);
```

## Running tests

### Environment variables (`unit-test.env` at project root)

| Variable | Description |
|----------|-------------|
| `TEST_BASE_URL` | Supabase project URL (test environment) |
| `TEST_ANON_KEY` | Supabase anon key (test environment) |
| `TEST_FREE_EMAIL` / `TEST_FREE_PASSWORD` | Free account |
| `TEST_BASIC_EMAIL` / `TEST_BASIC_PASSWORD` | Basic account |
| `TEST_PREMIUM_EMAIL` / `TEST_PREMIUM_PASSWORD` | Premium account |

The `unit-test.env` file is gitignored and must not be committed.

### Commands

```bash
# All integration tests
flutter test test/integration/

# By area
flutter test test/integration/programs/
flutter test test/integration/sessions/
flutter test test/integration/history/
flutter test test/integration/subscriptions/

# Individual files (examples)
flutter test test/integration/programs/programs_service_test.dart
flutter test test/integration/subscriptions/free_plan_limits_test.dart

# Single test by name
flutter test test/integration/subscriptions/free_plan_limits_test.dart --name "should create 1 program successfully"
```

## What each suite covers

- **Per-plan limits** (`free_plan_limits_test.dart`, `basic_plan_limits_test.dart`, `premium_plan_limits_test.dart`): caps on programs / sessions / exercises and usage counter checks.
- **ProgramsService**: full program + session lifecycle (create, read, update, delete, favorites).
- **SessionsService**: full session update and `SessionApiResponse` consistency (global exercise names are not updated by the RPC — tests focus on parameters).
- **HistoryService**: log creation and history fetch for each session / log type.

Shared setup lives in `integration/test_setup.dart` (Supabase client with in-memory storage suitable for tests, without platform plugins for PKCE persistence).

## Fixtures

- **test_accounts.dart**: Free / Basic / Premium accounts from `unit-test.env`.
- **test_programs.dart**: programs and sessions (simple, multi-session, mixed types, limit scenarios).
- **test_session_logs.dart**: session logs for history tests (session / exercise IDs from a real `ProgramsService` create).

See `fixtures/README.md` for detailed usage.

## Cleanup

Service tests register targeted cleanup (`addTearDown`, program deletion, etc.). Global helpers remain available via `CleanupHelper` for limit scenarios.

Manual cleanup:

```sql
DELETE FROM programs WHERE user_id = 'USER_ID';
DELETE FROM subscription_limit_events WHERE user_id = 'USER_ID';
```

## Troubleshooting

### Error: "User not found"
- Verify accounts exist in Supabase Auth.
- Align `TEST_*_EMAIL` in `unit-test.env` with real accounts.

### Error: "Missing TEST_* in unit-test.env"
- Ensure `unit-test.env` exists at the project root with all required variables.

### Error: "Subscription not found" / wrong plan
- Rows exist in `subscriptions` with the correct `entitlement_key`.

### Error: "Entitlement not found"
- Rows in `entitlements` with limits consistent with the tests.

### Intermittent failures in parallel
- Run with `--concurrency=1` when multiple suites share the same accounts.

### Other failures
- Migrations and RPC functions up to date; check Supabase logs for SQL errors.

## PostgreSQL error codes (limits)

Tests assert messages such as:

- `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y`
- `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y`
- `LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION:X/Y`

These codes appear in the `PostgrestException` message, not in a separate field.

## Important notes

- Do not use these accounts in production.
- Use a dedicated Supabase project for tests.
- Tests modify the database — do not run against production.
- Service tests are designed to be independent thanks to per-test cleanup.
