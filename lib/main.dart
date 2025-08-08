import 'package:flutter/material.dart';
import 'package:flutx_core/core/routes/config/navigation_config.dart';
import 'package:smilestreats/core/theme/app_theme.dart';
import 'package:smilestreats/feature/splash/presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.light,

      navigatorKey: NavigationConfig.navigatorKey,

      home: SplashScreen(),
    );
  }
}
