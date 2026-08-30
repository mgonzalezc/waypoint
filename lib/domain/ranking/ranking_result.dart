import 'ranking_item.dart';

class RankingResult {
  const RankingResult({
    required this.query,
    required this.items,
    required this.isDegraded,
  });

  final String query;
  final List<RankingItem> items;

  final bool isDegraded;
}
