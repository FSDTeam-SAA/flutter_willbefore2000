import 'package:flutter/material.dart';

import '../../../../core/common/widgets/app_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons_const.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  const CustomBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          _buildNavItem(0, 'Home', AssetsPath.home, currentIndex, onTap),
          _buildNavItem(1, 'Search', AssetsPath.search, currentIndex, onTap),
          _buildNavItem(2, 'Cart', AssetsPath.cart, currentIndex, onTap),
          _buildNavItem(3, 'Profile', AssetsPath.profile, currentIndex, onTap),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    String iconPath,
    int currentIndex,
    Function(int)? onTap,
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
          AppIcon(
            assetPath: iconPath,
            type: IconType.svg,
            color: isSelected
                ? AppColors.iconSelectedColor
                : AppColors.iconDeselectedColor,
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
