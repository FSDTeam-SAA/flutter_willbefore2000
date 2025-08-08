import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smilestreats/feature/main/presentation/widgets/custom_bottom_navbar_widget.dart';

import '../provider/bottom_nav_provider.dart';

final List<Widget> _screens = [
  Center(child: Text('Home Screen')),
  Center(child: Text('Search Screen')),
  Center(child: Text('Cart Screen')),
  Center(child: Text('Profile Screen')),
];

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex,),
    );
  }
}

// "35k"
// wrk : 29K