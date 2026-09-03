import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/ui/screens/detail/detail_analytics.dart';

import '../../../domain/analytics/analytics_service_mock.dart';

void main() {
  late AnalyticsServiceMock analytics;
  late DetailAnalytics detailAnalytics;

  setUp(() {
    analytics = AnalyticsServiceMock();
    detailAnalytics = DetailAnalytics(analytics);
  });

  group('DetailAnalytics', () {
    group('when the user opens a source', () {
      test('then it tracks open_source with the source url', () {
        detailAnalytics.logOpenSource('https://example.com');

        verify(
          () => analytics.track('open_source', properties: {'url': 'https://example.com'}),
        ).called(1);
      });
    });
  });
}
