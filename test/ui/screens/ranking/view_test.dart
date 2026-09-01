import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/detail/view.dart';
import 'package:waypoint/ui/screens/ranking/view.dart';

import '../../../support/pump_localized_app.dart';

void main() {
  group('RankingScreen', () {
    group('when there are 10 good results', () {
      testWidgets('then the 10 items are shown, with no degraded note', (tester) async {
        final result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: List.generate(
            10,
            (i) => RankingItem(id: '$i', position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
          ),
        );

        await pumpLocalizedApp(tester, RankingScreen(result: result));

        expect(find.text('Place 0'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Place 9'), 500);
        expect(find.text('Place 9'), findsOneWidget);
        expect(find.text('fewer than 10 good candidates this time'), findsNothing);
      });
    });

    group('when there are fewer than 10 good results', () {
      testWidgets('then it shows fewer items and says so, never fills with noise', (tester) async {
        const result = RankingResult(
          query: 'q',
          isDegraded: true,
          items: [RankingItem(id: '1', position: 1, name: 'Only Good One', reason: 'r', sources: [])],
        );

        await pumpLocalizedApp(tester, const RankingScreen(result: result));

        expect(find.text('Only Good One'), findsOneWidget);
        expect(find.text('fewer than 10 good candidates this time'), findsOneWidget);
      });
    });

    group('when the user taps back', () {
      testWidgets('then it returns to the previous screen, even with a single result', (tester) async {
        const result = RankingResult(
          query: 'q',
          isDegraded: true,
          items: [RankingItem(id: '1', position: 1, name: 'Only Good One', reason: 'r', sources: [])],
        );

        await pumpLocalizedApp(
          tester,
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RankingScreen(result: result)),
              ),
              child: const Text('open'),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byType(RankingScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(RankingScreen), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });
    });

    group('when the user taps an item', () {
      testWidgets('then it navigates to that item\'s detail screen', (tester) async {
        const item = RankingItem(id: '1', position: 1, name: 'Only Good One', reason: 'r', sources: []);
        const result = RankingResult(query: 'q', isDegraded: false, items: [item]);

        await pumpLocalizedApp(tester, const RankingScreen(result: result));

        await tester.tap(find.text('Only Good One'));
        await tester.pumpAndSettle();

        final screen = tester.widget<DetailScreen>(find.byType(DetailScreen));
        expect(screen.item.id, '1');
      });
    });
  });
}
