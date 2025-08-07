import 'package:flutter/material.dart';
import 'package:smilestreats/core/constants/app_icons_const.dart';
import 'package:smilestreats/feature/splash/presentation/controller/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController _controller = SplashController();

  @override
  void initState() {
    super.initState();
    _controller.navigateAfterDelay(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(child: Image.asset(AssetsPath.appLogo)),
      ),
    );
  }
}
