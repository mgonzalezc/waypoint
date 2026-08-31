import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ranking/view.dart';

import '../../../support/pump_localized_app.dart';

void main() {
  group('RankingScreen', () {
    group('when there are 10 good results', () {
      testWidgets('then the 10 items are shown, with no degraded badge', (tester) async {
        final result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: List.generate(
            10,
            (i) => RankingItem(id: '$i', position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
          ),
        );

        await pumpLocalizedApp(tester, RankingScreen(result: result));

        expect(find.text('1. Place 0'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('10. Place 9'), 500);
        expect(find.text('10. Place 9'), findsOneWidget);
        expect(find.text('Fewer than 10 good candidates'), findsNothing);
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

        expect(find.text('1. Only Good One'), findsOneWidget);
        expect(find.text('Fewer than 10 good candidates'), findsOneWidget);
      });
    });
  });
}
