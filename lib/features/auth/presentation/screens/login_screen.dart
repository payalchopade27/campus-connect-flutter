import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF7C3AED),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        size: 52,
                        color: Color(0xFF4F46E5),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'CampusConnect',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Connect • Collaborate • Build',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _InputField(label: 'Email'),

                      const SizedBox(height: 16),

                      _InputField(
                        label: 'Password',
                        isPassword: true,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            padding:
                            const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          context.go('/signup');
                        },
                        child: const Text(
                          "Don’t have an account? Sign up",
                          style: TextStyle(
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final bool isPassword;

  const _InputField({
    required this.label,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}