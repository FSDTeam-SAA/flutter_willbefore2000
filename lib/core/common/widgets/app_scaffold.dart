import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? drawer;
  final bool removePadding;
  final Widget? floatingActionButton;
  final Widget ? endDrawer;

  const AppScaffold({
    super.key,
    this.appBar,
    this.drawer,
    required this.body,
    this.removePadding = false,
    this.floatingActionButton,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: appBar,
      endDrawer: endDrawer,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: removePadding ? 0 : 18),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
