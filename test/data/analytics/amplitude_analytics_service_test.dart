import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/analytics/amplitude_analytics_service.dart';

class AmplitudeMock extends Mock implements Amplitude {}

void main() {
  late AmplitudeMock amplitude;
  late AmplitudeAnalyticsService service;

  setUpAll(() {
    registerFallbackValue(BaseEvent('fallback'));
  });

  setUp(() {
    amplitude = AmplitudeMock();
    service = AmplitudeAnalyticsService(amplitude);
    when(() => amplitude.track(any())).thenAnswer((_) async {});
  });

  group('AmplitudeAnalyticsService.track', () {
    group('when called with an event and properties', () {
      test('then it forwards a BaseEvent with that type and those properties', () {
        service.track('submit_query', properties: {'query_text': 'tapas'});

        final captured = verify(() => amplitude.track(captureAny())).captured;
        final event = captured.single as BaseEvent;
        expect(event.eventType, 'submit_query');
        expect(event.eventProperties, {'query_text': 'tapas'});
      });
    });

    group('when called with no properties', () {
      test('then it forwards an empty properties map', () {
        service.track('clear_history');

        final captured = verify(() => amplitude.track(captureAny())).captured;
        final event = captured.single as BaseEvent;
        expect(event.eventType, 'clear_history');
        expect(event.eventProperties, isEmpty);
      });
    });
  });
}
