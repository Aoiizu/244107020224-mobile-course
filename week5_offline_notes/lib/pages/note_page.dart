import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    if (ref.read(forceOfflineProvider)) {
      _snack(context, 'Offline: sync postponed');
      return;
    }
    final n = await syncNotes(ref.read(noteRepositoryProvider));
    ref.invalidate(notesProvider);
    if (context.mounted) _snack(context, 'Synced $n note(s)');
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      await ref
          .read(noteRepositoryProvider)
          .addNote(title: titleCtrl.text.trim(), body: bodyCtrl.text.trim());
      ref.invalidate(notesProvider); // refresh after mutation
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: offline ? 'Simulated offline' : 'Online',
            icon: Icon(offline ? Icons.wifi_off : Icons.wifi),
            onPressed: () => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Posts (cache-first)',
            icon: const Icon(Icons.article_outlined),
            onPressed: () => context.push('/posts'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          Badge(
            label: Text('$dirty'),
            isLabelVisible: dirty > 0,
            child: IconButton(
              tooltip: 'Sync',
              icon: const Icon(Icons.sync),
              onPressed: () => _sync(context, ref),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(notesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No notes yet. Tap + to add one.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notesProvider),
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final note = list[i];
                return NoteTile(
                  note: note,
                  onTap: () => context.push('/note/${note.id}'),
                  onDelete: () async {
                    await ref
                        .read(noteRepositoryProvider)
                        .deleteNote(note.id!);
                    ref.invalidate(notesProvider);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}