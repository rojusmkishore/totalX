import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:total_x/viewmodels/auth_viewmodel.dart';
import 'package:total_x/widgets/google_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/images/login_illustration.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Welcome to TotalX',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to your account to continue and manage users effortlessly.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              GoogleSignInButton(
                isLoading: authViewModel.isLoading,
                onPressed: () async {
                  try {
                    await authViewModel.signInWithGoogle();
                    // Navigation will be handled in main.dart or via a listener
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
              ),
              const Spacer(),
              Center(
                child: Text(
                  'By signing in, you agree to our Terms & Conditions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
