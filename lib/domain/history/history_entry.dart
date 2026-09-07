import '../ranking/ranking_result.dart';

class HistoryEntry {
  const HistoryEntry({required this.result, required this.searchedAt});

  final RankingResult result;
  final DateTime searchedAt;
}
