import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/analytics/analytics_providers.dart';
import 'package:waypoint/data/places/place_media_providers.dart';
import 'package:waypoint/domain/places/place_media.dart';
import 'package:waypoint/ui/features/detail/detail_view_model.dart';

import '../../../domain/analytics/analytics_service_mock.dart';
import '../../../domain/places/place_media_repository_mock.dart';

void main() {
  group('DetailViewModel', () {
    group('when the user opens a source', () {
      test('then it tracks open_source with the source url', () async {
        final repository = PlaceMediaRepositoryMock();
        when(() => repository.findMedia(any())).thenAnswer((_) async => const PlaceMedia());
        final analytics = AnalyticsServiceMock();

        final container = ProviderContainer(
          overrides: [
            placeMediaRepositoryProvider.overrideWithValue(repository),
            analyticsServiceProvider.overrideWithValue(analytics),
          ],
        );
        addTearDown(container.dispose);

        const query = (placeName: 'Place', query: 'q');
        await container.read(detailViewModelProvider(query).future);

        container.read(detailViewModelProvider(query).notifier).openSource('https://example.com');

        verify(
          () => analytics.track('open_source', properties: {'url': 'https://example.com'}),
        ).called(1);
      });
    });
  });
}
