import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(offline ? 'Posts (cached, offline)' : 'Posts (cache-first)'),
      ),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('No cached posts yet. Open once while online.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(list[i].title),
                  subtitle: Text(list[i].body, maxLines: 2),
                ),
              ),
      ),
    );
  }
}