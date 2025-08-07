import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.bgColor,
    primaryColor: AppColors.primaryLaurel,
    colorScheme: ColorScheme.light(primary: AppColors.primaryLaurel),

    textTheme: GoogleFonts.notoSansKrTextTheme(),
    appBarTheme: AppBarTheme(backgroundColor: AppColors.white),
  );
}
