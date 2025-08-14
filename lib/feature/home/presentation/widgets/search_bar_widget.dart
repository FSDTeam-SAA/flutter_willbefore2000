import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? hintText;

  const SearchBarWidget({super.key, this.onTap, this.hintText});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: isTablet ? 56 : 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: isTablet ? 20 : 16),
            Icon(
              Icons.search,
              color: Colors.grey[400],
              size: isTablet ? 24 : 20,
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                hintText ?? 'Search products...',
                style: GoogleFonts.notoSansKr(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[500],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: isTablet ? 36 : 32,
              height: isTablet ? 36 : 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLaurel.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
              ),
              child: Icon(
                Icons.tune,
                color: AppColors.primaryLaurel,
                size: isTablet ? 18 : 16,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
          ],
        ),
      ),
    );
  }
}