import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/features/detail/detail_screen.dart';
import 'package:waypoint/ui/features/ranking/ranking_screen.dart';
import 'package:waypoint/ui/navigation/app_router.dart';
import 'package:waypoint/ui/navigation/app_routes.dart';

import '../../../support/pump_localized_app.dart';
import '../../../support/pump_routed_app.dart';

void main() {
  group('RankingScreen', () {
    group('when there are 10 good results', () {
      testWidgets('then the 10 items are shown, with no degraded note', (tester) async {
        final result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: List.generate(
            10,
            (i) => RankingItem(position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
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
          items: [RankingItem(position: 1, name: 'Only Good One', reason: 'r', sources: [])],
        );

        await pumpLocalizedApp(tester, const RankingScreen(result: result));

        expect(find.text('Only Good One'), findsOneWidget);
        expect(find.text('fewer than 10 good candidates this time'), findsOneWidget);
      });
    });

    group('when there are no results at all', () {
      testWidgets('then it says so, instead of an unexplained blank list', (tester) async {
        const result = RankingResult(query: 'q', isDegraded: true, items: []);

        await pumpLocalizedApp(tester, const RankingScreen(result: result));

        expect(find.text("Couldn't find any good matches for that."), findsOneWidget);
        expect(find.text('fewer than 10 good candidates this time'), findsNothing);
      });
    });

    group('when the user taps back', () {
      testWidgets('then it returns to the previous screen, even with a single result', (tester) async {
        const result = RankingResult(
          query: 'q',
          isDegraded: true,
          items: [RankingItem(position: 1, name: 'Only Good One', reason: 'r', sources: [])],
        );

        await pumpRoutedApp(
          tester,
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.pushNamed(AppRoutes.rankingName, extra: result),
              child: const Text('open'),
            ),
          ),
          additionalRoutes: [rankingRoute],
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

    group('when an item\'s reason is long', () {
      testWidgets('then it is limited to 2 lines with an ellipsis', (tester) async {
        const item = RankingItem(
          position: 1,
          name: 'Only Good One',
          reason: 'A long-winded description of why this place made the list, spanning several lines.',
          sources: [],
        );
        const result = RankingResult(query: 'q', isDegraded: false, items: [item]);

        await pumpLocalizedApp(tester, const RankingScreen(result: result));

        final text = tester.widget<Text>(find.text(item.reason));
        expect(text.maxLines, 2);
        expect(text.overflow, TextOverflow.ellipsis);
      });
    });

    group('when the user taps an item', () {
      testWidgets('then it navigates to that item\'s detail screen', (tester) async {
        const item = RankingItem(position: 1, name: 'Only Good One', reason: 'r', sources: []);
        const result = RankingResult(query: 'q', isDegraded: false, items: [item]);

        await pumpRoutedApp(tester, const RankingScreen(result: result), additionalRoutes: [detailRoute]);

        await tester.tap(find.text('Only Good One'));
        await tester.pumpAndSettle();

        final screen = tester.widget<DetailScreen>(find.byType(DetailScreen));
        expect(screen.item.name, 'Only Good One');
      });
    });
  });
}
