import '../ranking/ranking_result.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.result,
    required this.queries,
    required this.firstSearchedAt,
    required this.lastSearchedAt,
  });

  final RankingResult result;

  final List<String> queries;

  final DateTime firstSearchedAt;
  final DateTime lastSearchedAt;
}
