import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/places/place_media_providers.dart';
import '../../../domain/places/place_media.dart';

class PlaceMediaViewModel extends AutoDisposeFamilyAsyncNotifier<PlaceMedia, String> {
  @override
  Future<PlaceMedia> build(String placeName) {
    return ref.read(placeMediaRepositoryProvider).findMedia(placeName);
  }
}

final placeMediaViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PlaceMediaViewModel, PlaceMedia, String>(PlaceMediaViewModel.new);
