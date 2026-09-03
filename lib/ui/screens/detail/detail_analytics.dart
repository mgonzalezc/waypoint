import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/analytics/analytics_providers.dart';
import '../../../domain/analytics/analytics_service.dart';

class DetailAnalytics {
  DetailAnalytics(this._analytics);

  final AnalyticsService _analytics;

  void logOpenSource(String url) => _analytics.track('open_source', properties: {'url': url});
}

final detailAnalyticsProvider = Provider.autoDispose<DetailAnalytics>(
  (ref) => DetailAnalytics(ref.read(analyticsServiceProvider)),
);
