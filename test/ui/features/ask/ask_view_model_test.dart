import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/data/analytics/analytics_providers.dart';
import 'package:waypoint/ui/features/ask/ask_view_model.dart';

import '../../../domain/analytics/analytics_service_mock.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AskViewModel', () {
    group('when the user submits a query', () {
      test('then it tracks submit_query with the query text and locale', () async {
        final analytics = AnalyticsServiceMock();
        final container = ProviderContainer(
          overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
        );
        addTearDown(container.dispose);
        await container.read(askViewModelProvider.future);

        container.read(askViewModelProvider.notifier).submitQuery(query: 'beaches in Portugal', locale: 'en');

        verify(
          () => analytics.track(
            'submit_query',
            properties: {'query_text': 'beaches in Portugal', 'locale': 'en'},
          ),
        ).called(1);
      });
    });

    group('when the user opens a past search from history', () {
      test('then it tracks open_history with that search\'s query text', () async {
        final analytics = AnalyticsServiceMock();
        final container = ProviderContainer(
          overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
        );
        addTearDown(container.dispose);
        await container.read(askViewModelProvider.future);

        container.read(askViewModelProvider.notifier).openHistoryEntry('beaches in Portugal');

        verify(
          () => analytics.track('open_history', properties: {'query_text': 'beaches in Portugal'}),
        ).called(1);
      });
    });

    group('when the user clears their history', () {
      test('then it tracks clear_history', () async {
        final analytics = AnalyticsServiceMock();
        final container = ProviderContainer(
          overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
        );
        addTearDown(container.dispose);
        await container.read(askViewModelProvider.future);

        await container.read(askViewModelProvider.notifier).clearHistory();

        verify(() => analytics.track('clear_history')).called(1);
      });
    });
  });
}
