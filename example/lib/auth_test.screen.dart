import 'package:flutter/material.dart';
import 'package:trainer_backend/services/auth.service.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  // Using a dynamic email to avoid conflicts on multiple sign ups
  final TextEditingController _emailController =
      TextEditingController(text: 'user+${DateTime.now().millisecondsSinceEpoch}@test.com');
  final TextEditingController _passwordController = TextEditingController(text: 'Trainer2025@');
  final TextEditingController _usernameController = TextEditingController(text: 'testuser');
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AUTH TEST')),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // --- Standard Auth ---
            const Text('Standard Sign Up / Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username (for sign up)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _createUserWithEmail, child: const Text('Create User')),
            ElevatedButton(onPressed: _signInWithEmail, child: const Text('Sign In')),

            const Divider(height: 32),

            // --- Account Confirmation ---
            const Text('Account Confirmation (OTP)', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'Confirmation OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _confirmSignUp, child: const Text('Confirm Sign Up')),
            TextButton(onPressed: _resendConfirmationCode, child: const Text('Resend Confirmation Code')),

            const Divider(height: 32),

            // --- Password Reset ---
            const Text('Password Reset (OTP)', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: _sendPasswordResetCode, child: const Text('Send Password Reset Code')),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'Reset OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _verifyPasswordResetCode, child: const Text('Verify Reset Code')),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            ElevatedButton(onPressed: _updatePassword, child: const Text('Update Password (after verifying code)')),

            const Divider(height: 32),

            // --- Social Auth ---
            const Text('Social Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: _signInWithGoogle, child: const Text('Sign in with Google')),
            ElevatedButton(onPressed: _signInWithApple, child: const Text('Sign in with Apple')),
          ],
        ),
      );

  // --- Methods ---

  Future<void> _createUserWithEmail() async {
    try {
      await AuthService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      );
      _showSnackbar('Confirmation code sent to ${_emailController.text}');
    } catch (e) {
      _showSnackbar('Account creation failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _signInWithEmail() async {
    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // On success, StreamBuilder will navigate to home.
    } catch (e) {
      _showSnackbar('Sign in failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _confirmSignUp() async {
    try {
      await AuthService.confirmSignUp(
        email: _emailController.text,
        token: _otpController.text,
      );
      _otpController.clear();
      // On success, StreamBuilder will navigate to home.
    } catch (e) {
      _showSnackbar('Sign up confirmation failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _resendConfirmationCode() async {
    try {
      await AuthService.resendConfirmationCode(email: _emailController.text);
      _showSnackbar('Confirmation code re-sent to ${_emailController.text}');
    } catch (e) {
      _showSnackbar('Failed to resend code: ${e.toString()}', isError: true);
    }
  }

  Future<void> _sendPasswordResetCode() async {
    try {
      await AuthService.sendPasswordResetCode(email: _emailController.text);
      _showSnackbar('Password reset code sent to ${_emailController.text}');
    } catch (e) {
      _showSnackbar('Failed to send reset code: ${e.toString()}', isError: true);
    }
  }

  Future<void> _verifyPasswordResetCode() async {
    try {
      await AuthService.verifyPasswordResetCode(
        email: _emailController.text,
        token: _otpController.text,
      );
      _otpController.clear();
      _showSnackbar('Code verified. You are now signed in. Please set a new password.');
    } catch (e) {
      _showSnackbar('Failed to verify reset code: ${e.toString()}', isError: true);
    }
  }

  Future<void> _updatePassword() async {
    try {
      await AuthService.updatePassword(newPassword: _newPasswordController.text);
      _newPasswordController.clear();
      _showSnackbar('Password updated successfully.');
    } catch (e) {
      _showSnackbar('Failed to update password: ${e.toString()}', isError: true);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      _showSnackbar('Sign in with Google failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> _signInWithApple() async {
    try {
      await AuthService.signInWithApple();
    } catch (e) {
      _showSnackbar('Sign in with Apple failed: ${e.toString()}', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
    }
  }
}
