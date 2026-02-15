# Integration Tests - Subscription Limits

This directory contains integration tests for the Supabase subscription limits system.

## Structure

```
test/
├── fixtures/
│   ├── test_accounts.dart          # Test accounts (Free/Basic/Premium)
│   ├── test_programs.dart          # Test program fixtures
│   └── README.md                   # Fixtures documentation
├── helpers/
│   └── cleanup_helper.dart         # Helper for cleaning up test data
├── integration/
│   ├── test_setup.dart             # Common setup for tests
│   ├── free_plan_limits_test.dart  # Free Plan limit tests
│   ├── basic_plan_limits_test.dart # Basic Plan limit tests
│   ├── premium_plan_limits_test.dart # Premium Plan limit tests
│   └── usage_counters_test.dart    # Usage counter tests
└── README.md                       # This file
```

## Prerequisites

1. **Separate Supabase test project** (recommended)
   - Create a dedicated Supabase project for tests
   - Apply all necessary migrations
   - Configure entitlements (Free, Basic, Premium)

2. **Environment configuration**
   - Create a `unit-test.env` file (gitignored) with Supabase credentials and test account credentials

## Test Account Setup

### 1. Create User Accounts

Create accounts in Supabase Auth using the **same emails and passwords** you configure in `unit-test.env`. Credentials are never committed to git.

| Plan | unit-test.env variable | Expected plan |
|------|--------------|---------------|
| Free | `TEST_FREE_EMAIL` / `TEST_FREE_PASSWORD` | Free |
| Basic | `TEST_BASIC_EMAIL` / `TEST_BASIC_PASSWORD` | Basic |
| Premium | `TEST_PREMIUM_EMAIL` / `TEST_PREMIUM_PASSWORD` | Premium |

### 2. Create Subscriptions in the Database

#### Free account
Replace `YOUR_FREE_EMAIL` with the value of `TEST_FREE_EMAIL` from your `unit-test.env`.
- No explicit subscription required
- System falls back to Free automatically

#### Basic account
Replace `YOUR_BASIC_EMAIL` with the value of `TEST_BASIC_EMAIL` from your `unit-test.env`.

```sql
-- Get user UUID (use your TEST_BASIC_EMAIL)
SELECT id FROM auth.users WHERE email = 'YOUR_BASIC_EMAIL';

-- Create Basic subscription (replace USER_ID)
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
Replace `YOUR_PREMIUM_EMAIL` with the value of `TEST_PREMIUM_EMAIL` from your `unit-test.env`.

```sql
-- Get user UUID (use your TEST_PREMIUM_EMAIL)
SELECT id FROM auth.users WHERE email = 'YOUR_PREMIUM_EMAIL';

-- Create Premium subscription (replace USER_ID)
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

### 3. Verify Entitlements

Ensure the following entitlements exist in the `entitlements` table:

```sql
SELECT * FROM entitlements WHERE entitlement_key IN ('Free', 'Basic', 'Premium');
```

Expected limits:

| Entitlement | max_programs | max_sessions_per_program | max_exercises_per_session | history_days |
|-------------|--------------|--------------------------|---------------------------|--------------|
| Free | 1 | 2 | 6 | 7 |
| Basic | 5 | 10 | 15 | 30 |
| Premium | NULL (unlimited) | 30 | 20 | 365 |

### 4. Complete SQL Script

Run the following SQL script after creating users via Supabase Auth:

```sql
-- Helper function to create a subscription
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

-- Create subscriptions (use emails from your unit-test.env)
SELECT create_test_subscription('YOUR_BASIC_EMAIL', 'Basic', 'active', NOW() + INTERVAL '30 days');
SELECT create_test_subscription('YOUR_PREMIUM_EMAIL', 'Premium', 'active', NOW() + INTERVAL '30 days');

-- Clean up helper function
DROP FUNCTION create_test_subscription(TEXT, TEXT, TEXT, TIMESTAMPTZ);
```

## Running Tests

### Environment Configuration

Create a `unit-test.env` file at the project root with all required variables:

Required variables:

| Variable | Description |
|---------|-------------|
| `TEST_BASE_URL` | Supabase project URL (test environment) |
| `TEST_ANON_KEY` | Supabase anon key (test environment) |
| `TEST_FREE_EMAIL` | Free plan test account email |
| `TEST_FREE_PASSWORD` | Free plan test account password |
| `TEST_BASIC_EMAIL` | Basic plan test account email |
| `TEST_BASIC_PASSWORD` | Basic plan test account password |
| `TEST_PREMIUM_EMAIL` | Premium plan test account email |
| `TEST_PREMIUM_PASSWORD` | Premium plan test account password |

The `unit-test.env` file is gitignored and must never be committed.

### Execute Tests

```bash
# All integration tests
flutter test test/integration/

# Specific plan tests
flutter test test/integration/free_plan_limits_test.dart
flutter test test/integration/basic_plan_limits_test.dart
flutter test test/integration/premium_plan_limits_test.dart

# Usage counters
flutter test test/integration/usage_counters_test.dart

# Single test
flutter test test/integration/free_plan_limits_test.dart --name "should create 1 program successfully"
```

## Test Structure

Tests are organized in separate files by scenario:

1. **free_plan_limits_test.dart**: Free plan limits (1 program, 2 sessions, 6 exercises)
2. **basic_plan_limits_test.dart**: Basic plan limits (5 programs, 10 sessions, 15 exercises)
3. **premium_plan_limits_test.dart**: Premium plan limits (unlimited programs, 30 sessions, 20 exercises)
4. **usage_counters_test.dart**: Usage counters

Each file uses the common setup defined in `test_setup.dart` to avoid code duplication.

## Test Fixtures

Test fixtures provide reusable test data and utilities:

- **test_accounts.dart**: Manages test user accounts (Free, Basic, Premium) with credentials from `unit-test.env`
- **test_programs.dart**: Factory methods for creating standardized test programs with various configurations (simple programs, multiple sessions, mixed session types, limit tests, etc.)

See `fixtures/README.md` for detailed documentation on using these fixtures in your tests.

## Cleanup

Each test automatically cleans up its data after execution via `CleanupHelper`.

For manual cleanup:

```sql
-- Clean data for a specific user
DELETE FROM programs WHERE user_id = 'USER_ID';
DELETE FROM subscription_limit_events WHERE user_id = 'USER_ID';
```

## Troubleshooting

### Error: "User not found"
- Verify accounts were created in Supabase Auth
- Verify `TEST_*_EMAIL` values in `unit-test.env` match the created accounts

### Error: "Missing TEST_* in unit-test.env"
- Ensure `unit-test.env` exists at the project root with all required variables
- Ensure all `TEST_*` variables are defined (see Environment Configuration above)

### Error: "Subscription not found"
- Verify subscriptions were created in the `subscriptions` table
- Ensure `entitlement_key` values match (Free, Basic, Premium)

### Error: "Entitlement not found"
- Verify entitlements exist in the `entitlements` table
- Check that limits are correctly configured

### Unexpected test failures
- Verify Supabase migrations are up to date
- Check that RPC functions are correctly deployed
- Check Supabase logs for database errors

## PostgreSQL Error Codes

Tests verify the following error codes in PostgreSQL messages:

- `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y` - Program limit reached
- `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y` - Sessions per program limit reached
- `LIMIT_EXCEEDED:MAX_EXERCISES_PER_SESSION:X/Y` - Exercises per session limit reached

These codes are in the `PostgrestException` message, not in a separate field.

## Important Notes

- ⚠️ **Never use these accounts in production**
- ⚠️ **Use a separate Supabase project for tests**
- ⚠️ **Tests modify the database - do not run on production**
- ✅ **Tests are idempotent thanks to automatic cleanup**
- ✅ **Each test is independent and can be run in isolation**
