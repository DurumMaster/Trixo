import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class CommentMapper {
  static Comment fromMap(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      postId: data['post_id'] as String,
      userId: data['user_id'] as String,
      text: data['text'] as String,
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  static Map<String, dynamic> toMap(Comment comment) {
    return {
      'user_id': comment.userId,
      'text': comment.text,
      'created_at': comment.createdAt.toUtc().toIso8601String(),
      'targetType': 'post',
      'post_id': comment.postId,
    };
  }
}
