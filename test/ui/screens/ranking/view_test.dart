import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/api_failure.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ranking/view.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';
import '../../../support/pump_localized_app.dart';

Future<void> _pumpWithResult(WidgetTester tester, RankingResult result) async {
  final repository = RankingRepositoryMock();
  when(
    () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
  ).thenAnswer((_) async => result);

  await pumpLocalizedApp(
    tester,
    const RankingScreen(query: 'q', locale: 'es'),
    overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
  );
  // The mock repository resolves on the next microtask, so a single pump
  // is enough for the data state to render.
  await tester.pump();
}

Future<void> _pumpWithFailure(WidgetTester tester, ApiFailure failure) async {
  final repository = RankingRepositoryMock();
  when(
    () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
  ).thenThrow(failure);

  await pumpLocalizedApp(
    tester,
    const RankingScreen(query: 'q', locale: 'es'),
    overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
  );
  await tester.pump();
}

void main() {
  group('RankingScreen', () {
    group('when there are 10 good results', () {
      testWidgets('then the 10 items are shown, with no degraded badge', (tester) async {
        await _pumpWithResult(
          tester,
          RankingResult(
            query: 'q',
            isDegraded: false,
            items: List.generate(
              10,
              (i) => RankingItem(id: '$i', position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
            ),
          ),
        );

        expect(find.text('1. Place 0'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('10. Place 9'), 500);
        expect(find.text('10. Place 9'), findsOneWidget);
        expect(find.text('Fewer than 10 good candidates'), findsNothing);
      });
    });

    group('when there are fewer than 10 good results', () {
      testWidgets('then it shows fewer items and says so, never fills with noise', (tester) async {
        await _pumpWithResult(
          tester,
          const RankingResult(
            query: 'q',
            isDegraded: true,
            items: [RankingItem(id: '1', position: 1, name: 'Only Good One', reason: 'r', sources: [])],
          ),
        );

        expect(find.text('1. Only Good One'), findsOneWidget);
        expect(find.text('Fewer than 10 good candidates'), findsOneWidget);
      });
    });

    group('when there is no internet connection', () {
      testWidgets('then it shows a connection message, not the raw error', (tester) async {
        await _pumpWithFailure(tester, const NoConnection());

        expect(find.text('No internet connection. Check your network and try again.'), findsOneWidget);
      });
    });

    group('when the service is unavailable', () {
      testWidgets('then it shows a generic outage message, not the raw error', (tester) async {
        await _pumpWithFailure(tester, const ServiceUnavailable());

        expect(find.text('The service is temporarily unavailable. Try again in a moment.'), findsOneWidget);
      });
    });

    group('when something unexpected goes wrong', () {
      testWidgets('then it shows a generic message, never the internal reason', (tester) async {
        await _pumpWithFailure(tester, const UnexpectedFailure('OpenAI returned HTTP 400'));

        expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
        expect(find.textContaining('HTTP 400'), findsNothing);
      });
    });
  });
}
