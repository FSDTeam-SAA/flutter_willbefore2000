import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum IconType { svg, image }

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
      type: IconType.image,
    );
  }
}

class AppIcon extends StatelessWidget {
  final String assetPath;
  final IconType type;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppIcon({
    super.key,
    required this.assetPath,
    required this.type,
    this.width = 24.0,
    this.height = 24.0,
    this.padding = const EdgeInsets.all(8),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    switch (type) {
      case IconType.svg:
        iconWidget = SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          theme: SvgTheme(
            currentColor:
                color ?? Colors.black, // Default color if none provided
          ),
        );
        break;
      case IconType.image:
        iconWidget = Image.asset(
          assetPath,
          width: width,
          height: height,
          color: color,
        );
        break;
    }

    return Padding(padding: padding, child: iconWidget);
  }
}
