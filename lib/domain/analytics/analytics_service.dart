abstract interface class AnalyticsService {
  void track(String event, {Map<String, Object?> properties = const {}});
}
