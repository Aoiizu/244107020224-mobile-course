import '../../../../core/result.dart';
import '../entities/chat_message.dart';

abstract class AssistantRepository {
  /// [history] holds the earlier turns only, not the new [question].
  Future<Result<String>> ask(String question, List<ChatMessage> history);
}
