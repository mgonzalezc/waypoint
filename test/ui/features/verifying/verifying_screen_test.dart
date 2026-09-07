import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/data/history/shared_preferences_history_repository.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/api_failure.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/features/ranking/ranking_screen.dart';
import 'package:waypoint/ui/features/verifying/verifying_screen.dart';
import 'package:waypoint/ui/navigation/app_router.dart';
import 'package:waypoint/ui/navigation/app_routes.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';
import '../../../support/pump_localized_app.dart';
import '../../../support/pump_routed_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

      testWidgets('then a back button is still shown', (tester) async {
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

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('when the search succeeds', () {
      testWidgets('then it navigates to the ranking screen with that result', (tester) async {
        final repository = RankingRepositoryMock();
        final completer = Completer<RankingResult>();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) => completer.future);

        await pumpRoutedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
          additionalRoutes: [rankingRoute],
        );
        await tester.pump();

        const result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: [])],
        );
        completer.complete(result);
        await tester.pump();
        await tester.pump();

        final screen = tester.widget<RankingScreen>(find.byType(RankingScreen));
        expect(screen.result.items.single.name, 'La Ristra');
      });
    });

    group('when the search succeeds with no results at all', () {
      testWidgets('then nothing is recorded to history', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) async => const RankingResult(query: 'q', isDegraded: true, items: []));

        await pumpRoutedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
          additionalRoutes: [rankingRoute],
        );
        await tester.pump();
        await tester.pump();

        final historyRepository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        expect(await historyRepository.loadHistory(), isEmpty);
      });
    });

    group('when there is no internet connection', () {
      testWidgets('then it shows a connection message, not the raw error', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenThrow(const NoConnection());

        await pumpLocalizedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        expect(find.text('No internet connection. Check your network and try again.'), findsOneWidget);
      });
    });

    group('when the service is unavailable', () {
      testWidgets('then it shows a generic outage message, not the raw error', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenThrow(const ServiceUnavailable());

        await pumpLocalizedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        expect(find.text('The service is temporarily unavailable. Try again in a moment.'), findsOneWidget);
      });
    });

    group('when something unexpected goes wrong', () {
      testWidgets('then it shows a generic message, never the internal reason', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenThrow(const UnexpectedFailure('OpenAI returned HTTP 400'));

        await pumpLocalizedApp(
          tester,
          const VerifyingScreen(query: 'q', locale: 'en'),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
        expect(find.textContaining('HTTP 400'), findsNothing);
      });
    });

    group('when the user taps back after a failed search', () {
      testWidgets('then it returns to the previous screen', (tester) async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenThrow(const NoConnection());

        await pumpRoutedApp(
          tester,
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.pushNamed(
                AppRoutes.verifyingName,
                extra: (query: 'q', locale: 'en'),
              ),
              child: const Text('open'),
            ),
          ),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
          additionalRoutes: [verifyingRoute],
        );

        await tester.tap(find.text('open'));
        // Two pumps: the pushed route is offstage for the frame it's
        // inserted on (part of the transition machinery), so it isn't
        // findable until the next frame.
        await tester.pump();
        await tester.pump();
        expect(find.text('No internet connection. Check your network and try again.'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(VerifyingScreen), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });
    });
  });
}
