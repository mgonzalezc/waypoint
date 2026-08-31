import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ranking/view.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';

Future<void> _pumpWithResult(WidgetTester tester, RankingResult result) async {
  final repository = RankingRepositoryMock();
  when(
    () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
  ).thenAnswer((_) async => result);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: RankingScreen(query: 'q', locale: 'es')),
    ),
  );
  // The mock repository resolves on the next microtask, so a single pump
  // is enough for the data state to render.
  await tester.pump();
}

void main() {
  group('RankingScreen', () {
    group('when there are 10 good results', () {
      testWidgets('then the 10 items are shown, with no degraded badge', (tester) async {
        await _pumpWithResult(
          tester,
          RankingResult(
            query: 'q',
            isDegraded: false,
            items: List.generate(
              10,
              (i) => RankingItem(id: '$i', position: i + 1, name: 'Place $i', reason: 'r', sources: const []),
            ),
          ),
        );

        expect(find.text('1. Place 0'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('10. Place 9'), 500);
        expect(find.text('10. Place 9'), findsOneWidget);
        expect(find.text('fewer than 10 good candidates'), findsNothing);
      });
    });

    group('when there are fewer than 10 good results', () {
      testWidgets('then it shows fewer items and says so, never fills with noise', (tester) async {
        await _pumpWithResult(
          tester,
          const RankingResult(
            query: 'q',
            isDegraded: true,
            items: [RankingItem(id: '1', position: 1, name: 'Only Good One', reason: 'r', sources: [])],
          ),
        );

        expect(find.text('1. Only Good One'), findsOneWidget);
        expect(find.text('fewer than 10 good candidates'), findsOneWidget);
      });
    });
  });
}
