import 'package:trixo_frontend/features/auth/domain/datasource/auth_datasource.dart';
import 'package:trixo_frontend/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<void> registerUser({
    required String email,
    required String username,
    required String password,
  }) {
    return datasource.registerUser(
      email: email,
      username: username,
      password: password,
    );
  }

  @override
  Future<void> saveUserPreferences({required List<String> preferences}) {
    return datasource.saveUserPreferences(preferences: preferences);
  }
}
