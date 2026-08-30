import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/ranking/ranking_response_mapper.dart';
import 'package:waypoint/domain/ranking/ranking_failure.dart';

void main() {
  group('parseRankingItems', () {
    group('when OpenAI returns a well-formed ranking', () {
      test('then every item is parsed in order with its sources', () {
        final items = parseRankingItems({
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

        expect(items, hasLength(2));
        expect(items[0].position, 1);
        expect(items[0].name, 'Trattoria Da Enzo');
        expect(items[0].sources, hasLength(1));
        expect(items[1].position, 2);
        expect(items[1].sources, isEmpty);
      });
    });

    group('when an item has a source with a missing url', () {
      test('then that source is dropped, not the whole item', () {
        final items = parseRankingItems({
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

        expect(items, hasLength(1));
        expect(items.first.sources, isEmpty);
      });
    });

    group('when the response has no "items" field', () {
      test('then it is reported as an unexpected failure, not silently empty', () {
        expect(
          () => parseRankingItems({'oops': true}),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });

    group('when an item is missing its reason', () {
      test('then it is reported as an unexpected failure', () {
        expect(
          () => parseRankingItems({
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
