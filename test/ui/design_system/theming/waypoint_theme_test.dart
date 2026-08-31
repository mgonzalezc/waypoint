import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/theming/waypoint_colors.dart';
import 'package:waypoint/ui/design_system/theming/waypoint_theme.dart';

void main() {
  group('buildWaypointTheme', () {
    group('when the app builds its theme', () {
      test('then it is light with the amber accent', () {
        final theme = buildWaypointTheme();

        expect(theme.brightness, Brightness.light);
        expect(theme.colorScheme.primary, WaypointColors.amber);
      });

      test('then headlines use Archivo and body text uses Onest', () {
        final theme = buildWaypointTheme();

        expect(theme.textTheme.headlineMedium?.fontFamily, 'Archivo');
        expect(theme.textTheme.bodyLarge?.fontFamily, 'Onest');
      });
    });
  });
}
