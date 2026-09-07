import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/l10n/app_localizations.dart';
import 'package:waypoint/ui/features/ask/ask_screen.dart';
import 'package:waypoint/ui/navigation/app_router.dart';
import 'package:waypoint/ui/navigation/app_routes.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appRouter.go(AppRoutes.askPath);
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: appRouter,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );

  group('appRouter', () {
    group('when verifying is reached without the query/locale it needs', () {
      testWidgets('then it redirects to Ask instead of crashing', (tester) async {
        await pumpApp(tester);

        appRouter.go(AppRoutes.verifyingPath);
        await tester.pumpAndSettle();

        expect(find.byType(AskScreen), findsOneWidget);
      });
    });

    group('when ranking is reached without a result to show', () {
      testWidgets('then it redirects to Ask instead of crashing', (tester) async {
        await pumpApp(tester);

        appRouter.go(AppRoutes.rankingPath);
        await tester.pumpAndSettle();

        expect(find.byType(AskScreen), findsOneWidget);
      });
    });

    group('when detail is reached without an item to show', () {
      testWidgets('then it redirects to Ask instead of crashing', (tester) async {
        await pumpApp(tester);

        appRouter.go(AppRoutes.detailPath);
        await tester.pumpAndSettle();

        expect(find.byType(AskScreen), findsOneWidget);
      });
    });

    group('when the path matches no route at all', () {
      testWidgets('then it falls back to Ask instead of an error page', (tester) async {
        await pumpApp(tester);

        appRouter.go('/nowhere');
        await tester.pumpAndSettle();

        expect(find.byType(AskScreen), findsOneWidget);
      });
    });
  });
}
