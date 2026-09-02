import '../ranking/ranking_result.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.result,
    required this.query,
    required this.searchedAt,
  });

  final RankingResult result;
  final String query;
  final DateTime searchedAt;
}
