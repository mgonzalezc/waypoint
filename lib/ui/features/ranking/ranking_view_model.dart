import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/ranking/ranking_item.dart';
import 'ranking_analytics.dart';

class RankingViewModel extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  void openItem(RankingItem item) {
    ref.read(rankingAnalyticsProvider).logOpenDetail(item.position);
  }
}

final rankingViewModelProvider = NotifierProvider.autoDispose<RankingViewModel, void>(
  RankingViewModel.new,
);
