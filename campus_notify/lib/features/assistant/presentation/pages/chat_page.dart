import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await ref.read(chatProvider.notifier).send(_input.text);
    if (ok) _input.clear();
  }

  Future<void> _askForKey() async {
    final key = await showDialog<String>(
      context: context,
      builder: (_) => const _ApiKeyDialog(),
    );
    if (key == null || key.trim().isEmpty) return;
    await ref.read(chatProvider.notifier).saveApiKey(key);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Assistant'), actions: [
        IconButton(
          tooltip: 'Set API key',
          icon: const Icon(Icons.key),
          onPressed: _askForKey,
        ),
        IconButton(
          tooltip: 'Clear chat',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => ref.read(chatProvider.notifier).clearChat(),
        ),
      ]),
      body: Column(children: [
        Expanded(
          child: chat.messages.isEmpty
              ? const Center(child: Text('Ask about campus announcements.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: chat.messages.length,
                  itemBuilder: (_, i) => _Bubble(chat.messages[i]),
                ),
        ),
        if (chat.loading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Thinking...'),
            ]),
          ),
        if (chat.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${chat.error!} You can retry, or browse the announcement list.',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ask something...',
                    helperText: 'Do not share ID or phone numbers',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: chat.loading ? null : _send,
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();
  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI API key'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Paste your key'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.message);
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == ChatRole.user;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: mine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.text),
      ),
    );
  }
}