class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });
}

Comment copyWith(Comment comment, {
  String? id,
  String? postId,
  String? userId,
  String? text,
  DateTime? createdAt,
}) {
  return Comment(
    id: id ?? comment.id,
    postId: postId ?? comment.postId,
    userId: userId ?? comment.userId,
    text: text ?? comment.text,
    createdAt: createdAt ?? comment.createdAt,
  );
}

