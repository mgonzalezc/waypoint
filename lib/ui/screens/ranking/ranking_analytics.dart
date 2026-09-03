import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/analytics/analytics_providers.dart';
import '../../../domain/analytics/analytics_service.dart';

class RankingAnalytics {
  RankingAnalytics(this._analytics);

  final AnalyticsService _analytics;

  void logOpenDetail(int position) => _analytics.track('open_detail', properties: {'position': position});
}

final rankingAnalyticsProvider = Provider.autoDispose<RankingAnalytics>(
  (ref) => RankingAnalytics(ref.read(analyticsServiceProvider)),
);
