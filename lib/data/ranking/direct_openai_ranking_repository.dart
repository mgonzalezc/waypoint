import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/api_failure.dart';
import '../../domain/ranking/ranking_repository.dart';
import '../../domain/ranking/ranking_result.dart';
import '../dio_exception_mapper.dart';
import '../services/openai_service.dart';
import 'ranking_system_prompt.dart';
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
        systemPrompt: rankingSystemPrompt(locale),
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
        isDegraded: items.length < 10,
      );
    } on DioException catch (error) {
      throw error.toApiFailure();
    } on FormatException {
      throw const UnexpectedFailure('OpenAI response was not valid JSON');
    } on StateError catch (error) {
      throw UnexpectedFailure(error.message);
    }
  }
}
