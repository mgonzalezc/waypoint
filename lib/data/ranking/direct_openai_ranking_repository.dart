import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/ranking/ranking_failure.dart';
import '../../domain/ranking/ranking_repository.dart';
import '../../domain/ranking/ranking_result.dart';
import '../services/openai_service.dart';
import 'dto/ranking_response_dto.dart';

class DirectOpenAiRankingRepository implements RankingRepository {
  DirectOpenAiRankingRepository(this._openAi);

  final OpenAiService _openAi;

  @override
  Future<RankingResult> generateRanking({
    required String query,
    required String locale,
  }) async {
    try {
      final completion = await _openAi.createChatCompletion(
        systemPrompt: _systemPrompt(locale),
        userPrompt: query,
      );
      final content = _extractContent(completion);
      final dto = RankingResponseDto.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );

      return RankingResult(
        query: query,
        items: dto.items,
        degraded: dto.items.length < 10,
      );
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on FormatException {
      throw const UnexpectedFailure('OpenAI response was not valid JSON');
    } on StateError catch (error) {
      throw UnexpectedFailure(error.message);
    }
  }

  String _extractContent(Map<String, dynamic> completion) {
    final choices = completion['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const UnexpectedFailure('OpenAI response has no choices');
    }

    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw const UnexpectedFailure('OpenAI response choice is not an object');
    }

    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw const UnexpectedFailure('OpenAI response choice has no message');
    }

    final content = message['content'];
    if (content is! String) {
      throw const UnexpectedFailure('OpenAI response message has no content');
    }

    return content;
  }

  RankingFailure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return const NoConnection();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 429) return const RateLimited();
        if (status != null && status >= 500) return const ServiceUnavailable();
        return UnexpectedFailure('OpenAI returned HTTP $status');
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnexpectedFailure('Unexpected network error');
    }
  }

  String _systemPrompt(String locale) => '''
You are Waypoint, a travel ranking assistant. Given a natural-language travel
question, respond with a strict JSON object of the shape:
{"items": [{"name": string, "reason": string, "sources": [{"title": string, "url": string}]}]}

Rules:
- Return at most 10 items, ranked best first (position 1 = best).
- If you cannot find at least 10 genuinely good candidates, return fewer
  rather than padding the list with weak ones.
- "reason" must explain concretely why this item beats the next one, not a
  generic compliment.
- Only include a source you are confident is real. Omit the "sources" array
  entirely for an item rather than inventing a URL.
- Respond in locale "$locale".
''';
}
