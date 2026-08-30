import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/api_failure.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_repository.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ask/ranking_view_model.dart';

class _StubRankingRepository implements RankingRepository {
  _StubRankingRepository.succeeding(this._result) : _failure = null;
  _StubRankingRepository.failing(this._failure) : _result = null;

  final RankingResult? _result;
  final ApiFailure? _failure;

  @override
  Future<RankingResult> generateRanking({required String query, required String locale}) async {
    final failure = _failure;
    if (failure != null) throw failure;
    final result = _result;
    if (result == null) throw const UnexpectedFailure('test stub has neither result nor failure');
    return result;
  }
}

void main() {
  group('RankingViewModel', () {
    group('when the user taps submit and 10 good results come back', () {
      test('then the 10 items are in the resulting state', () async {
        final result = RankingResult(
          query: 'q',
          isDegraded: false,
          items: List.generate(
            10,
            (i) => RankingItem(id: '$i', position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
          ),
        );
        final container = ProviderContainer(
          overrides: [
            rankingRepositoryProvider.overrideWithValue(_StubRankingRepository.succeeding(result)),
          ],
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
        final container = ProviderContainer(
          overrides: [
            rankingRepositoryProvider.overrideWithValue(
              _StubRankingRepository.failing(const NoConnection()),
            ),
          ],
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
  });
}
