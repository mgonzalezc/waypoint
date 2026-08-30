import 'package:dio/dio.dart';

import '../ranking/openai_api_key.dart';

class OpenAiService {
  OpenAiService(this._dio);

  final Dio _dio;

  static Dio buildClient() => Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {'Authorization': 'Bearer $openAiApiKey'},
    ),
  );

  Future<Map<String, dynamic>> createChatCompletion({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: {
        'model': 'gpt-4o-mini',
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('OpenAI returned an empty response body');
    }
    return data;
  }
}
