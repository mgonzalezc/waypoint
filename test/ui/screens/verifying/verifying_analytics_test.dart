import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/ui/screens/verifying/verifying_analytics.dart';

import '../../../domain/analytics/analytics_service_mock.dart';

void main() {
  late AnalyticsServiceMock analytics;
  late VerifyingAnalytics verifyingAnalytics;

  setUp(() {
    analytics = AnalyticsServiceMock();
    verifyingAnalytics = VerifyingAnalytics(analytics);
  });

  group('VerifyingAnalytics', () {
    group('when a ranking is rendered', () {
      test('then it tracks render_ranking with the item count, degraded flag, and latency', () {
        verifyingAnalytics.logRenderRanking(itemCount: 7, degraded: true, latencyMs: 420);

        verify(
          () => analytics.track(
            'render_ranking',
            properties: {'item_count': 7, 'degraded': true, 'latency_ms': 420},
          ),
        ).called(1);
      });
    });
  });
}
