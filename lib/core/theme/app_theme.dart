import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.bgColor,
    primaryColor: AppColors.primaryLaurel,
    colorScheme: ColorScheme.light(primary: AppColors.primaryLaurel),

    appBarTheme: AppBarTheme(backgroundColor: AppColors.white),
  );
}
