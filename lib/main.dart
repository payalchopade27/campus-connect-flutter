import 'package:campus_connect/core/constants/app_constants.dart';
import 'package:campus_connect/core/router/app_router.dart';
import 'package:campus_connect/core/theme/app_theme.dart';
import 'package:campus_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CampusConnectApp(),
    ),
  );
}

class CampusConnectApp extends ConsumerWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: themeMode,

      routerConfig: appRouter,
    );
  }
}