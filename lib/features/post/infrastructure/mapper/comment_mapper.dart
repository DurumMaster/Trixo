import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class CommentMapper {
  static Comment fromMap(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      postId: data['post_id'] as String,
      userId: data['userId'] as String,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toMap(Comment comment) {
    return {
      'userId': comment.userId,
      'text': comment.text,
      'createdAt': comment.createdAt,
      'targetType': 'post',
      'post_id': comment.postId,
    };
  }
}
