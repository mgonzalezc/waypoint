import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/ranking/ranking_failure.dart';
import '../../domain/ranking/ranking_repository.dart';
import '../../domain/ranking/ranking_result.dart';
import '../services/openai_service.dart';
import 'dio_exception_mapper.dart';
import 'ranking_response_mapper.dart';

class DirectOpenAiRankingRepository implements RankingRepository {
  DirectOpenAiRankingRepository(this._openAi);

  final OpenAiService _openAi;

  @override
  Future<RankingResult> generateRanking({
    required String query,
    required String locale,
  }) async {
    try {
      final content = await _openAi.createChatCompletion(
        systemPrompt: _systemPrompt(locale),
        userPrompt: query,
      );
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw const UnexpectedFailure('OpenAI response content was not a JSON object');
      }
      final items = parseRankingItems(decoded);

      return RankingResult(
        query: query,
        items: items,
        degraded: items.length < 10,
      );
    } on DioException catch (error) {
      throw error.toRankingFailure();
    } on FormatException {
      throw const UnexpectedFailure('OpenAI response was not valid JSON');
    } on StateError catch (error) {
      throw UnexpectedFailure(error.message);
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
