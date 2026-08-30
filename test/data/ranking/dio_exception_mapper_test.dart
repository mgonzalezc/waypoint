import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/ranking/dio_exception_mapper.dart';
import 'package:waypoint/domain/ranking/ranking_failure.dart';

DioException _badResponse({required int statusCode, Object? data}) => DioException(
  requestOptions: RequestOptions(path: ''),
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: RequestOptions(path: ''), statusCode: statusCode, data: data),
);

void main() {
  group('DioExceptionMapper.toRankingFailure', () {
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
          expect(error.toRankingFailure(), isA<NoConnection>());
        }
      });
    });

    group('when OpenAI responds with 429 and no quota error code', () {
      test('then it maps to RateLimited', () {
        final error = _badResponse(statusCode: 429);
        expect(error.toRankingFailure(), isA<RateLimited>());
      });
    });

    group('when OpenAI responds with 429 and an insufficient_quota code', () {
      test('then it maps to InsufficientQuota, not RateLimited', () {
        final error = _badResponse(
          statusCode: 429,
          data: {
            'error': {'code': 'insufficient_quota'},
          },
        );
        expect(error.toRankingFailure(), isA<InsufficientQuota>());
      });
    });

    group('when OpenAI responds with a 5xx', () {
      test('then it maps to ServiceUnavailable', () {
        final error = _badResponse(statusCode: 503);
        expect(error.toRankingFailure(), isA<ServiceUnavailable>());
      });
    });

    group('when OpenAI responds with an unrelated 4xx', () {
      test('then it maps to UnexpectedFailure carrying the status code', () {
        final error = _badResponse(statusCode: 400);
        final failure = error.toRankingFailure();
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
          expect(error.toRankingFailure(), isA<UnexpectedFailure>());
        }
      });
    });
  });
}
