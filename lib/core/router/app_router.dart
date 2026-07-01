import 'package:campus_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:campus_connect/features/auth/presentation/screens/signup_screen.dart';
import 'package:campus_connect/features/home/presentation/screens/home_screen.dart';
import 'package:campus_connect/features/splash/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    /// Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    /// Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// Signup
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    /// Home
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);