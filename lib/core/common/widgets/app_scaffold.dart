import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? drawer;
  final bool removePadding;
  final Widget? floatingActionButton;
  final Widget? endDrawer;
  final bool safeArea;

  const AppScaffold({
    super.key,
    this.appBar,
    this.drawer,
    required this.body,
    this.removePadding = false,
    this.floatingActionButton,
    this.endDrawer,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: removePadding ? 0 : 18),
      child: body,
    );

    // Wrap with SafeArea if enabled
    if (safeArea) {
      content = SafeArea(
        child: content,
      );
    }

    return Scaffold(
      drawer: drawer,
      appBar: appBar,
      endDrawer: endDrawer,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}