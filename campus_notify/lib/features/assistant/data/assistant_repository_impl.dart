import 'package:dio/dio.dart';
import '../../../core/failures.dart';
import '../../../core/result.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/assistant_repository.dart';
import 'gemini_remote_source.dart';

const campusSystemPrompt =
    'You are the Campus Notify assistant. Answer in the same language as the '
    'user, in at most 3 sentences. Only help with campus announcements, '
    'schedules and study questions. Never ask for or repeat personal data '
    '(ID numbers, phone numbers, passwords). If you are not sure, say so.';

class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._remote);
  final GeminiRemoteSource _remote;

  @override
  Future<Result<String>> ask(String question, List<ChatMessage> history) async {
    final contents = <Map<String, dynamic>>[
      for (final m in history)
        {
          'role': m.role == ChatRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.text}
          ],
        },
      {
        'role': 'user',
        'parts': [
          {'text': question}
        ],
      },
    ];

    try {
      final text = await _remote.generate(
        system: campusSystemPrompt,
        contents: contents,
      );
      return Ok(text);
    } on MissingApiKey {
      return const Err(AuthFailure('Set your AI API key first'));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 400 || code == 401 || code == 403) {
        return const Err(AuthFailure('The API key was rejected'));
      }
      if (code == 429) {
        return const Err(NetworkFailure('Too many requests, try again later'));
      }
      return const Err(NetworkFailure('AI service is busy, try again later'));
    } on FormatException {
      return const Err(NetworkFailure('Unexpected AI response'));
    }
  }
}
