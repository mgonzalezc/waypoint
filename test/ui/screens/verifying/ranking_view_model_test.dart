import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/api_failure.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/verifying/ranking_view_model.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RankingViewModel', () {
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
          rankingViewModelProvider((query: 'q', locale: 'es')).future,
        );

        expect(state.items, hasLength(10));
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
          container.read(rankingViewModelProvider((query: 'q', locale: 'es')).future),
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

        final query = rankingViewModelProvider((query: 'q', locale: 'es'));
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
