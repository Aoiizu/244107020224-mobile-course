import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/assistant/data/assistant_repository_impl.dart';
import 'package:campus_notification_app/features/assistant/data/gemini_remote_source.dart';
import 'package:campus_notification_app/features/assistant/domain/entities/chat_message.dart';
import 'package:campus_notification_app/shared/data/api_key_store.dart';

typedef Generate = Future<String> Function(
    String system, List<Map<String, dynamic>> contents);

class FakeGemini extends GeminiRemoteSource {
  FakeGemini(this._onGenerate) : super(Dio(), ApiKeyStore());
  final Generate _onGenerate;

  @override
  Future<String> generate({
    required String system,
    required List<Map<String, dynamic>> contents,
  }) =>
      _onGenerate(system, contents);
}

DioException _dioError(int? statusCode) {
  final options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    response: statusCode == null
        ? null
        : Response(requestOptions: options, statusCode: statusCode),
  );
}

Future<Result<String>> _askWith(Generate onGenerate) =>
    AssistantRepositoryImpl(FakeGemini(onGenerate)).ask('hello', const []);

void main() {
  test('success returns the answer and sends the new question last', () async {
    List<Map<String, dynamic>>? sent;
    final repo = AssistantRepositoryImpl(FakeGemini((system, contents) async {
      sent = contents;
      return 'Midterm starts on 20 October.';
    }));

    final r = await repo.ask('When?', const [
      ChatMessage(ChatRole.user, 'Hi'),
      ChatMessage(ChatRole.assistant, 'Hello!'),
    ]);

    expect(r, isA<Ok<String>>());
    expect((r as Ok<String>).value, 'Midterm starts on 20 October.');
    expect(sent, hasLength(3));
    expect(sent![0]['role'], 'user');
    expect(sent![1]['role'], 'model');
    expect(sent![2]['role'], 'user');
  });

  test('missing API key becomes an AuthFailure', () async {
    final r = await _askWith((_, __) async => throw const MissingApiKey());
    final failure = (r as Err<String>).failure;
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Set your AI API key first');
  });

  test('a rejected key (403) becomes an AuthFailure', () async {
    final r = await _askWith((_, __) async => throw _dioError(403));
    expect((r as Err<String>).failure, isA<AuthFailure>());
  });

  test('rate limit (429) becomes a NetworkFailure that says to wait', () async {
    final r = await _askWith((_, __) async => throw _dioError(429));
    final failure = (r as Err<String>).failure;
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, contains('Too many requests'));
  });

  test('server or connection errors become a "busy" NetworkFailure', () async {
    final r500 = await _askWith((_, __) async => throw _dioError(500));
    final rOffline = await _askWith((_, __) async => throw _dioError(null));
    expect((r500 as Err<String>).failure.message, contains('busy'));
    expect((rOffline as Err<String>).failure.message, contains('busy'));
  });

  test('an unreadable response becomes a NetworkFailure', () async {
    final r = await _askWith(
        (_, __) async => throw const FormatException('Empty or blocked'));
    final failure = (r as Err<String>).failure;
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, 'Unexpected AI response');
  });
}
