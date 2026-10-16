import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'api_client.dart';
import 'models/post.dart';
import 'models/comment.dart';
import 'repositories/post_repository.dart';
import 'repositories/comment_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
        PostListNotifier.new,
        retry: (retryCount, error) => null);

final commentListProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Slow connection or timeout. Check your internet and retry.';
      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data not found (404).';
        if (code == 401 || code == 403) {
          return 'Access denied ($code). Check your credentials.';
        }
        return 'Server problem ($code). Try again later.';
      default:
        return 'A network error occurred. Try again.';
    }
  }
  return 'An unexpected error occurred: $error';
}

Future<List<Post>> readPostsOnce(ProviderContainer container) async {
  final completer = Completer<List<Post>>();
  late final ProviderSubscription sub;
  sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      next.whenOrNull(
        data: (posts) {
          if (!completer.isCompleted) completer.complete(posts);
          sub.close();
        },
        error: (err, st) {
          if (!completer.isCompleted) completer.completeError(err);
          sub.close();
        },
      );
    },
    fireImmediately: true,
  );
  return completer.future;
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) async {
  try {
    await readPostsOnce(container);
    return null;
  } catch (e) {
    return e;
  }
}