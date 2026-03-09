import 'package:flutter/material.dart';
import 'package:smilestreatsapp/core/constants/app_icons_const.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double width;

  const AppLogo({super.key, this.height = 120, this.width = 120});

  @override
  Widget build(BuildContext context) {
    // return 
    // Center(
    //   child: Container(
    //     width: 60,
    //     height: 60,
    //     decoration: BoxDecoration(
    //       color: Colors.blue,
    //       borderRadius: BorderRadius.circular(12),
    //     ),
    //     child: const Center(
    //       child: Text(
    //         'YOUR\nLOGO',
    //         style: TextStyle(
    //           color: Colors.white,
    //           fontSize: 10,
    //           fontWeight: FontWeight.bold,
    //         ),
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   ),
    // );
    return Image.asset(
      AssetsPath.appLogo,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}
