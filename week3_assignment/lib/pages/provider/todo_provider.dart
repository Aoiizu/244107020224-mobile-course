import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  final String title;
  final bool done;

  const Todo({required this.title, this.done = false});

  Todo copyWith({String? title, bool? done}) {
    return Todo(title: title ?? this.title, done: done ?? this.done);
  }
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => [];

  void add(String title) {
    state = [...state, Todo(title: title)];
  }

  void toggle(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(done: !state[i].done) else state[i],
    ];
  }

  void remove(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

final unfinishedTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((t) => !t.done).toList();
});