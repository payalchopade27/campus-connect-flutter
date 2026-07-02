import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:campus_connect/features/splash/presentation/screens/splash_screen.dart';
import 'package:campus_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:campus_connect/features/auth/presentation/screens/signup_screen.dart';
import 'package:campus_connect/features/home/presentation/screens/home_screen.dart';
import 'package:campus_connect/core/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wmuacobwtcvfjffpdqrx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtdWFjb2J3dGN2ZmpmZnBkcXJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5MTg2MDUsImV4cCI6MjA5ODQ5NDYwNX0.-en2uUR2KvGT1YppbnnXp6cSfYqTG7n93Ri8gP3IMiY',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen(
          (AuthState data) {
        final event = data.event;
        final session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/home', (route) => false);
        }

        if (event == AuthChangeEvent.signedOut) {
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}