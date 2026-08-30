import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ask/view.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';

void main() {
  group('AskView', () {
    group('when there is no query typed yet', () {
      testWidgets('then the submit button is disabled', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [rankingRepositoryProvider.overrideWithValue(RankingRepositoryMock())],
            child: const MaterialApp(home: AskView()),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('when the user types a query and submits', () {
      testWidgets('then the result is shown', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer(
          (_) async => const RankingResult(
            query: 'tapas en Roma',
            isDegraded: false,
            items: [
              RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'closest to the venue', sources: []),
            ],
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
            child: const MaterialApp(home: AskView()),
          ),
        );

        await tester.enterText(find.byType(TextField), 'tapas en Roma');
        await tester.pump();

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);

        await tester.tap(find.text('generar ranking'));
        // A single pump is enough — the fake repository resolves
        // synchronously, no indeterminate animation is left running by the
        // time the data state renders, so pumpAndSettle would also work
        // but isn't needed.
        await tester.pump();

        expect(find.text('1. La Ristra'), findsOneWidget);
      });
    });

    group('when the user presses enter again while a search is still in flight', () {
      testWidgets('then it does not fire a second request', (tester) async {
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
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        verify(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).called(1);

        completer.complete(
          const RankingResult(query: 'tapas en Roma', isDegraded: false, items: []),
        );
        await tester.pump();
      });
    });
  });
}
