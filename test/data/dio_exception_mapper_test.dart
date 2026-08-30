import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/dio_exception_mapper.dart';
import 'package:waypoint/domain/api_failure.dart';

DioException _badResponse({required int statusCode, Object? data}) => DioException(
  requestOptions: RequestOptions(path: ''),
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: RequestOptions(path: ''), statusCode: statusCode, data: data),
);

void main() {
  group('DioExceptionMapper.toApiFailure', () {
    group('when the connection fails or times out', () {
      test('then it maps to NoConnection', () {
        for (final type in [
          DioExceptionType.connectionError,
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.transformTimeout,
        ]) {
          final error = DioException(requestOptions: RequestOptions(path: ''), type: type);
          expect(error.toApiFailure(), isA<NoConnection>());
        }
      });
    });

    group('when the API responds with 429, regardless of the reason', () {
      test('then it maps to ServiceUnavailable — the user cannot fix billing/rate limits', () {
        final genericLimit = _badResponse(statusCode: 429);
        final quotaExhausted = _badResponse(
          statusCode: 429,
          data: {
            'error': {'code': 'insufficient_quota'},
          },
        );

        expect(genericLimit.toApiFailure(), isA<ServiceUnavailable>());
        expect(quotaExhausted.toApiFailure(), isA<ServiceUnavailable>());
      });
    });

    group('when the API responds with a 5xx', () {
      test('then it maps to ServiceUnavailable', () {
        final error = _badResponse(statusCode: 503);
        expect(error.toApiFailure(), isA<ServiceUnavailable>());
      });
    });

    group('when the API responds with an unrelated 4xx', () {
      test('then it maps to UnexpectedFailure carrying the status code', () {
        final error = _badResponse(statusCode: 400);
        final failure = error.toApiFailure();
        expect(failure, isA<UnexpectedFailure>());
        expect((failure as UnexpectedFailure).message, contains('400'));
      });
    });

    group('when the request was cancelled or hit an unknown Dio error', () {
      test('then it maps to UnexpectedFailure', () {
        for (final type in [
          DioExceptionType.cancel,
          DioExceptionType.badCertificate,
          DioExceptionType.unknown,
        ]) {
          final error = DioException(requestOptions: RequestOptions(path: ''), type: type);
          expect(error.toApiFailure(), isA<UnexpectedFailure>());
        }
      });
    });
  });
}
