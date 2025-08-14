import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AppColors.borderColor.withAlpha((0.2 * 255).toInt()),
        spreadRadius: 2,
        blurRadius: 10,
        offset: const Offset(2, 4),
      ),
    ],
  );
}
