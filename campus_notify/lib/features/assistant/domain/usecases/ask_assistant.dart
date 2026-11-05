import '../../../../core/failures.dart';
import '../../../../core/privacy.dart';
import '../../../../core/result.dart';
import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

class AskAssistant {
  AskAssistant(this._repo, {this.maxQuestions = 20, this.maxLength = 500});

  final AssistantRepository _repo;
  final int maxQuestions;
  final int maxLength;
  int _used = 0;

  Future<Result<String>> call(
      String question, List<ChatMessage> history) async {
    final q = redactSensitive(question.trim());
    if (q.isEmpty) {
      return const Err(ValidationFailure('Type a question first'));
    }
    if (q.length > maxLength) {
      return Err(ValidationFailure('Keep it under $maxLength characters'));
    }
    if (_used >= maxQuestions) {
      return const Err(
          ValidationFailure('Question limit reached for this session'));
    }
    _used++;
    return _repo.ask(q, history);
  }
}
