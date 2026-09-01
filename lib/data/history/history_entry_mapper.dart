import '../../domain/history/history_entry.dart';
import '../../domain/ranking/ranking_item.dart';
import '../../domain/ranking/ranking_result.dart';
import '../../domain/ranking/source_citation.dart';

Map<String, dynamic> historyEntryToJson(HistoryEntry entry) => {
  'result': _resultToJson(entry.result),
  'queries': entry.queries,
  'firstSearchedAt': entry.firstSearchedAt.toIso8601String(),
  'lastSearchedAt': entry.lastSearchedAt.toIso8601String(),
};

HistoryEntry historyEntryFromJson(Map<String, dynamic> json) => HistoryEntry(
  result: _resultFromJson(json['result'] as Map<String, dynamic>),
  queries: (json['queries'] as List).cast<String>(),
  firstSearchedAt: DateTime.parse(json['firstSearchedAt'] as String),
  lastSearchedAt: DateTime.parse(json['lastSearchedAt'] as String),
);

Map<String, dynamic> _resultToJson(RankingResult result) => {
  'query': result.query,
  'isDegraded': result.isDegraded,
  'items': result.items.map(_itemToJson).toList(),
};

RankingResult _resultFromJson(Map<String, dynamic> json) => RankingResult(
  query: json['query'] as String,
  isDegraded: json['isDegraded'] as bool,
  items: (json['items'] as List).map((raw) => _itemFromJson(raw as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _itemToJson(RankingItem item) => {
  'id': item.id,
  'position': item.position,
  'name': item.name,
  'reason': item.reason,
  'sources': item.sources.map(_sourceToJson).toList(),
};

RankingItem _itemFromJson(Map<String, dynamic> json) => RankingItem(
  id: json['id'] as String,
  position: json['position'] as int,
  name: json['name'] as String,
  reason: json['reason'] as String,
  sources: (json['sources'] as List).map((raw) => _sourceFromJson(raw as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _sourceToJson(SourceCitation source) => {'title': source.title, 'url': source.url};

SourceCitation _sourceFromJson(Map<String, dynamic> json) =>
    SourceCitation(title: json['title'] as String, url: json['url'] as String);
