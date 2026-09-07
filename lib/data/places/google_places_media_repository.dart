import 'package:dio/dio.dart';

import '../../domain/places/place_media.dart';
import '../../domain/places/place_media_repository.dart';
import 'google_places_config.dart';

class GooglePlacesMediaRepository implements PlaceMediaRepository {
  GooglePlacesMediaRepository(this._dio);

  final Dio _dio;

  @override
  Future<PlaceMedia> findMedia(String placeName) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/places:searchText',
        data: {'textQuery': placeName},
        options: Options(headers: {'X-Goog-FieldMask': 'places.photos,places.location'}),
      );
    } on DioException {
      return const PlaceMedia();
    }

    final places = response.data?['places'];
    if (places is! List || places.isEmpty) return const PlaceMedia();

    final place = places.first;
    if (place is! Map<String, dynamic>) return const PlaceMedia();

    return PlaceMedia(photoUrl: _photoUrl(place), mapUrl: _mapUrl(place));
  }

  String? _photoUrl(Map<String, dynamic> place) {
    final photos = place['photos'];
    if (photos is! List || photos.isEmpty) return null;

    final photo = photos.first;
    if (photo is! Map<String, dynamic>) return null;

    final photoResourceName = photo['name'];
    if (photoResourceName is! String) return null;

    return 'https://places.googleapis.com/v1/$photoResourceName/media'
        '?key=$googlePlacesApiKey&maxWidthPx=800';
  }

  String? _mapUrl(Map<String, dynamic> place) {
    final location = place['location'];
    if (location is! Map) return null;

    final latitude = location['latitude'];
    final longitude = location['longitude'];
    if (latitude is! num || longitude is! num) return null;

    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$latitude,$longitude&zoom=15&size=600x300'
        '&markers=$latitude,$longitude&key=$googlePlacesApiKey';
  }
}
