import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/source_citation.dart';
import 'package:waypoint/ui/screens/detail/view.dart';

import '../../../support/pump_localized_app.dart';

class _UrlLauncherPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

void main() {
  late _UrlLauncherPlatformMock urlLauncher;

  setUp(() {
    urlLauncher = _UrlLauncherPlatformMock();
    UrlLauncherPlatform.instance = urlLauncher;
    registerFallbackValue(const LaunchOptions());
    when(() => urlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);
  });

  group('DetailScreen', () {
    group('when the item has sources', () {
      testWidgets('then the reason and every source title are shown', (tester) async {
        const item = RankingItem(
          id: '1',
          position: 1,
          name: 'La Ristra',
          reason: 'Closest to the venue.',
          sources: [SourceCitation(title: 'Time Out Seville', url: 'https://timeout.com/la-ristra')],
        );

        await pumpLocalizedApp(tester, const DetailScreen(item: item));

        expect(find.text('La Ristra'), findsOneWidget);
        expect(find.text('Closest to the venue.'), findsOneWidget);
        expect(find.text('Time Out Seville'), findsOneWidget);
      });
    });

    group('when the item has no sources', () {
      testWidgets('then no sources section is shown', (tester) async {
        const item = RankingItem(id: '1', position: 1, name: 'La Ristra', reason: 'r', sources: []);

        await pumpLocalizedApp(tester, const DetailScreen(item: item));

        expect(find.text('Sources'), findsNothing);
      });
    });

    group('when the user taps a source', () {
      testWidgets('then it launches that source\'s URL', (tester) async {
        const item = RankingItem(
          id: '1',
          position: 1,
          name: 'La Ristra',
          reason: 'r',
          sources: [SourceCitation(title: 'Time Out Seville', url: 'https://timeout.com/la-ristra')],
        );

        await pumpLocalizedApp(tester, const DetailScreen(item: item));

        await tester.tap(find.text('Time Out Seville'));
        await tester.pump();

        verify(() => urlLauncher.launchUrl('https://timeout.com/la-ristra', any())).called(1);
      });
    });
  });
}
