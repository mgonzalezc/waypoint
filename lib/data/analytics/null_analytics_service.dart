import '../../domain/analytics/analytics_service.dart';

class NullAnalyticsService implements AnalyticsService {
  @override
  void track(String event, {Map<String, Object?> properties = const {}}) {}
}
