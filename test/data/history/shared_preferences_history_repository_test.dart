import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/data/history/shared_preferences_history_repository.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/domain/ranking/source_citation.dart';

const _result = RankingResult(
  query: 'q',
  isDegraded: false,
  items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: [])],
);

void main() {
  group('SharedPreferencesHistoryRepository', () {
    group('when there is no history yet', () {
      test('then loadHistory returns an empty list', () async {
        SharedPreferences.setMockInitialValues({});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());

        expect(await repository.loadHistory(), isEmpty);
      });
    });

    group('when a search is recorded', () {
      test('then it appears in history with that query', () async {
        SharedPreferences.setMockInitialValues({});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());

        await repository.recordSearch(query: 'tapas en Sevilla', result: _result);
        final history = await repository.loadHistory();

        expect(history, hasLength(1));
        expect(history.single.queries, ['tapas en Sevilla']);
        expect(history.single.result.items.single.name, 'La Ristra');
      });
    });

    group('when a different query lands on the same result', () {
      test('then it updates the existing entry instead of duplicating it', () async {
        SharedPreferences.setMockInitialValues({});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());

        await repository.recordSearch(query: 'tapas en Sevilla', result: _result);
        final firstSearchedAt = (await repository.loadHistory()).single.firstSearchedAt;

        await repository.recordSearch(query: 'mejores bares de tapas en Sevilla', result: _result);
        final history = await repository.loadHistory();

        expect(history, hasLength(1));
        expect(history.single.queries, ['tapas en Sevilla', 'mejores bares de tapas en Sevilla']);
        expect(history.single.firstSearchedAt, firstSearchedAt);
      });
    });

    group('when the same query is recorded again', () {
      test('then it does not duplicate that query in the entry', () async {
        SharedPreferences.setMockInitialValues({});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());

        await repository.recordSearch(query: 'tapas en Sevilla', result: _result);
        await repository.recordSearch(query: 'tapas en Sevilla', result: _result);
        final history = await repository.loadHistory();

        expect(history.single.queries, ['tapas en Sevilla']);
      });
    });

    group('when an item has sources', () {
      test('then the sources survive a save and reload', () async {
        SharedPreferences.setMockInitialValues({});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        const withSources = RankingResult(
          query: 'q',
          isDegraded: false,
          items: [
            RankingItem(
              id: '1',
              position: 1,
              name: 'La Ristra',
              reason: 'r',
              sources: [SourceCitation(title: 'Time Out Seville', url: 'https://timeout.com/la-ristra')],
            ),
          ],
        );

        await repository.recordSearch(query: 'q', result: withSources);
        final history = await repository.loadHistory();

        final source = history.single.result.items.single.sources.single;
        expect(source.title, 'Time Out Seville');
        expect(source.url, 'https://timeout.com/la-ristra');
      });
    });

    group('when the history is cleared', () {
      test('then loadHistory returns an empty list afterwards', () async {
        SharedPreferences.setMockInitialValues({});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());
        await repository.recordSearch(query: 'tapas en Sevilla', result: _result);

        await repository.clearHistory();

        expect(await repository.loadHistory(), isEmpty);
      });
    });

    group('when the stored data is corrupted', () {
      test('then loadHistory falls back to an empty list instead of crashing', () async {
        SharedPreferences.setMockInitialValues({'history_entries': 'not valid json'});
        final repository = SharedPreferencesHistoryRepository(await SharedPreferences.getInstance());

        expect(await repository.loadHistory(), isEmpty);
      });
    });
  });
}
