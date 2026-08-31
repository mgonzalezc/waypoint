import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/atoms/waypoint_scaffold.dart';

void main() {
  group('WaypointScaffold', () {
    group('when it builds', () {
      testWidgets('then it wraps its body in exactly one Scaffold', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: WaypointScaffold(body: Text('content'))),
        );

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('content'), findsOneWidget);
      });
    });
  });
}
