class User {
  final String id;
  final String username;
  final String bio;
  final String email;
  final String avatarImg;
  final String registrationDate;

  User({
    required this.id,
    required this.avatarImg,
    required this.username,
    required this.bio,
    required this.email,
    required this.registrationDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String,
        bio: json['bio'] as String,
        email: json['email'] as String,
        avatarImg: json['avatar_img'] as String,
        registrationDate: json['registrationDate'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'bio': bio,
        'email': email,
        'avatar_img': avatarImg,
        'registrationDate': registrationDate,
      };
}

/// Clase para envíos parciales (solo los campos que cambian)
class UserUpdate {
  final String? username;
  final String? bio;
  final String? avatarImg;

  UserUpdate({
    this.username,
    this.bio,
    this.avatarImg,
  });

  /// Genera un JSON únicamente con los campos no nulos
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (avatarImg != null) data['avatar_img'] = avatarImg;
    return data;
  }
}
