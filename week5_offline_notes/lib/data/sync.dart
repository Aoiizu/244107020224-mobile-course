import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

// ---------- Offline simulation toggle ----------
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---------- Post model ----------
class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> j) => Post(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body};
}

// ---------- Cache helpers ----------
Future<List<Post>> readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows
      .map((r) => Post.fromJson(
          jsonDecode(r['payload'] as String) as Map<String, dynamic>))
      .toList();
}

Future<void> cachePosts(List<Post> posts) async {
  final db = await openNotesDb();
  final now = DateTime.now().toIso8601String();
  final batch = db.batch();
  batch.delete('cached_posts');
  for (final p in posts) {
    batch.insert('cached_posts', {
      'id': p.id,
      'payload': jsonEncode(p.toJson()),
      'cached_at': now,
    });
  }
  await batch.commit(noResult: true);
}

Future<List<Post>> fetchRemotePosts() async {
  final res = await Dio().get<List<dynamic>>(
    'https://jsonplaceholder.typicode.com/posts',
    options: Options(receiveTimeout: const Duration(seconds: 8)),
  );
  return (res.data ?? [])
      .map((e) => Post.fromJson(e as Map<String, dynamic>))
      .toList();
}

// ---------- Cache-first posts ----------
class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final offline = ref.watch(forceOfflineProvider);
    // 1. Return the cache immediately so the UI is never blank offline.
    final cached = await readCachedPosts();
    // 2. Refresh in the background (skipped when offline).
    if (!offline) Future(_refreshInBackground);
    return cached;
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await fetchRemotePosts();
      await cachePosts(fresh);
      state = AsyncData(fresh);
    } catch (_) {
      // Network failure: keep showing the cache.
    }
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

// ---------- Sync dirty notes ----------
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulated upload. In a real project: send each dirty note to the REST
  // API, then mark it clean only on a 2xx response.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}