import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analytics/analytics_service.dart';
import 'amplitude_analytics_service.dart';
import 'amplitude_config.dart';
import 'null_analytics_service.dart';

final amplitudeClientProvider = Provider<Amplitude>(
  (ref) => Amplitude(Configuration(apiKey: amplitudeApiKey)),
);

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (amplitudeApiKey.isEmpty) return NullAnalyticsService();
  return AmplitudeAnalyticsService(ref.watch(amplitudeClientProvider));
});
