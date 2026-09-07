import '../ranking/ranking_result.dart';
import 'history_entry.dart';

abstract interface class HistoryRepository {
  Future<List<HistoryEntry>> loadHistory();

  Future<void> recordSearch({required RankingResult result});

  Future<void> clearHistory();
}
