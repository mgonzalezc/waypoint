import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ask/view.dart';
import 'package:waypoint/ui/screens/ranking/view.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';

void main() {
  group('AskView', () {
    group('when there is no query typed yet', () {
      testWidgets('then the submit button is disabled', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: AskView()));

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('when the user types a query and submits', () {
      testWidgets('then it navigates to the ranking screen with that query', (tester) async {
        // RankingScreen starts fetching as soon as it's pushed, so the
        // repository still needs a stub here even though this test only
        // cares about the navigation, not the result.
        final repository = RankingRepositoryMock();
        final completer = Completer<RankingResult>();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
            child: const MaterialApp(home: AskView()),
          ),
        );

        await tester.enterText(find.byType(TextField), 'tapas en Roma');
        await tester.pump();
        await tester.tap(find.text('generar ranking'));
        // Two pumps: the pushed route is offstage for the frame it's
        // inserted on (part of the transition machinery), so it isn't
        // findable until the next frame.
        await tester.pump();
        await tester.pump();

        final screen = tester.widget<RankingScreen>(find.byType(RankingScreen));
        expect(screen.query, 'tapas en Roma');

        completer.complete(const RankingResult(query: 'tapas en Roma', isDegraded: false, items: []));
        await tester.pump();
      });
    });
  });
}
