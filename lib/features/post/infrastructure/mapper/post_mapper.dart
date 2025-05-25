import 'package:trixo_frontend/features/auth/infrastructure/auth_infrastructure.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class PostMapper {
  static Post postJsonToEntity(Map<String, dynamic> json) => Post(
        id: json['id'] ?? '',
        caption: json['caption'] ?? '',
        images: (json['images'] as List?)?.cast<String>() ?? [],
        createdAt: json['created_at'] ?? '',
        likesCount: json['likes_count'] ?? 0,
        commentsCount: json['comments_count'] ?? 0,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        user: UserMapper.userJsonToEntity(json['user'] as Map<String, dynamic>),
        isLiked: json['is_liked'] ?? false,
      );
}
