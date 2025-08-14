// main_nav_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';

import '../provider/bottom_nav_provider.dart';
import '../widgets/custom_bottom_navbar_widget.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainNavScreen({super.key, required this.child});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    ref.read(bottomNavIndexProvider.notifier).state = index;
    
    switch (index) {
      case 0:
        context.go(RouteEndpoint.home);
        break;
      case 1:
        context.go(RouteEndpoint.search);
        break;
      case 2:
        context.go(RouteEndpoint.cart);
        break;
      case 3:
        context.go(RouteEndpoint.profile);
        break;
    }
  }
}