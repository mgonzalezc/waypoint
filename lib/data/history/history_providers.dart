import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/history/history_entry.dart';
import '../../domain/history/history_repository.dart';
import 'shared_preferences_history_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

final historyRepositoryProvider = FutureProvider<HistoryRepository>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesHistoryRepository(preferences);
});

final historyEntriesProvider = FutureProvider.autoDispose<List<HistoryEntry>>((ref) async {
  final repository = await ref.watch(historyRepositoryProvider.future);
  return repository.loadHistory();
});
