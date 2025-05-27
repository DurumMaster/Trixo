import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final String caption;
  final List<String> images;
  final String createdAt;
  final int likesCount;
  final int commentsCount;
  final List<String> tags;
  final User? user;
  final bool isLiked;

  Post(
      {required this.id,
      required this.caption,
      required this.images,
      required this.createdAt,
      required this.likesCount,
      required this.commentsCount,
      required this.tags,
      this.user,
      required this.isLiked});

  Post copyWith({
    String? id,
    String? caption,
    List<String>? images,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
    List<String>? tags,
    User? user,
    bool? isLiked,
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
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PostDto {
  final String id;
  final String caption;
  final List<String> images;
  final List<String> tags;
  final User user;
  final Timestamp createdAt;

  PostDto({
    String? id,
    required this.caption,
    required this.images,
    required this.tags,
    required this.user,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'caption': caption,
        'images': images,
        'tags': tags,
        'user': user.toJson(),
        'created_at': createdAt.toDate().toIso8601String(),
      };
}
