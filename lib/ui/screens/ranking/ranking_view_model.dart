import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ranking/ranking_providers.dart';
import '../../../domain/ranking/ranking_result.dart';

typedef RankingQuery = ({String query, String locale});

class RankingViewModel extends AutoDisposeFamilyAsyncNotifier<RankingResult, RankingQuery> {
  @override
  Future<RankingResult> build(RankingQuery arg) {
    return ref.read(rankingRepositoryProvider).generateRanking(query: arg.query, locale: arg.locale);
  }
}

final rankingViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<RankingViewModel, RankingResult, RankingQuery>(RankingViewModel.new);
