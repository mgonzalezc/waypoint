import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/history/history_entry.dart';
import '../../domain/history/history_repository.dart';
import '../../domain/ranking/ranking_result.dart';
import 'history_entry_mapper.dart';

class SharedPreferencesHistoryRepository implements HistoryRepository {
  SharedPreferencesHistoryRepository(this._preferences);

  final SharedPreferences _preferences;

  static const _storageKey = 'history_entries';

  @override
  Future<List<HistoryEntry>> loadHistory() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map<String, dynamic>>().map(historyEntryFromJson).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> recordSearch({required RankingResult result}) async {
    final entries = await loadHistory();
    final recorded = HistoryEntry(result: result, searchedAt: DateTime.now());

    final updated = [recorded, ...entries];
    await _preferences.setString(_storageKey, jsonEncode(updated.map(historyEntryToJson).toList()));
  }

  @override
  Future<void> clearHistory() => _preferences.remove(_storageKey);
}
