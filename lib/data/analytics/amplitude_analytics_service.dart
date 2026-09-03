import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';

import '../../domain/analytics/analytics_service.dart';

class AmplitudeAnalyticsService implements AnalyticsService {
  AmplitudeAnalyticsService(this._amplitude);

  final Amplitude _amplitude;

  @override
  void track(String event, {Map<String, Object?> properties = const {}}) {
    _amplitude.track(BaseEvent(event, eventProperties: properties));
  }
}
