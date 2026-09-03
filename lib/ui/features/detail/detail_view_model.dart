import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/places/place_media_providers.dart';
import '../../../domain/places/place_media.dart';
import 'detail_analytics.dart';

typedef DetailQuery = ({String placeName, String query});

class DetailViewModel extends AutoDisposeFamilyAsyncNotifier<PlaceMedia, DetailQuery> {
  @override
  Future<PlaceMedia> build(DetailQuery arg) {
    return ref.read(placeMediaRepositoryProvider).findMedia('${arg.placeName}, ${arg.query}');
  }

  void openSource(String url) {
    ref.read(detailAnalyticsProvider).logOpenSource(url);
  }
}

final detailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<DetailViewModel, PlaceMedia, DetailQuery>(DetailViewModel.new);
