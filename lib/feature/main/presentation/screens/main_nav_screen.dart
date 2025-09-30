// main_nav_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';
import '../widgets/custom_bottom_navbar_widget.dart';
import '../provider/bottom_nav_provider.dart';

class MainNavScreen extends ConsumerWidget {
  final Widget child;
  const MainNavScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the current tab based on the route
    // final String currentPath = GoRouterState.of(context).uri.path;
    // final int currentIndex = _getCurrentIndex(currentPath);

    return Scaffold(
      body: child, // Use the child from ShellRoute
      bottomNavigationBar: CustomBottomNavBar(
        // currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context, ref),
      ),
    );
  }

  // int _getCurrentIndex(String path) {
  //   if (path.startsWith(RoutePaths.home)) return 0;
  //   if (path.startsWith(RoutePaths.search)) return 1;
  //   if (path.startsWith(RoutePaths.cart)) return 2;
  //   if (path.startsWith(RoutePaths.profile)) return 3;
  //   return 0; // Default to Home
  // }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) {
    // Update Riverpod state
    ref.read(bottomNavIndexProvider.notifier).state = index;

    // Navigate using go_router
    switch (index) {
      case 0:
        context.go(RoutePaths.home);
        break;
      case 1:
        context.go(RoutePaths.search);
        break;
      case 2:
        context.go(RoutePaths.cart);
        break;
      case 3:
        context.go(RoutePaths.profile);
        break;
    }
  }
}
