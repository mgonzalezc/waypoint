import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'ui/design_system/theming/waypoint_theme.dart';
import 'ui/screens/ask/ask_screen.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Crashlytics / Sentry: FirebaseCrashlytics.instance.recordFlutterFatalError(details)
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: WaypointApp())),
    (error, stack) {
      debugPrint('Uncaught zone error: $error');
      debugPrintStack(stackTrace: stack);
      // Crashlytics / Sentry: FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)
    },
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AskScreen(),
    );
  }
}
