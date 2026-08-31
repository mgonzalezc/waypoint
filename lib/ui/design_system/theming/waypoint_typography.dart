import 'package:flutter/material.dart';

import 'waypoint_colors.dart';

/// Archivo for headlines and numerals, Onest for everything else. Fonts are
/// bundled assets, not google_fonts runtime-fetch, so text renders
/// identically in golden tests and at runtime.
class WaypointTypography {
  const WaypointTypography._();

  static const String _headline = 'Archivo';
  static const String _body = 'Onest';

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: _headline,
      fontWeight: FontWeight.w900,
      fontSize: 42,
      letterSpacing: -0.2,
      height: 0.98,
      color: WaypointColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _headline,
      fontWeight: FontWeight.w900,
      fontSize: 22,
      letterSpacing: -0.2,
      color: WaypointColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _headline,
      fontWeight: FontWeight.w900,
      fontSize: 15,
      letterSpacing: -0.2,
      color: WaypointColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _body,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: WaypointColors.textSecondary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _body,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      color: WaypointColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _headline,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: WaypointColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: _body,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.6,
      color: WaypointColors.textSecondary,
    ),
  );
}
