import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Note')),
      body: note.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (n) => n == null
            ? const Center(child: Text('Note not found'))
            : _Editor(note: n),
      ),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.note});
  final Note note;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final _title = TextEditingController(text: widget.note.title);
  late final _body = TextEditingController(text: widget.note.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(noteRepositoryProvider).updateNote(
          widget.note.id!,
          title: _title.text.trim(),
          body: _body.text.trim(),
        );
    ref.invalidate(notesProvider);
    ref.invalidate(noteByIdProvider(widget.note.id!));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _body,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}