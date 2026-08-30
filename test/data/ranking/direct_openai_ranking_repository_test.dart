import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/ranking/direct_openai_ranking_repository.dart';
import 'package:waypoint/data/services/openai_service.dart';
import 'package:waypoint/domain/ranking/ranking_failure.dart';

class _MockOpenAiService extends Mock implements OpenAiService {}

Map<String, dynamic> _completionWith(String jsonContent) => {
  'choices': [
    {
      'message': {'content': jsonContent},
    },
  ],
};

void main() {
  late _MockOpenAiService openAi;
  late DirectOpenAiRankingRepository repository;

  setUp(() {
    openAi = _MockOpenAiService();
    repository = DirectOpenAiRankingRepository(openAi);
  });

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('DirectOpenAiRankingRepository.generateRanking', () {
    group('when OpenAI returns 10 or more good candidates', () {
      test('then the result is not marked as degraded', () async {
        final items = List.generate(
          10,
          (i) => {'name': 'Place $i', 'reason': 'reason $i'},
        );
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenAnswer((_) async => _completionWith(jsonEncode({'items': items})));

        final result = await repository.generateRanking(query: 'q', locale: 'es');

        expect(result.items, hasLength(10));
        expect(result.degraded, isFalse);
      });
    });

    group('when OpenAI returns fewer than 10 candidates', () {
      test('then the result is marked as degraded, not padded', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenAnswer(
          (_) async => _completionWith(
            jsonEncode({
              'items': [
                {'name': 'Place 0', 'reason': 'reason 0'},
              ],
            }),
          ),
        );

        final result = await repository.generateRanking(query: 'q', locale: 'es');

        expect(result.items, hasLength(1));
        expect(result.degraded, isTrue);
      });
    });

    group('when the network is unreachable', () {
      test('then it throws NoConnection', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<NoConnection>()),
        );
      });
    });

    group('when OpenAI responds with 429', () {
      test('then it throws RateLimited', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 429),
          ),
        );

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<RateLimited>()),
        );
      });
    });

    group('when OpenAI responds with 429 for insufficient quota', () {
      test('then it throws InsufficientQuota, not RateLimited', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 429,
              data: {
                'error': {'code': 'insufficient_quota'},
              },
            ),
          ),
        );

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<InsufficientQuota>()),
        );
      });
    });

    group('when OpenAI responds with a 500', () {
      test('then it throws ServiceUnavailable', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
          ),
        );

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<ServiceUnavailable>()),
        );
      });
    });

    group('when OpenAI returns content that is not valid JSON', () {
      test('then it throws UnexpectedFailure instead of crashing', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenAnswer((_) async => _completionWith('not json'));

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });

    group('when OpenAI returns valid JSON that is not an object', () {
      test('then it throws UnexpectedFailure instead of a raw TypeError', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenAnswer((_) async => _completionWith(jsonEncode([1, 2, 3])));

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });

    group('when OpenAI returns an empty response body', () {
      test('then it throws UnexpectedFailure, not a raw StateError', () async {
        when(
          () => openAi.createChatCompletion(
            systemPrompt: any(named: 'systemPrompt'),
            userPrompt: any(named: 'userPrompt'),
          ),
        ).thenThrow(StateError('OpenAI returned an empty response body'));

        expect(
          () => repository.generateRanking(query: 'q', locale: 'es'),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });
  });
}
