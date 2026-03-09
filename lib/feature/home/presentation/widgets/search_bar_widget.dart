import 'package:flutter/material.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_endpoint.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? hintText;

  const HomeSearchBarWidget({super.key, this.onTap, this.hintText});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: () {
        try {
          if (onTap != null) {
            onTap!();
          } else {
            context.push(RoutePaths.homeSearch);
          }
        } catch (e) {
          DPrint.error("Navigate to search fail : $e");
        }
      },
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
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[500],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
