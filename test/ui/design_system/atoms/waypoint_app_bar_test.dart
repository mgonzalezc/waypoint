import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/atoms/waypoint_app_bar.dart';

void main() {
  group('WaypointAppBar', () {
    group('when the user taps the leading button', () {
      testWidgets('then it pops the current route', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: const WaypointAppBar(),
                          body: const Text('detail'),
                        ),
                      ),
                    ),
                    child: const Text('go to detail'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('go to detail'));
        await tester.pumpAndSettle();
        expect(find.text('detail'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('go to detail'), findsOneWidget);
      });
    });
  });
}
