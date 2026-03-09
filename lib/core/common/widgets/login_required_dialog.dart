import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smilestreatsapp/core/constants/app_colors.dart';
import 'package:smilestreatsapp/core/routes/route_endpoint.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LoginRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Login Required',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textAppBlack,
        ),
      ),
      content: Text(
        'You need to login first to access this feature.',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondaryColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Go back
          child: Text(
            'Not Now',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            context.pushNamed(RoutePaths.login); // Go to login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLaurel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
