import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/places/place_media_repository.dart';
import 'google_places_config.dart';
import 'google_places_media_repository.dart';
import 'null_place_media_repository.dart';

final placesDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: 'https://places.googleapis.com/v1',
      headers: {'X-Goog-Api-Key': googlePlacesApiKey},
    ),
  ),
);

final placeMediaRepositoryProvider = Provider<PlaceMediaRepository>((ref) {
  if (googlePlacesApiKey.isEmpty) return NullPlaceMediaRepository();
  return GooglePlacesMediaRepository(ref.watch(placesDioProvider));
});
