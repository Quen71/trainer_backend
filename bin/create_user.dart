#!/usr/bin/env dart

// Script to create a new user in Supabase Auth.
//
// This script creates a user directly in the auth.users table with all
// required fields properly initialized, and creates the associated profile.
//
// Usage:
//   cd bin/
//   dart pub get
//   dart run create_user.dart
//
// The script will prompt for:
//   - Supabase URL
//   - Supabase Anon Key
//   - Email
//   - Password
//   - Username
//
// Prerequisites:
//   - Run `dart pub get` in the bin/ directory first
import 'dart:io';
import 'package:supabase/supabase.dart';

/// Reads a line from stdin with a prompt.
String _readLine(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync() ?? '';
}

/// Reads a password from stdin (hidden input).
String _readPassword(String prompt) {
  stdout.write(prompt);
  stdin.echoMode = false;
  final String password = stdin.readLineSync() ?? '';
  stdin.echoMode = true;
  stdout.writeln();
  return password;
}

/// Main function.
Future<void> main(List<String> args) async {
  try {
    stdout.writeln('=== Supabase User Creation Script ===\n');

    // Get Supabase configuration
    final String baseUrl = _readLine('Enter Supabase URL: ').trim();
    if (baseUrl.isEmpty) {
      stderr.writeln('Supabase URL cannot be empty.');
      exit(1);
    }

    final String anonKey = _readPassword('Enter Supabase Anon Key: ');
    if (anonKey.isEmpty) {
      stderr.writeln('Supabase Anon Key cannot be empty.');
      exit(1);
    }

    // Create Supabase client directly (without Flutter)
    final SupabaseClient client = SupabaseClient(
      baseUrl,
      anonKey,
    );

    // Get user input
    stdout.writeln();
    final String email = _readLine('Enter email: ').trim();
    if (email.isEmpty) {
      stderr.writeln('Email cannot be empty.');
      exit(1);
    }

    final String password = _readPassword('Enter password: ');
    if (password.isEmpty) {
      stderr.writeln('Password cannot be empty.');
      exit(1);
    }

    final String username = _readLine('Enter username: ').trim();
    if (username.isEmpty) {
      stderr.writeln('Username cannot be empty.');
      exit(1);
    }

    stdout.writeln('\nCreating user...');

    // Create user using the RPC function
    final dynamic result = await client.rpc(
      'create_test_user',
      params: <String, dynamic>{
        'p_email': email,
        'p_password': password,
        'p_username': username,
      },
    );

    if (result == null) {
      throw Exception('Failed to create user: No data returned.');
    }

    final Map<String, dynamic> userData = result as Map<String, dynamic>;

    stdout
      ..writeln('\n✅ User created successfully!')
      ..writeln('   ID: ${userData['id']}')
      ..writeln('   Email: ${userData['email']}')
      ..writeln('   Username: ${userData['username']}')
      ..writeln('   Created at: ${userData['created_at']}')
      ..writeln('\n✅ Profile created automatically by trigger.');

    // Cleanup
    client.dispose();
  } catch (e, stackTrace) {
    stderr
      ..writeln('Error: $e')
      ..writeln('Stack trace: $stackTrace');
    exit(1);
  }
}
