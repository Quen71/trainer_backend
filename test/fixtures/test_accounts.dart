/// Test account fixtures for integration tests.
///
/// These accounts must be created manually in Supabase before running tests.
/// See test/README.md for setup instructions.
class TestAccounts {
  TestAccounts._();

  /// User account with Free subscription (limits: 1 program, 2 sessions, 6 exercises).
  static const TestAccount freeUser = TestAccount(
    email: 'test-free@trainer.app',
    password: 'Trainer2025@',
    userId: '', // Will be filled after sign-in
    plan: 'Free',
  );

  /// User account with Basic subscription (limits: 5 programs, 10 sessions, 15 exercises).
  static const TestAccount basicUser = TestAccount(
    email: 'test-basic@trainer.app',
    password: 'Trainer2025@',
    userId: '',
    plan: 'Basic',
  );

  /// User account with Premium subscription (limits: unlimited programs, 30 sessions, 20 exercises).
  static const TestAccount premiumUser = TestAccount(
    email: 'test-premium@trainer.app',
    password: 'Trainer2025@',
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
