import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        avatarImg: json['avatar_img'] as String,
        registrationDate: json['registration_date'] as String,
      );
}
