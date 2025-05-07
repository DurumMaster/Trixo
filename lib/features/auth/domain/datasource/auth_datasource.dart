abstract class AuthDataSource {
  Future<void> registerUser({
    required String email,
    required String username,
    required String password,
  });
}