import 'package:dio/dio.dart';

import '../../domain/ranking/ranking_failure.dart';

extension DioExceptionMapper on DioException {
  RankingFailure toRankingFailure() {
    switch (type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return const NoConnection();
      case DioExceptionType.badResponse:
        final status = response?.statusCode;
        if (status == 429) return _mapTooManyRequests();
        if (status != null && status >= 500) return const ServiceUnavailable();
        return UnexpectedFailure('OpenAI returned HTTP $status');
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnexpectedFailure('Unexpected network error');
    }
  }

  RankingFailure _mapTooManyRequests() {
    final data = response?.data;
    final errorField = data is Map ? data['error'] : null;
    final code = errorField is Map ? errorField['code'] : null;
    if (code == 'insufficient_quota') return const InsufficientQuota();
    return const RateLimited();
  }
}
