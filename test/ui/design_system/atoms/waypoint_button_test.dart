import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/atoms/waypoint_button.dart';

void main() {
  group('WaypointButton', () {
    group('when the user taps it', () {
      testWidgets('then its action runs', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: WaypointButton(label: 'empezar', onPressed: () => tapped = true),
          ),
        );

        await tester.tap(find.text('empezar'));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('when there is no action to perform', () {
      testWidgets('then it is shown disabled', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WaypointButton(label: 'empezar', onPressed: null),
          ),
        );

        final button = tester.widget<TextButton>(find.byType(TextButton));
        expect(button.onPressed, isNull);
      });
    });
  });
}
