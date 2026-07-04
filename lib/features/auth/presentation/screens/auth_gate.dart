import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    // Run once after widget is mounted
    Future.microtask(() {
      final session = Supabase.instance.client.auth.currentSession;

      if (!mounted) return;

      if (session != null) {
        context.go('/main'); // ✅ GO TO MAIN LAYOUT
      } else {
        context.go('/login'); // ✅ GO TO LOGIN
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Just a loading screen
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}