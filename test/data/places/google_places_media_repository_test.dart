import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/places/google_places_media_repository.dart';

class DioMock extends Mock implements Dio {}

void main() {
  late DioMock dio;
  late GooglePlacesMediaRepository repository;

  setUp(() {
    dio = DioMock();
    repository = GooglePlacesMediaRepository(dio);
  });

  Response<Map<String, dynamic>> responseWith(Map<String, dynamic>? body) => Response(
    requestOptions: RequestOptions(path: '/places:searchText'),
    data: body,
    statusCode: 200,
  );

  void stubSearch(Map<String, dynamic>? body) {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => responseWith(body));
  }

  group('GooglePlacesMediaRepository.findMedia', () {
    group('when the place has a photo and a location', () {
      test('then it returns a photo URL and a map URL', () async {
        stubSearch({
          'places': [
            {
              'photos': [
                {'name': 'places/abc123/photos/xyz789'},
              ],
              'location': {'latitude': 37.3826, 'longitude': -5.9963},
            },
          ],
        });

        final media = await repository.findMedia('La Ristra, tapas en Sevilla');

        expect(media.photoUrl, contains('places/abc123/photos/xyz789/media'));
        expect(media.mapUrl, contains('center=37.3826,-5.9963'));
        expect(media.mapUrl, contains('markers=37.3826,-5.9963'));
      });
    });

    group('when the place has no photos or location', () {
      test('then both URLs are null', () async {
        stubSearch({
          'places': [
            {'photos': <dynamic>[]},
          ],
        });

        final media = await repository.findMedia('La Ristra');

        expect(media.photoUrl, isNull);
        expect(media.mapUrl, isNull);
      });
    });

    group('when a photo entry is not an object', () {
      test('then the photo URL is null instead of throwing', () async {
        stubSearch({
          'places': [
            {
              'photos': ['not an object'],
              'location': {'latitude': 37.3826, 'longitude': -5.9963},
            },
          ],
        });

        final media = await repository.findMedia('La Ristra');

        expect(media.photoUrl, isNull);
        expect(media.mapUrl, contains('center=37.3826,-5.9963'));
      });
    });

    group('when no places are found', () {
      test('then both URLs are null', () async {
        stubSearch({'places': <dynamic>[]});

        final media = await repository.findMedia('a place nobody has heard of');

        expect(media.photoUrl, isNull);
        expect(media.mapUrl, isNull);
      });
    });

    group('when the request fails', () {
      test('then both URLs are null instead of throwing', () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(requestOptions: RequestOptions(path: '/places:searchText')),
        );

        final media = await repository.findMedia('La Ristra');

        expect(media.photoUrl, isNull);
        expect(media.mapUrl, isNull);
      });
    });
  });
}
