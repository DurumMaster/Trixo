abstract class AuthRepository {
  /// Registers a new user with email, username, and password.
  Future<void> registerUser({
    required String email,
    required String username,
    required String password,
  });
}