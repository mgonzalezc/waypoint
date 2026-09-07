import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:waypoint/data/places/place_media_providers.dart';
import 'package:waypoint/domain/places/place_media.dart';
import 'package:waypoint/domain/ranking/ranking_item.dart';
import 'package:waypoint/domain/ranking/source_citation.dart';
import 'package:waypoint/ui/features/detail/detail_screen.dart';

import '../../../domain/places/place_media_repository_mock.dart';
import '../../../support/pump_localized_app.dart';

class _UrlLauncherPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

const _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

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
          position: 1,
          name: 'La Ristra',
          reason: 'Closest to the venue.',
          sources: [SourceCitation(title: 'Time Out Seville', url: 'https://timeout.com/la-ristra')],
        );

        await pumpLocalizedApp(tester, const DetailScreen(item: item, query: 'tapas en Sevilla'));

        expect(find.text('La Ristra'), findsOneWidget);
        expect(find.text('Closest to the venue.'), findsOneWidget);
        expect(find.text('Time Out Seville'), findsOneWidget);
      });
    });

    group('when the item has no sources', () {
      testWidgets('then no sources section is shown', (tester) async {
        const item = RankingItem(position: 1, name: 'La Ristra', reason: 'r', sources: []);

        await pumpLocalizedApp(tester, const DetailScreen(item: item, query: 'tapas en Sevilla'));

        expect(find.text('Sources'), findsNothing);
      });
    });

    group('when the user taps a source', () {
      testWidgets('then it launches that source\'s URL', (tester) async {
        const item = RankingItem(
          position: 1,
          name: 'La Ristra',
          reason: 'r',
          sources: [SourceCitation(title: 'Time Out Seville', url: 'https://timeout.com/la-ristra')],
        );

        await pumpLocalizedApp(tester, const DetailScreen(item: item, query: 'tapas en Sevilla'));
        await tester.scrollUntilVisible(
          find.text('Time Out Seville'),
          200,
          scrollable: find.byType(Scrollable),
        );

        await tester.tap(find.text('Time Out Seville'));
        await tester.pump();

        verify(() => urlLauncher.launchUrl('https://timeout.com/la-ristra', any())).called(1);
      });
    });

    group('when the source fails to open', () {
      testWidgets('then it tells the user, instead of doing nothing', (tester) async {
        when(() => urlLauncher.launchUrl(any(), any())).thenAnswer((_) async => false);
        const item = RankingItem(
          position: 1,
          name: 'La Ristra',
          reason: 'r',
          sources: [SourceCitation(title: 'Time Out Seville', url: 'https://timeout.com/la-ristra')],
        );

        await pumpLocalizedApp(tester, const DetailScreen(item: item, query: 'tapas en Sevilla'));
        await tester.scrollUntilVisible(
          find.text('Time Out Seville'),
          200,
          scrollable: find.byType(Scrollable),
        );

        await tester.tap(find.text('Time Out Seville'));
        await tester.pump();

        expect(find.text("Couldn't open that link."), findsOneWidget);
      });
    });

    group('when a photo and a map are found for the place', () {
      testWidgets('then both are shown above the ranking numeral', (tester) async {
        debugNetworkImageHttpClientProvider = () => _FakeHttpClient();

        const item = RankingItem(position: 1, name: 'La Ristra', reason: 'r', sources: []);
        final repository = PlaceMediaRepositoryMock();
        when(() => repository.findMedia(any())).thenAnswer(
          (_) async => const PlaceMedia(
            photoUrl: 'https://places.googleapis.com/v1/places/1/photos/1/media',
            mapUrl: 'https://maps.googleapis.com/maps/api/staticmap?center=1,1',
          ),
        );

        await pumpLocalizedApp(
          tester,
          const DetailScreen(item: item, query: 'tapas en Sevilla'),
          overrides: [placeMediaRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        expect(find.byType(Image), findsNWidgets(2));

        debugNetworkImageHttpClientProvider = null;
      });
    });

    group('when no photo or map is found for the place', () {
      testWidgets('then a placeholder is shown instead of a broken image', (tester) async {
        const item = RankingItem(position: 1, name: 'La Ristra', reason: 'r', sources: []);
        final repository = PlaceMediaRepositoryMock();
        when(() => repository.findMedia(any())).thenAnswer((_) async => const PlaceMedia());

        await pumpLocalizedApp(
          tester,
          const DetailScreen(item: item, query: 'tapas en Sevilla'),
          overrides: [placeMediaRepositoryProvider.overrideWithValue(repository)],
        );
        await tester.pump();

        expect(find.byType(Image), findsNothing);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
        expect(find.text('01'), findsOneWidget);
      });
    });
  });
}
