import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/ui/features/ranking/ranking_analytics.dart';

import '../../../domain/analytics/analytics_service_mock.dart';

void main() {
  late AnalyticsServiceMock analytics;
  late RankingAnalytics rankingAnalytics;

  setUp(() {
    analytics = AnalyticsServiceMock();
    rankingAnalytics = RankingAnalytics(analytics);
  });

  group('RankingAnalytics', () {
    group('when the user opens an item', () {
      test('then it tracks open_detail with the item position', () {
        rankingAnalytics.logOpenDetail(3);

        verify(() => analytics.track('open_detail', properties: {'position': 3})).called(1);
      });
    });
  });
}
