import 'package:flutter/material.dart';

import 'waypoint_colors.dart';
import 'waypoint_typography.dart';

ThemeData buildWaypointTheme() {
  final colorScheme = const ColorScheme.dark().copyWith(
    surface: WaypointColors.background,
    primary: WaypointColors.amber,
    onPrimary: WaypointColors.onAmber,
    secondary: WaypointColors.trustBlue,
    error: WaypointColors.error,
    outline: WaypointColors.divider,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: WaypointColors.background,
    colorScheme: colorScheme,
    textTheme: WaypointTypography.textTheme,
    dividerColor: WaypointColors.divider,
  );
}
