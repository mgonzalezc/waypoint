import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ranking/ranking_providers.dart';
import '../../../domain/ranking/ranking_result.dart';

class RankingViewModel extends AsyncNotifier<RankingResult?> {
  @override
  Future<RankingResult?> build() async => null;

  Future<void> submitQuery({required String query, required String locale}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(rankingRepositoryProvider).generateRanking(query: query, locale: locale),
    );
  }
}

final rankingViewModelProvider =
    AsyncNotifierProvider<RankingViewModel, RankingResult?>(RankingViewModel.new);
