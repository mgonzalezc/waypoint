import 'place_media.dart';

abstract interface class PlaceMediaRepository {
  Future<PlaceMedia> findMedia(String placeName);
}
