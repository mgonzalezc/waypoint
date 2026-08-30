import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/data/services/openai_service.dart';

void main() {
  late _FakeResponder responder;
  late OpenAiService service;

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.openai.com/v1'));
    responder = _FakeResponder();
    dio.interceptors.add(responder);
    service = OpenAiService(dio);
  });

  group('OpenAiService.createChatCompletion', () {
    group('when the response has a well-formed envelope', () {
      test('then it returns the message content', () async {
        responder.respondWith({
          'choices': [
            {
              'message': {'content': '{"items":[]}'},
            },
          ],
        });

        final content = await service.createChatCompletion(
          systemPrompt: 'system',
          userPrompt: 'user',
        );

        expect(content, '{"items":[]}');
      });
    });

    group('when the response has no choices', () {
      test('then it throws StateError, not a raw type error', () async {
        responder.respondWith({'choices': <dynamic>[]});

        expect(
          () => service.createChatCompletion(systemPrompt: 's', userPrompt: 'u'),
          throwsStateError,
        );
      });
    });

    group('when a choice has no message', () {
      test('then it throws StateError', () async {
        responder.respondWith({
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
        responder.respondWith({
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
        responder.respondWith(null);

        expect(
          () => service.createChatCompletion(systemPrompt: 's', userPrompt: 'u'),
          throwsStateError,
        );
      });
    });
  });
}

/// Resolves every request at the interceptor level with a canned body — no
/// real network, no need to implement Dio's HttpClientAdapter/ResponseBody
/// layer for what's just a handful of fixed responses.
class _FakeResponder extends Interceptor {
  Map<String, dynamic>? _next;

  void respondWith(Map<String, dynamic>? body) => _next = body;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(Response(requestOptions: options, data: _next, statusCode: 200));
  }
}
