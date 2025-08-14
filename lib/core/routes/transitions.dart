// transitions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Collection of custom page transitions that work with GoRouter
class AppTransitions {
  /// Creates a fade transition
  static CustomTransitionPage fadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Creates a slide transition (right to left by default)
  static CustomTransitionPage slideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Creates a scale transition
  static CustomTransitionPage scaleTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.fastOutSlowIn,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: begin, end: end).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        );
      },
    );
  }

  /// Creates a combined fade and slide transition
  static CustomTransitionPage fadeSlideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(0.0, 0.1),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: begin, end: end).animate(
              CurvedAnimation(parent: animation, curve: curve),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Helper function for default page transitions
CustomTransitionPage buildPageWithDefaultTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return AppTransitions.fadeSlideTransition(
    context: context,
    state: state,
    child: child,
  );
}