abstract class AuthDataSource {
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
}
