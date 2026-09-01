import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/history/history_providers.dart';
import '../../../domain/history/history_entry.dart';

class AskViewModel extends AutoDisposeAsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() {
    return ref.watch(historyEntriesProvider.future);
  }

  Future<void> clearHistory() async {
    final repository = await ref.read(historyRepositoryProvider.future);
    await repository.clearHistory();
    ref.invalidate(historyEntriesProvider);
  }
}

final askViewModelProvider = AsyncNotifierProvider.autoDispose<AskViewModel, List<HistoryEntry>>(
  AskViewModel.new,
);

final askHistoryProvider = Provider.autoDispose<List<HistoryEntry>>((ref) {
  return ref.watch(askViewModelProvider).valueOrNull ?? const [];
});
