import 'ranking_item.dart';

class RankingResult {
  const RankingResult({
    required this.query,
    required this.items,
    required this.degraded,
  });

  final String query;
  final List<RankingItem> items;

  final bool degraded;
}
