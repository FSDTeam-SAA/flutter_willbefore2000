import 'package:flutter/cupertino.dart';

class AppFormIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const AppFormIcon({
    super.key,
    required this.assetPath,
    this.width = 20.0,
    this.height = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      assetPath: assetPath,
      width: width,
      height: height,
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 14.5,
        bottom: 14.5,
        right: 4.0,
      ),
    );
  }
}

class AppIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const AppIcon({
    super.key,
    required this.assetPath,
    this.height = 20.0,
    this.width = 20.0,
    this.padding = const EdgeInsets.only(
      left: 16.0,
      top: 14.5,
      bottom: 14.5,
      right: 4.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
