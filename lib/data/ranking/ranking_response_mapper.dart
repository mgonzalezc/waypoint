import '../../domain/api_failure.dart';
import '../../domain/ranking/ranking_item.dart';
import '../../domain/ranking/source_citation.dart';

List<RankingItem> parseRankingItems(Map<String, dynamic> json) {
  final rawItems = json['items'];
  if (rawItems is! List) {
    throw const UnexpectedFailure('OpenAI response is missing "items"');
  }

  final items = <RankingItem>[];
  for (var index = 0; index < rawItems.length; index++) {
    final raw = rawItems[index];
    if (raw is! Map<String, dynamic>) {
      throw const UnexpectedFailure('OpenAI response item is not an object');
    }
    items.add(_itemFromJson(raw, position: index + 1));
  }

  return items;
}

RankingItem _itemFromJson(Map<String, dynamic> json, {required int position}) {
  final name = json['name'];
  final reason = json['reason'];
  if (name is! String || reason is! String) {
    throw const UnexpectedFailure('OpenAI response item is missing name/reason');
  }

  return RankingItem(
    id: '$position-${name.hashCode}',
    position: position,
    name: name,
    reason: reason,
    sources: _sourcesFromJson(json['sources']),
  );
}

List<SourceCitation> _sourcesFromJson(Object? rawSources) {
  if (rawSources is! List) return const [];

  final sources = <SourceCitation>[];
  for (final rawSource in rawSources) {
    if (rawSource is! Map<String, dynamic>) continue;
    final title = rawSource['title'];
    final url = rawSource['url'];
    if (title is String && url is String) {
      sources.add(SourceCitation(title: title, url: url));
    }
  }
  return sources;
}
