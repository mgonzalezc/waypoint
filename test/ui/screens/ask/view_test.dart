import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/ranking_providers.dart';
import 'package:waypoint/domain/ranking/ranking_result.dart';
import 'package:waypoint/ui/screens/ask/view.dart';
import 'package:waypoint/ui/screens/verifying/view.dart';

import '../../../domain/ranking/ranking_repository_mock.dart';
import '../../../support/pump_localized_app.dart';

void main() {
  group('AskView', () {
    group('when there is no query typed yet', () {
      testWidgets('then the submit button is disabled', (tester) async {
        await pumpLocalizedApp(tester, const AskView());

        final button = tester.widget<TextButton>(find.byType(TextButton));
        expect(button.onPressed, isNull);
      });
    });

    group('when the user types a query and submits', () {
      testWidgets('then it navigates to the verifying screen with that query', (tester) async {
        // VerifyingScreen starts fetching as soon as it's pushed, so the
        // repository still needs a stub here even though this test only
        // cares about the navigation, not the result.
        final repository = RankingRepositoryMock();
        final completer = Completer<RankingResult>();
        when(
          () => repository.generateRanking(query: any(named: 'query'), locale: any(named: 'locale')),
        ).thenAnswer((_) => completer.future);

        await pumpLocalizedApp(
          tester,
          const AskView(),
          overrides: [rankingRepositoryProvider.overrideWithValue(repository)],
        );

        await tester.enterText(find.byType(TextField), 'tapas en Roma');
        await tester.pump();
        await tester.tap(find.text('Generate ranking'));
        // Two pumps: the pushed route is offstage for the frame it's
        // inserted on (part of the transition machinery), so it isn't
        // findable until the next frame.
        await tester.pump();
        await tester.pump();

        final screen = tester.widget<VerifyingScreen>(find.byType(VerifyingScreen));
        expect(screen.query, 'tapas en Roma');
      });
    });
  });
}
