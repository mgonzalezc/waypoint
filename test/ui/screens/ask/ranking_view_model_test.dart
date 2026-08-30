import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/api_failure.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ask/ranking_view_model.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';

void main() {
  group('RankingViewModel', () {
    group('when the user taps submit and 10 good results come back', () {
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

        await container.read(rankingViewModelProvider.notifier).submitQuery(
          query: 'q',
          locale: 'es',
        );

        final state = container.read(rankingViewModelProvider);
        expect(state.value?.items, hasLength(10));
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

        await container.read(rankingViewModelProvider.notifier).submitQuery(
          query: 'q',
          locale: 'es',
        );

        final state = container.read(rankingViewModelProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<NoConnection>());
      });
    });

    group('when the query is blank', () {
      test('then no search is triggered', () async {
        final repository = RankingRepositoryMock();
        final container = ProviderContainer(
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        await container.read(rankingViewModelProvider.notifier).submitQuery(
          query: '   ',
          locale: 'es',
        );

        final state = container.read(rankingViewModelProvider);
        expect(state.value, isNull);
        verifyNever(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        );
      });
    });
  });
}
