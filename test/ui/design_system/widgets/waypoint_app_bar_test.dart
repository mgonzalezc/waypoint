import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waypoint/ui/design_system/widgets/waypoint_app_bar.dart';

void main() {
  group('WaypointAppBar', () {
    group('when the user taps the leading button', () {
      testWidgets('then it pops the current route', (tester) async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.push('/detail'),
                    child: const Text('go to detail'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/detail',
              builder: (context, state) => Scaffold(
                appBar: const WaypointAppBar(),
                body: const Text('detail'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

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
