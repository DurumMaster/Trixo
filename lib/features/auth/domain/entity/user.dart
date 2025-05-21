class User {
  final String id;
  final String username;
  final String bio;
  final String email;
  final String avatarImg;
  final String registrationDate;

  User(
      {required this.id,
      required this.avatarImg,
      required this.username,
      required this.bio,
      required this.email,
      required this.registrationDate});
}
