import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/analytics/analytics_providers.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/ui/screens/ranking/ranking_view_model.dart';

import '../../../domain/analytics/analytics_service_mock.dart';

void main() {
  group('RankingViewModel', () {
    group('when the user opens an item', () {
      test('then it tracks open_detail with the item position', () {
        final analytics = AnalyticsServiceMock();
        final container = ProviderContainer(
          overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
        );
        addTearDown(container.dispose);

        const item = RankingItem(id: '1', position: 3, name: 'Place', reason: 'r', sources: []);
        container.read(rankingViewModelProvider.notifier).openItem(item);

        verify(() => analytics.track('open_detail', properties: {'position': 3})).called(1);
      });
    });
  });
}
