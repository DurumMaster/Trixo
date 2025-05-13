import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

abstract class AuthRepository {
  /// Registers a new user with email, username, and password.
  Future<void> registerUser({
    required String email,
    required String username,
    required String password,
  });

  Future<void> saveUserPreferences({
    required List<String> preferences,
    required String userId,
  });

  Future<bool> hasPreferences({required String userId});

  Future<User> getUserById({required String userId});
}
