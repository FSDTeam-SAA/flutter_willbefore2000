import 'package:flutter/material.dart';
import 'package:flutx_core/core/theme/text/app_text_style.dart';

import '../../constants/app_colors.dart';

extension ButtonStyleExtensions on BuildContext {
  Widget primaryButton({
    required VoidCallback onPressed,
    required String text,
    double? width,
    double? height,
    bool isLoading = false,
    Color backgroundColor = AppColors.primaryLaurel,
    Color textColor = AppColors.white,
    double borderRadius = 6.0,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyles.text16w500().copyWith(
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget secondaryButton({
    required VoidCallback onPressed,
    required String text,
    double? width,
    double? height,
    bool isLoading = false,
    Color borderColor = AppColors.primaryLaurel,
    Color textColor = AppColors.primaryLaurel,
    Color? backgroundColor,
    double borderRadius = 6.0,
    double borderWidth = 1.0,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyles.text16w500().copyWith(
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
