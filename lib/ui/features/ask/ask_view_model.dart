import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/history/history_providers.dart';
import '../../../domain/history/history_entry.dart';
import 'ask_analytics.dart';

class AskViewModel extends AutoDisposeAsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() {
    return ref.watch(historyEntriesProvider.future);
  }

  void submitQuery({required String query, required String locale}) {
    ref.read(askAnalyticsProvider).logSubmitQuery(query: query, locale: locale);
  }

  void openHistoryEntry(String query) {
    ref.read(askAnalyticsProvider).logOpenHistory(query);
  }

  Future<void> clearHistory() async {
    final repository = await ref.read(historyRepositoryProvider.future);
    await repository.clearHistory();
    ref.invalidate(historyEntriesProvider);
    ref.read(askAnalyticsProvider).logClearHistory();
  }
}

final askViewModelProvider = AsyncNotifierProvider.autoDispose<AskViewModel, List<HistoryEntry>>(
  AskViewModel.new,
);

final askHistoryProvider = Provider.autoDispose<List<HistoryEntry>>((ref) {
  return ref.watch(askViewModelProvider).valueOrNull ?? const [];
});
