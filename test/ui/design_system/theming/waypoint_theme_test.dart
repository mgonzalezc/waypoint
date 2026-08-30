import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/theming/waypoint_colors.dart';
import 'package:waypoint/ui/design_system/theming/waypoint_theme.dart';

void main() {
  group('buildWaypointTheme', () {
    group('when the app builds its theme', () {
      test('then it is dark with the amber accent', () {
        final theme = buildWaypointTheme();

        expect(theme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, WaypointColors.amber);
      });

      test('then headlines use Archivo, body text uses Onest, and data labels use Space Mono', () {
        final theme = buildWaypointTheme();

        expect(theme.textTheme.headlineMedium?.fontFamily, 'Archivo');
        expect(theme.textTheme.bodyLarge?.fontFamily, 'Onest');
        expect(theme.textTheme.labelLarge?.fontFamily, 'Space Mono');
      });
    });
  });
}
