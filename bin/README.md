# User Creation Script

Standalone Dart script to create users in Supabase Auth with all required fields properly initialized.

## Prerequisites

1. The RPC function `create_test_user` must be deployed in Supabase (via migration `20251109161006_create_test_user_function.sql`)
2. Have your Supabase project URL and Anon Key

## Installation

The script has its own `pubspec.yaml` and is completely standalone. To install dependencies:

```bash
cd bin/
dart pub get
```

## Usage

From the `bin/` directory:

```bash
dart run create_user.dart
```

The script will prompt for:
1. Your Supabase project URL
2. Supabase Anon Key (hidden during input)
3. User email
4. Password (hidden during input)
5. Username

## Features

- ✅ Creates the user in `auth.users` with all fields properly initialized
- ✅ Automatically creates the associated profile in `public.profiles`
- ✅ All string fields are initialized with empty strings (not NULL)
- ✅ Email automatically confirmed
- ✅ Metadata correctly configured

## Example Output

```
=== Supabase User Creation Script ===

Enter Supabase URL: https://your-project.supabase.co
Enter Supabase Anon Key: ********

Enter email: test-user@trainer.app
Enter password: ********
Enter username: test_user

Creating user...

✅ User created successfully!
   ID: 123e4567-e89b-12d3-a456-426614174000
   Email: test-user@trainer.app
   Username: test_user
   Created at: 2025-11-09 15:10:00.000Z

✅ Profile created automatically by trigger.
```

## Notes

- The script uses the RPC function `create_test_user` which is secured with `SECURITY DEFINER`
- Password is hashed with bcrypt via `pgcrypto`
- Profile is created automatically by the `handle_new_user()` trigger

## Security

✅ **This script is safe to version in Git** because:
- No secrets are hardcoded in the code
- All credentials are requested at runtime
- The Anon Key is hidden during input

⚠️ **Best practices**:
- Use this script only to create test/development users
- Never share your Supabase credentials
- Limit repository access to authorized personnel
- The RPC function `create_test_user` uses `SECURITY DEFINER` - ensure it is properly secured in your database
