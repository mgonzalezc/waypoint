import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/analytics/analytics_providers.dart';
import '../../../domain/analytics/analytics_service.dart';

class VerifyingAnalytics {
  VerifyingAnalytics(this._analytics);

  final AnalyticsService _analytics;

  void logRenderRanking({required int itemCount, required bool degraded, required int latencyMs}) =>
      _analytics.track(
        'render_ranking',
        properties: {'item_count': itemCount, 'degraded': degraded, 'latency_ms': latencyMs},
      );
}

final verifyingAnalyticsProvider = Provider.autoDispose<VerifyingAnalytics>(
  (ref) => VerifyingAnalytics(ref.read(analyticsServiceProvider)),
);
