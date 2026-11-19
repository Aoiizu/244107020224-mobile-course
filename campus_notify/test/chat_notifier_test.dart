import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notification_app/core/failures.dart';
import 'package:campus_notification_app/core/result.dart';
import 'package:campus_notification_app/features/assistant/domain/entities/chat_message.dart';
import 'package:campus_notification_app/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:campus_notification_app/features/assistant/presentation/providers/chat_providers.dart';

class FakeAssistantRepo implements AssistantRepository {
  FakeAssistantRepo(this.result);
  Result<String> result;
  int calls = 0;
  List<ChatMessage> lastHistory = const [];

  @override
  Future<Result<String>> ask(String question, List<ChatMessage> history) async {
    calls++;
    lastHistory = history;
    return result;
  }
}

ProviderContainer _container(FakeAssistantRepo repo) {
  final c = ProviderContainer(
    overrides: [assistantRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('a successful question adds the user and assistant messages', () async {
    final repo = FakeAssistantRepo(const Ok('answer'));
    final c = _container(repo);

    final ok = await c.read(chatProvider.notifier).send('When is the exam?');
    final state = c.read(chatProvider);

    expect(ok, isTrue);
    expect(state.loading, isFalse);
    expect(state.error, isNull);
    expect(
        state.messages.map((m) => m.role), [ChatRole.user, ChatRole.assistant]);
    expect(state.messages.last.text, 'answer');
  });

  test('the second question sends the first exchange as history', () async {
    final repo = FakeAssistantRepo(const Ok('answer'));
    final c = _container(repo);

    await c.read(chatProvider.notifier).send('first');
    await c.read(chatProvider.notifier).send('second');

    expect(repo.lastHistory, hasLength(2));
  });

  test('a failure keeps the chat unchanged and exposes the message', () async {
    final repo =
        FakeAssistantRepo(const Err(NetworkFailure('AI service is busy')));
    final c = _container(repo);

    final ok = await c.read(chatProvider.notifier).send('hello');
    final state = c.read(chatProvider);

    expect(ok, isFalse);
    expect(state.messages, isEmpty);
    expect(state.error, 'AI service is busy');
    expect(state.loading, isFalse);
  });

  test('a blank question is rejected before reaching the repository', () async {
    final repo = FakeAssistantRepo(const Ok('never used'));
    final c = _container(repo);

    final ok = await c.read(chatProvider.notifier).send('   ');

    expect(ok, isFalse);
    expect(repo.calls, 0);
    expect(c.read(chatProvider).error, 'Type a question first');
  });

  test('phone numbers are stored redacted in the chat history', () async {
    final repo = FakeAssistantRepo(const Ok('ok'));
    final c = _container(repo);

    await c.read(chatProvider.notifier).send('call 081234567890');

    expect(c.read(chatProvider).messages.first.text, 'call [number]');
  });
}
