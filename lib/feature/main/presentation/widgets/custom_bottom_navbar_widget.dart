import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smilestreats/feature/cart/presentation/providers/cart_provider.dart';

import '../../../../core/common/widgets/app_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons_const.dart';
import '../provider/bottom_nav_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  // final int currentIndex;
  final Function(int)? onTap;
  const CustomBottomNavBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final cartItemCount = ref.watch(
      cartProvider.select((state) => state.totalItems),
    );

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'Home', AssetsPath.home, currentIndex, onTap, 0),
            _buildNavItem(
              1,
              'Search',
              AssetsPath.search,
              currentIndex,
              onTap,
              0,
            ),
            _buildNavItem(
              2,
              'Cart',
              AssetsPath.cart,
              currentIndex,
              onTap,
              cartItemCount,
            ),
            _buildNavItem(
              3,
              'Profile',
              AssetsPath.profile,
              currentIndex,
              onTap,
              0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    String iconPath,
    int currentIndex,
    Function(int)? onTap,
    int itemCount,
  ) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          onTap(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppIcon(
                assetPath: iconPath,
                type: IconType.svg,
                color: isSelected
                    ? AppColors.iconSelectedColor
                    : AppColors.iconDeselectedColor,
              ),
              if (index == 2 && itemCount > 0)
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLaurel,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? AppColors.iconSelectedColor
                  : AppColors.iconDeselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
