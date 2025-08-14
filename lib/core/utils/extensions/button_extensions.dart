import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    String? prefixIconPath, // SVG path for prefix icon
    String? suffixIconPath, // SVG path for suffix icon
    double iconSize = 24.0, // Size for both icons
    double iconGap = 8.0, // Space between icon and text
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (prefixIconPath != null)
                        Padding(
                          padding: EdgeInsets.only(right: iconGap),
                          child: SvgPicture.asset(
                            prefixIconPath,
                            width: iconSize,
                            height: iconSize,
                            colorFilter: ColorFilter.mode(
                              textColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      Text(
                        text,
                        style: AppTextStyles.text16w600().copyWith(
                          color: textColor,
                        ),
                      ),
                      if (suffixIconPath != null)
                        Padding(
                          padding: EdgeInsets.only(left: iconGap),
                          child: SvgPicture.asset(
                            suffixIconPath,
                            width: iconSize,
                            height: iconSize,
                            colorFilter: ColorFilter.mode(
                              textColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
