import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/history/history_providers.dart';
import '../../../data/ranking/ranking_providers.dart';
import '../../../domain/ranking/ranking_result.dart';
import 'verifying_analytics.dart';

typedef VerifyingQuery = ({String query, String locale});

class VerifyingViewModel extends AutoDisposeFamilyAsyncNotifier<RankingResult, VerifyingQuery> {
  @override
  Future<RankingResult> build(VerifyingQuery arg) async {
    final stopwatch = Stopwatch()..start();

    final result = await ref
        .read(rankingRepositoryProvider)
        .generateRanking(query: arg.query, locale: arg.locale);

    if (result.items.isNotEmpty) {
      final historyRepository = await ref.read(historyRepositoryProvider.future);
      await historyRepository.recordSearch(query: arg.query, result: result);
      ref.invalidate(historyEntriesProvider);
    }

    ref
        .read(verifyingAnalyticsProvider)
        .logRenderRanking(
          itemCount: result.items.length,
          degraded: result.isDegraded,
          latencyMs: stopwatch.elapsedMilliseconds,
        );

    return result;
  }
}

final verifyingViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<VerifyingViewModel, RankingResult, VerifyingQuery>(VerifyingViewModel.new);
