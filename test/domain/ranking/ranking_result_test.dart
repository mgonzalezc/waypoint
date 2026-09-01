import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';

RankingItem _item(String name) => RankingItem(id: name, position: 1, name: name, reason: 'r', sources: const []);

void main() {
  group('RankingResult.fingerprint', () {
    group('when two results list the same places in a different order', () {
      test('then they have the same fingerprint', () {
        final a = RankingResult(query: 'q1', isDegraded: false, items: [_item('La Ristra'), _item('Bar Alfalfa')]);
        final b = RankingResult(query: 'q2', isDegraded: false, items: [_item('Bar Alfalfa'), _item('La Ristra')]);

        expect(a.fingerprint, b.fingerprint);
      });
    });

    group('when two results list the same places with different casing or spacing', () {
      test('then they have the same fingerprint', () {
        final a = RankingResult(query: 'q1', isDegraded: false, items: [_item('La Ristra')]);
        final b = RankingResult(query: 'q2', isDegraded: false, items: [_item(' la ristra ')]);

        expect(a.fingerprint, b.fingerprint);
      });
    });

    group('when the reason text differs but the places are the same', () {
      test('then the fingerprint still matches', () {
        const a = RankingResult(
          query: 'q1',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'closest', sources: [])],
        );
        const b = RankingResult(
          query: 'q2',
          isDegraded: false,
          items: [RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'cheapest', sources: [])],
        );

        expect(a.fingerprint, b.fingerprint);
      });
    });

    group('when the results list genuinely different places', () {
      test('then the fingerprints differ', () {
        final a = RankingResult(query: 'q1', isDegraded: false, items: [_item('La Ristra')]);
        final b = RankingResult(query: 'q1', isDegraded: false, items: [_item('Bar Alfalfa')]);

        expect(a.fingerprint, isNot(b.fingerprint));
      });
    });
  });
}
