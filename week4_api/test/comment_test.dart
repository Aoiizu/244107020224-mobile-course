import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson is safe against missing fields', () {
    final comment = Comment.fromJson({'id': 3, 'postId': 1});
    expect(comment.id, 3);
    expect(comment.postId, 1);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('Comment.fromJson handles wrong types gracefully', () {
    final comment = Comment.fromJson({
      'postId': null,
      'id': '5',
      'name': 42,
    });
    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
  });
}