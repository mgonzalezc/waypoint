import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/analytics/analytics_providers.dart';
import '../../../domain/analytics/analytics_service.dart';

class AskAnalytics {
  AskAnalytics(this._analytics);

  final AnalyticsService _analytics;

  void logSubmitQuery({required String query, required String locale}) =>
      _analytics.track('submit_query', properties: {'query_text': query, 'locale': locale});

  void logOpenHistory(String query) => _analytics.track('open_history', properties: {'query_text': query});

  void logClearHistory() => _analytics.track('clear_history');
}

final askAnalyticsProvider = Provider.autoDispose<AskAnalytics>(
  (ref) => AskAnalytics(ref.read(analyticsServiceProvider)),
);
