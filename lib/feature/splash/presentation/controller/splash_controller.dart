import 'package:flutter/material.dart';
import 'package:smilestreats/feature/auth/presentation/screens/login_screen.dart';

class SplashController {
  void navigateAfterDelay(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
    );
  }
}
