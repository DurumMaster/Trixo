import 'dart:math';

import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    final random = Random();
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ??
          'Usuario${random.nextInt(9000) + 1000}',
      bio: json['bio']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarImg: json['avatar_img']?.toString() ?? '',
      registrationDate: json['registration_date']?.toString() ?? '',
    );
  }
}
