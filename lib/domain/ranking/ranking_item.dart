import 'source_citation.dart';

class RankingItem {
  const RankingItem({
    required this.id,
    required this.position,
    required this.name,
    required this.reason,
    required this.sources,
  });

  final String id;
  final int position;
  final String name;
  final String reason;
  final List<SourceCitation> sources;
}
