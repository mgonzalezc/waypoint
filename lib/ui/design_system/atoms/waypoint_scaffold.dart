import 'package:flutter/material.dart';

class WaypointScaffold extends StatelessWidget {
  const WaypointScaffold({
    required this.body,
    this.appBar,
    this.extendBodyBehindAppBar = false,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: SafeArea(top: appBar == null, child: body),
    );
  }
}
