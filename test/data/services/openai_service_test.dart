import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint/data/services/openai_service.dart';

class DioMock extends Mock implements Dio {}

void main() {
  late DioMock dio;
  late OpenAiService service;

  setUp(() {
    dio = DioMock();
    service = OpenAiService(dio);
  });

  Response<Map<String, dynamic>> responseWith(Map<String, dynamic>? body) => Response(
    requestOptions: RequestOptions(path: '/chat/completions'),
    data: body,
    statusCode: 200,
  );

  void stubCompletion(Map<String, dynamic>? body) {
    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => responseWith(body));
  }

  group('OpenAiService.createChatCompletion', () {
    group('when the response has a well-formed envelope', () {
      test('then it returns the message content', () async {
        stubCompletion({
          'choices': [
            {'message': {'content': '{"items":[]}'}},
          ],
        });

        final content = await service.createChatCompletion(
          systemPrompt: 'system',
          userPrompt: 'user',
        );

        expect(content, '{"items":[]}');
      });

      test('then it sends the model, response format, and both prompts to OpenAI', () async {
        stubCompletion({
          'choices': [
            {'message': {'content': '{}'}},
          ],
        });

        await service.createChatCompletion(systemPrompt: 'system prompt', userPrompt: 'user prompt');

        verify(
          () => dio.post<Map<String, dynamic>>(
            '/chat/completions',
            data: {
              'model': 'gpt-5-nano',
              'reasoning_effort': 'low',
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': 'system prompt'},
                {'role': 'user', 'content': 'user prompt'},
              ],
            },
          ),
        ).called(1);
      });
    });

    group('when the response has no choices', () {
      test('then it throws StateError, not a raw type error', () async {
        stubCompletion({'choices': <dynamic>[]});

        expect(
          () => service.createChatCompletion(systemPrompt: 's', userPrompt: 'u'),
          throwsStateError,
        );
      });
    });

    group('when a choice has no message', () {
      test('then it throws StateError', () async {
        stubCompletion({
          'choices': [<String, dynamic>{}],
        });

        expect(
          () => service.createChatCompletion(systemPrompt: 's', userPrompt: 'u'),
          throwsStateError,
        );
      });
    });

    group('when the message has no content', () {
      test('then it throws StateError', () async {
        stubCompletion({
          'choices': [
            {'message': <String, dynamic>{}},
          ],
        });

        expect(
          () => service.createChatCompletion(systemPrompt: 's', userPrompt: 'u'),
          throwsStateError,
        );
      });
    });

    group('when the response body is empty', () {
      test('then it throws StateError', () async {
        stubCompletion(null);

        expect(
          () => service.createChatCompletion(systemPrompt: 's', userPrompt: 'u'),
          throwsStateError,
        );
      });
    });
  });
}
