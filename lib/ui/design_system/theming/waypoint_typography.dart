import 'package:flutter/material.dart';

import 'waypoint_colors.dart';

/// Archivo for headlines, Onest for body, Space Mono for data/ticket-style
/// numbers. Fonts are bundled assets, not google_fonts runtime-fetch, so
/// text renders identically in golden tests and at runtime.
class WaypointTypography {
  const WaypointTypography._();

  static const String _headline = 'Archivo';
  static const String _body = 'Onest';
  static const String _mono = 'Space Mono';

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: _headline,
      fontWeight: FontWeight.w900,
      fontSize: 40,
      color: WaypointColors.textPrimary,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontFamily: _headline,
      fontWeight: FontWeight.w900,
      fontSize: 28,
      color: WaypointColors.textPrimary,
      height: 1.15,
    ),
    titleMedium: TextStyle(
      fontFamily: _body,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: WaypointColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _body,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: WaypointColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _body,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: WaypointColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _mono,
      fontWeight: FontWeight.w700,
      fontSize: 13,
      letterSpacing: 0.5,
      color: WaypointColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: _mono,
      fontWeight: FontWeight.w400,
      fontSize: 11,
      letterSpacing: 0.5,
      color: WaypointColors.textSecondary,
    ),
  );
}
