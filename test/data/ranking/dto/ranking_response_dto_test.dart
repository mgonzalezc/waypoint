import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/ranking/dto/ranking_response_dto.dart';
import 'package:waypoint/domain/ranking/ranking_failure.dart';

void main() {
  group('RankingResponseDto.fromJson', () {
    group('when OpenAI returns a well-formed ranking', () {
      test('then every item is parsed in order with its sources', () {
        final dto = RankingResponseDto.fromJson({
          'items': [
            {
              'name': 'Trattoria Da Enzo',
              'reason': 'closest to the venue and open late',
              'sources': [
                {'title': 'Tripadvisor', 'url': 'https://tripadvisor.com/x'},
              ],
            },
            {'name': 'Osteria Fernanda', 'reason': 'cheaper, similar quality'},
          ],
        });

        expect(dto.items, hasLength(2));
        expect(dto.items[0].position, 1);
        expect(dto.items[0].name, 'Trattoria Da Enzo');
        expect(dto.items[0].sources, hasLength(1));
        expect(dto.items[1].position, 2);
        expect(dto.items[1].sources, isEmpty);
      });
    });

    group('when an item has a source with a missing url', () {
      test('then that source is dropped, not the whole item', () {
        final dto = RankingResponseDto.fromJson({
          'items': [
            {
              'name': 'Trattoria Da Enzo',
              'reason': 'closest to the venue',
              'sources': [
                {'title': 'no url here'},
              ],
            },
          ],
        });

        expect(dto.items, hasLength(1));
        expect(dto.items.first.sources, isEmpty);
      });
    });

    group('when the response has no "items" field', () {
      test('then it is reported as an unexpected failure, not silently empty', () {
        expect(
          () => RankingResponseDto.fromJson({'oops': true}),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });

    group('when an item is missing its reason', () {
      test('then it is reported as an unexpected failure', () {
        expect(
          () => RankingResponseDto.fromJson({
            'items': [
              {'name': 'Trattoria Da Enzo'},
            ],
          }),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });
  });
}
