import 'package:flutter/material.dart';

class WaypointScaffold extends StatelessWidget {
  const WaypointScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: body));
  }
}
