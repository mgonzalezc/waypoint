import 'package:dio/dio.dart';

import '../domain/api_failure.dart';

extension DioExceptionMapper on DioException {
  ApiFailure toApiFailure() {
    switch (type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return const NoConnection();
      case DioExceptionType.badResponse:
        final status = response?.statusCode;
        if (status == 429) return const ServiceUnavailable();
        if (status != null && status >= 500) return const ServiceUnavailable();
        return UnexpectedFailure('API returned HTTP $status');
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnexpectedFailure('Unexpected network error');
    }
  }
}
