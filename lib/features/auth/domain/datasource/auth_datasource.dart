import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

abstract class AuthDataSource {
  Future<void> registerUser({
    required String id,
    required String username,
    required String email,
    required String avatarImg,
    required DateTime registrationDate,
  });

  Future<void> saveUserPreferences({
    required List<String> preferences,
    required String userId,
  });

  Future<bool> hasPreferences({required String userId});

  Future<bool> updateUserPreferences({
    required String userId,
    required List<String> preferences,
  });

  Future<List<String>> getUserPreferences({required String userId});

  Future<void> logOut();

  Future<User> getUserById({required String userId});
}
