import 'package:trixo_frontend/features/auth/infrastructure/auth_infrastructure.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class PostMapper {
  static postJsonToEntity(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        caption: json['caption'] as String,
        images: List<String>.from(json['images'] as List<dynamic>),
        createdAt: json['created_at'] as String,
        likesCount: json['likes_count'] as int,
        commentsCount: json['comments_count'] as int,
        tags: List<String>.from(json['tags'] as List<dynamic>),
        user:
            UserMapper.userJsonToEntity(json['user'] as Map<String, dynamic>),
      );
}
