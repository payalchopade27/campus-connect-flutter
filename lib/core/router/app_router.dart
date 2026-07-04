import 'package:campus_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:campus_connect/features/auth/presentation/screens/signup_screen.dart';
import 'package:campus_connect/features/auth/presentation/screens/auth_gate.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_connect/features/home/presentation/screens/main_layout.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainLayout(),
    ),
  ],
);