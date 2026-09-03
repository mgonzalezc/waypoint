import 'package:flutter/material.dart';

import 'waypoint_colors.dart';
import 'waypoint_typography.dart';

ThemeData buildWaypointTheme() {
  final colorScheme = const ColorScheme.light().copyWith(
    surface: WaypointColors.background,
    surfaceTint: Colors.transparent,
    primary: WaypointColors.amber,
    onPrimary: WaypointColors.onAmber,
    error: WaypointColors.error,
    outline: WaypointColors.divider,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: WaypointColors.background,
    colorScheme: colorScheme,
    textTheme: WaypointTypography.textTheme,
    dividerColor: WaypointColors.divider,
  );
}
