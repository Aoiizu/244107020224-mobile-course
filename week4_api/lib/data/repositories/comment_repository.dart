import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}