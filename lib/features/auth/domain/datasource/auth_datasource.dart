import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

abstract class AuthDataSource {
  Future<void> registerUser({
    required String id,
    required String username,
    required String email,
    required String avatar_img,
    required DateTime registration_date,
  });

  Future<void> saveUserPreferences({
    required List<String> preferences,
    required String userId,
  });

  Future<bool> hasPreferences({required String userId});

  Future<User> getUserById({required String userId});
}
