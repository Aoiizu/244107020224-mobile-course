import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts.dart';
import '../data/provider.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});
  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: FilledButton(
            onPressed: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
            child: const Text('Retry'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Posts Paged')),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: state.hasMore
                    ? const CircularProgressIndicator()
                    : const Text('All data loaded.'),
              ),
            );
          }
          final post = state.items[index];
          return ListTile(
            leading: CircleAvatar(child: Text(post.id.toString())),
            title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        },
      ),
    );
  }
}