import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/ranking_repository.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ask/view.dart';

class _FakeRankingRepository implements RankingRepository {
  @override
  Future<RankingResult> generateRanking({required String query, required String locale}) async {
    return RankingResult(
      query: query,
      isDegraded: false,
      items: const [
        RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'closest to the venue', sources: []),
      ],
    );
  }
}

void main() {
  group('AskView', () {
    group('when there is no query typed yet', () {
      testWidgets('then the submit button is disabled', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [rankingRepositoryProvider.overrideWithValue(_FakeRankingRepository())],
            child: const MaterialApp(home: AskView()),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('when the user types a query and submits', () {
      testWidgets('then the result is shown', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [rankingRepositoryProvider.overrideWithValue(_FakeRankingRepository())],
            child: const MaterialApp(home: AskView()),
          ),
        );

        await tester.enterText(find.byType(TextField), 'tapas en Roma');
        await tester.pump();

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);

        await tester.tap(find.text('generar ranking'));
        // A single pump is enough — the fake repository resolves
        // synchronously, no indeterminate animation is left running by the
        // time the data state renders, so pumpAndSettle would also work
        // but isn't needed.
        await tester.pump();

        expect(find.text('1. La Ristra'), findsOneWidget);
      });
    });
  });
}
