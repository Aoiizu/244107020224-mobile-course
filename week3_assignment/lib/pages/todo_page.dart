import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/todo_provider.dart';

class TodoTile extends ConsumerWidget {
  final int index;
  final Todo todo;

  const TodoTile({super.key, required this.index, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: todo.done,
        onChanged: (_) => ref.read(todoListProvider.notifier).toggle(index),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => ref.read(todoListProvider.notifier).remove(index),
      ),
    );
  }
}

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  bool _showUnfinishedOnly = false;

  @override
  Widget build(BuildContext context) {
    final todos = _showUnfinishedOnly
        ? ref.watch(unfinishedTodosProvider)
        : ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
        actions: [
          IconButton(
            icon: Icon(_showUnfinishedOnly
                ? Icons.filter_alt
                : Icons.filter_alt_outlined),
            tooltip: _showUnfinishedOnly ? 'Show all' : 'Show unfinished only',
            onPressed: () =>
                setState(() => _showUnfinishedOnly = !_showUnfinishedOnly),
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(child: Text('No tasks yet'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) => TodoTile(
                index: index,
                todo: todos[index],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New task'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}