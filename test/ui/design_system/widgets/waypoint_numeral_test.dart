import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/widgets/waypoint_numeral.dart';

void main() {
  group('WaypointNumeral', () {
    group('when the value is a single digit', () {
      testWidgets('then it is padded to two digits', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: WaypointNumeral(value: 1)));

        expect(find.text('01'), findsOneWidget);
      });
    });

    group('when the value is already two digits', () {
      testWidgets('then it is shown as-is', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: WaypointNumeral(value: 10)));

        expect(find.text('10'), findsOneWidget);
      });
    });
  });
}
