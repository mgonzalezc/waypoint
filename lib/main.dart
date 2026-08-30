import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/design_system/theming/waypoint_theme.dart';
import 'ui/screens/ask/view.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Uncaught Flutter error: ${details.exception}');
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: WaypointApp())),
    (error, stack) => debugPrint('Uncaught zone error: $error'),
  );
}

class WaypointApp extends StatelessWidget {
  const WaypointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waypoint',
      debugShowCheckedModeBanner: false,
      theme: buildWaypointTheme(),
      home: const AskView(),
    );
  }
}
