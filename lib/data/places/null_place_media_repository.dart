import '../../domain/places/place_media.dart';
import '../../domain/places/place_media_repository.dart';

class NullPlaceMediaRepository implements PlaceMediaRepository {
  @override
  Future<PlaceMedia> findMedia(String placeName) async => const PlaceMedia();
}
