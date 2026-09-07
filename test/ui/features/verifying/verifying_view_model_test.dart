import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/data/analytics/analytics_providers.dart';
import 'package:waypoint/data/history/history_providers.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/api_failure.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/features/verifying/verifying_view_model.dart';

import '../../../domain/analytics/analytics_service_mock.dart';
import '../../../domain/ranking/ranking_repository_mock.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VerifyingViewModel', () {
    group('when the screen is opened for a query and 10 good results come back', () {
      test('then the 10 items are in the resulting state', () async {
        final repository = RankingRepositoryMock();
        final result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: List.generate(
            10,
            (i) => RankingItem(id: '$i', position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
          ),
        );
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) async => result);

        final container = ProviderContainer(
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final state = await container.read(
          verifyingViewModelProvider((query: 'q', locale: 'es')).future,
        );

        expect(state.items, hasLength(10));
      });
    });

    group('when the search succeeds with at least one item', () {
      test('then the search is recorded to history', () async {
        final repository = RankingRepositoryMock();
        const result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'Place', reason: 'r', sources: [])],
        );
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) async => result);

        final container = ProviderContainer(
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        await container.read(verifyingViewModelProvider((query: 'q', locale: 'es')).future);

        final history = await container.read(historyEntriesProvider.future);
        expect(history, hasLength(1));
        expect(history.single.query, 'q');
      });

      test('then it tracks render_ranking with the item count, degraded flag, and latency', () async {
        final repository = RankingRepositoryMock();
        const result = RankingResult(
          query: 'q',
          isDegraded: true,
          items: [RankingItem(id: '1', position: 1, name: 'Place', reason: 'r', sources: [])],
        );
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) async => result);
        final analytics = AnalyticsServiceMock();

        final container = ProviderContainer(
          overrides: [
            rankingRepositoryProvider.overrideWithValue(repository),
            analyticsServiceProvider.overrideWithValue(analytics),
          ],
        );
        addTearDown(container.dispose);

        await container.read(verifyingViewModelProvider((query: 'q', locale: 'es')).future);

        final properties = verify(
          () => analytics.track('render_ranking', properties: captureAny(named: 'properties')),
        ).captured.single as Map<String, Object?>;
        expect(properties['item_count'], 1);
        expect(properties['degraded'], true);
        expect(properties['latency_ms'], isA<int>());
      });
    });

    group('when the search fails', () {
      test('then the state carries the error instead of crashing', () async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenThrow(const NoConnection());

        final container = ProviderContainer(
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        await expectLater(
          container.read(verifyingViewModelProvider((query: 'q', locale: 'es')).future),
          throwsA(isA<NoConnection>()),
        );
      });
    });

    group('when the same query is opened twice at once', () {
      test('then the repository is only called once', () async {
        final repository = RankingRepositoryMock();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer(
          (_) async => const RankingResult(query: 'q', isDegraded: false, items: []),
        );

        final container = ProviderContainer(
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final query = verifyingViewModelProvider((query: 'q', locale: 'es'));
        await Future.wait([
          container.read(query.future),
          container.read(query.future),
        ]);

        verify(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).called(1);
      });
    });
  });
}
