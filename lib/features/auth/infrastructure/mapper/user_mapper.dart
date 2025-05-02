import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
        id: json['id'] ?? 0,
        avatarImg: json['avatar_img'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        token: json['token'] ?? '',
      );
}