import 'package:dio/dio.dart';

import '../ranking/ranking_openai_config.dart';

class OpenAiService {
  OpenAiService(this._dio);

  final Dio _dio;

  static Dio buildClient() => Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {'Authorization': 'Bearer $openAiApiKey'},
    ),
  );

  Future<String> createChatCompletion({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: {
        'model': 'gpt-5-nano',
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
    return _extractContent(data);
  }

  String _extractContent(Map<String, dynamic> completion) {
    final choices = completion['choices'];
    if (choices is! List || choices.isEmpty) {
      throw StateError('OpenAI response has no choices');
    }

    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw StateError('OpenAI response choice is not an object');
    }

    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw StateError('OpenAI response choice has no message');
    }

    final content = message['content'];
    if (content is! String) {
      throw StateError('OpenAI response message has no content');
    }

    return content;
  }
}
