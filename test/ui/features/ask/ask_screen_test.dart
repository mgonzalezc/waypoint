import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/data/history/shared_preferences_history_repository.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/features/ask/ask_screen.dart';
import 'package:waypoint/ui/features/ranking/ranking_screen.dart';
import 'package:waypoint/ui/features/verifying/verifying_screen.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';
import '../../../support/pump_localized_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AskScreen', () {
    group('when there is no query typed yet', () {
      testWidgets('then the submit button is disabled', (tester) async {
        await pumpLocalizedApp(tester, const AskScreen());

        final button = tester.widget<TextButton>(find.ancestor(
          of: find.text('Generate ranking'),
          matching: find.byType(TextButton),
        ));
        expect(button.onPressed, isNull);
      });
    });

    group('when the user types a query and submits', () {
      testWidgets('then it navigates to the verifying screen with that query', (tester) async {
        // VerifyingScreen starts fetching as soon as it's pushed, so the
        // repository still needs a stub here even though this test only
        // cares about the navigation, not the result.
        final repository = RankingRepositoryMock();
        final completer = Completer<RankingResult>();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) => completer.future);

        await pumpLocalizedApp(
          tester,
          const AskScreen(),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );

        await tester.enterText(find.byType(TextField), 'tapas en Roma');
        await tester.pump();
        await tester.tap(find.text('Generate ranking'));
        // Two pumps: the pushed route is offstage for the frame it's
        // inserted on (part of the transition machinery), so it isn't
        // findable until the next frame.
        await tester.pump();
        await tester.pump();

        final screen = tester.widget<VerifyingScreen>(find.byType(VerifyingScreen));
        expect(screen.query, 'tapas en Roma');
      });
    });

    group('when there is no search history yet', () {
      testWidgets('then it renders with just the field and the button', (tester) async {
        await pumpLocalizedApp(tester, const AskScreen());
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Generate ranking'), findsOneWidget);
      });
    });

    group('when there is a past search', () {
      testWidgets('then it is shown inline below the search field', (tester) async {
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        const result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: [])],
        );
        await repository.recordSearch(query: 'tapas en Sevilla', result: result);

        await pumpLocalizedApp(tester, const AskScreen());
        await tester.pump();

        expect(find.text('tapas en Sevilla'), findsOneWidget);
        expect(find.text('La Ristra'), findsOneWidget);
      });
    });

    group('when the user taps a past search', () {
      testWidgets('then it navigates straight to that saved result, no re-fetch', (tester) async {
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        const result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: [])],
        );
        await repository.recordSearch(query: 'tapas en Sevilla', result: result);

        await pumpLocalizedApp(tester, const AskScreen());
        await tester.pump();

        await tester.tap(find.text('tapas en Sevilla'));
        await tester.pump();
        await tester.pump();

        final screen = tester.widget<RankingScreen>(find.byType(RankingScreen));
        expect(screen.result.items.single.name, 'La Ristra');
      });
    });

    group('when the user clears history and confirms', () {
      testWidgets('then the history disappears', (tester) async {
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        const result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: [])],
        );
        await repository.recordSearch(query: 'tapas en Sevilla', result: result);

        await pumpLocalizedApp(tester, const AskScreen());
        await tester.pump();

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear').last);
        await tester.pumpAndSettle();

        expect(find.text('tapas en Sevilla'), findsNothing);
      });
    });

    group('when the user clears history but cancels', () {
      testWidgets('then the history stays', (tester) async {
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        const result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: [])],
        );
        await repository.recordSearch(query: 'tapas en Sevilla', result: result);

        await pumpLocalizedApp(tester, const AskScreen());
        await tester.pump();

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('tapas en Sevilla'), findsOneWidget);
      });
    });
  });
}
