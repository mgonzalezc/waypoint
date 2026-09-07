import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/ui/features/ask/ask_analytics.dart';

import '../../../domain/analytics/analytics_service_mock.dart';

void main() {
  late AnalyticsServiceMock analytics;
  late AskAnalytics askAnalytics;

  setUp(() {
    analytics = AnalyticsServiceMock();
    askAnalytics = AskAnalytics(analytics);
  });

  group('AskAnalytics', () {
    group('when the user submits a query', () {
      test('then it tracks submit_query with the query text and locale', () {
        askAnalytics.logSubmitQuery(query: 'beaches in Portugal', locale: 'en');

        verify(
          () => analytics.track(
            'submit_query',
            properties: {'query_text': 'beaches in Portugal', 'locale': 'en'},
          ),
        ).called(1);
      });
    });

    group('when the user opens a past search from history', () {
      test('then it tracks open_history with that search\'s query text', () {
        askAnalytics.logOpenHistory('beaches in Portugal');

        verify(
          () => analytics.track('open_history', properties: {'query_text': 'beaches in Portugal'}),
        ).called(1);
      });
    });

    group('when the user clears their history', () {
      test('then it tracks clear_history', () {
        askAnalytics.logClearHistory();

        verify(() => analytics.track('clear_history')).called(1);
      });
    });
  });
}
