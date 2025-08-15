
import 'package:flutter/material.dart';
import 'shimmer_loader.dart';

class ShimmerPlaceholders {
  // Rectangle placeholder
  static Widget rectangle({
    double width = double.infinity,
    double height = double.infinity,
    double borderRadius = 0,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Circle placeholder
  static Widget circle({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  // Text line placeholder
  static Widget textLine({
    double width = double.infinity,
    double height = 12,
    double borderRadius = 4,
  }) {
    return rectangle(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  // Custom child with shimmer
  static Widget custom({
    required Widget child,
    bool isLoading = true,
  }) {
    return ShimmerLoader(
      isLoading: isLoading,
      child: child,
    );
  }
}