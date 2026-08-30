import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ranking/ranking_providers.dart';
import '../../../domain/ranking/ranking_result.dart';

class RankingViewModel extends AsyncNotifier<RankingResult?> {
  bool _isSubmitting = false;

  @override
  Future<RankingResult?> build() async => null;

  Future<void> submitQuery({required String query, required String locale}) async {
    if (_isSubmitting) return;

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    _isSubmitting = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(rankingRepositoryProvider).generateRanking(query: trimmedQuery, locale: locale),
    );
    _isSubmitting = false;
  }
}

final rankingViewModelProvider =
    AsyncNotifierProvider<RankingViewModel, RankingResult?>(RankingViewModel.new);
