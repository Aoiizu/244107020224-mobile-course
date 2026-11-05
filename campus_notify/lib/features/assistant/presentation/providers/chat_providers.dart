import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/privacy.dart';
import '../../../../core/result.dart';
import '../../../../shared/data/api_key_store.dart';
import '../../data/assistant_repository_impl.dart';
import '../../data/gemini_remote_source.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../domain/usecases/ask_assistant.dart';

final apiKeyStoreProvider = Provider((_) => ApiKeyStore());

// Separate Dio on purpose: the campus Dio adds the campus Bearer token,
// which must never be sent to a third-party AI provider.
final aiDioProvider = Provider<Dio>((_) => Dio());

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) =>
    AssistantRepositoryImpl(GeminiRemoteSource(
        ref.watch(aiDioProvider), ref.watch(apiKeyStoreProvider))));

final askAssistantProvider =
    Provider((ref) => AskAssistant(ref.watch(assistantRepositoryProvider)));

class ChatState {
  const ChatState({this.messages = const [], this.loading = false, this.error});

  final List<ChatMessage> messages;
  final bool loading;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
    bool clearError = false,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  /// Returns true when the question was answered.
  Future<bool> send(String text) async {
    if (state.loading) return false;
    state = state.copyWith(loading: true, clearError: true);
    final history = state.messages;
    final r = await ref.read(askAssistantProvider).call(text, history);
    if (r is Ok<String>) {
      state = state.copyWith(
        messages: [
          ...history,
          // Store the redacted text so later turns never resend raw data.
          ChatMessage(ChatRole.user, redactSensitive(text.trim())),
          ChatMessage(ChatRole.assistant, r.value),
        ],
        loading: false,
      );
      return true;
    }
    state = state.copyWith(
      loading: false,
      error: (r as Err<String>).failure.message,
    );
    return false;
  }

  Future<void> saveApiKey(String key) =>
      ref.read(apiKeyStoreProvider).save(key.trim());

  void clearChat() => state = const ChatState();
}

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
