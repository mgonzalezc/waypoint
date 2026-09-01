import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/history/history_providers.dart';
import '../../../data/ranking/ranking_providers.dart';
import '../../../domain/ranking/ranking_result.dart';

typedef RankingQuery = ({String query, String locale});

class RankingViewModel extends AutoDisposeFamilyAsyncNotifier<RankingResult, RankingQuery> {
  @override
  Future<RankingResult> build(RankingQuery arg) async {
    final result = await ref
        .read(rankingRepositoryProvider)
        .generateRanking(query: arg.query, locale: arg.locale);

    if (result.items.isNotEmpty) {
      final historyRepository = await ref.read(historyRepositoryProvider.future);
      await historyRepository.recordSearch(query: arg.query, result: result);
      ref.invalidate(historyEntriesProvider);
    }

    return result;
  }
}

final rankingViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<RankingViewModel, RankingResult, RankingQuery>(RankingViewModel.new);
