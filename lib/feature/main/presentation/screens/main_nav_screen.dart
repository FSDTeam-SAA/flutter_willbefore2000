// main_nav_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';

import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screen/profile_screen.dart';
import '../../../search/presentation/screens/advance_search_screen.dart';
import '../provider/bottom_nav_provider.dart';
import '../widgets/custom_bottom_navbar_widget.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainNavScreen({super.key, required this.child});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    ref.listen(bottomNavIndexProvider, (previous, next) {
      if (previous != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });


    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeScreen(),
          AdvancedSearchScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    ref.read(bottomNavIndexProvider.notifier).state = index;
    _navigateToIndex(index, context);
  }

  void _navigateToIndex(int index, BuildContext context) {
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
