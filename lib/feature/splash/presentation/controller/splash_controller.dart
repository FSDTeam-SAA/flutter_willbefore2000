import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';

class SplashController {
  void navigateAfterDelay(BuildContext context) async {
    // Wait for 2 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Access the Riverpod container to read authGuardProvider
    final container = ProviderScope.containerOf(context);
    final authGuard = container.read(authGuardProvider);

    // Wait for auth initialization if not yet initialized
    if (!authGuard.isInitialized) {
      // Optionally, you can use a listener or Future to wait for initialization
      // For simplicity, we'll assume initialization is fast enough
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Re-read authGuard after ensuring initialization
    final updatedAuthGuard = container.read(authGuardProvider);

    // Navigate based on authentication status
    if (updatedAuthGuard.isAuthenticated) {
      context.go(RoutePaths.home);
    } else {
      context.go(RoutePaths.login);
    }
  }
}
