import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/places/place_media_providers.dart';
import '../../../domain/places/place_media.dart';

typedef PlaceMediaQuery = ({String placeName, String query});

class PlaceMediaViewModel extends AutoDisposeFamilyAsyncNotifier<PlaceMedia, PlaceMediaQuery> {
  @override
  Future<PlaceMedia> build(PlaceMediaQuery arg) {
    return ref.read(placeMediaRepositoryProvider).findMedia('${arg.placeName}, ${arg.query}');
  }
}

final placeMediaViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PlaceMediaViewModel, PlaceMedia, PlaceMediaQuery>(PlaceMediaViewModel.new);
