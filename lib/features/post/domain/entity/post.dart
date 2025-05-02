import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

class Post {
  final int id;
  final String caption;
  final List<String> images;
  final String createdAt;
  final int likesCount;
  final int commentsCount;
  final List<String> tags;
  final User? user;

  Post({
    required this.id,
    required this.caption,
    required this.images,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.tags,
    this.user,
  });

  Post copyWith({
    int? id,
    String? caption,
    List<String>? images,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
    List<String>? tags,
    User? user,
  }) {
    return Post(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      tags: tags ?? this.tags,
      user: user ?? this.user,
    );
  }
}
