import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ranking/view.dart';
import 'package:waypoint/ui/screens/verifying/view.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';
import '../../../support/pump_localized_app.dart';

void main() {
  group('VerifyingScreen', () {
    group('when the search is still in flight', () {
      testWidgets('then it shows a rotating phrase', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) => Completer<RankingResult>().future);

        await pumpLocalizedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        expect(find.text('Scouring the globe...'), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Taste-testing restaurants...'), findsOneWidget);
      });
    });

    group('when the search finishes', () {
      testWidgets('then it navigates to the ranking screen', (tester) async {
        final repository = RankingRepositoryMock();
        final completer = Completer<RankingResult>();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) => completer.future);

        await pumpLocalizedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        completer.complete(const RankingResult(query: 'q', isDegraded: false, items: []));
        await tester.pump();
        await tester.pump();

        expect(find.byType(RankingScreen), findsOneWidget);
      });
    });
  });
}
