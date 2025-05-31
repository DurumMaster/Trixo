import 'package:trixo_frontend/features/auth/domain/datasource/auth_datasource.dart';
import 'package:trixo_frontend/features/auth/domain/entity/user.dart';
import 'package:trixo_frontend/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<void> registerUser({
    required String id,
    required String username,
    required String email,
    required String avatar_img,
    required DateTime registration_date,
  }) {
    return datasource.registerUser(
      id: id,
      username: username,
      email: email,
      avatar_img: avatar_img,
      registration_date: registration_date,
    );
  }

  @override
  Future<void> saveUserPreferences(
      {required List<String> preferences, required String userId}) {
    return datasource.saveUserPreferences(
        preferences: preferences, userId: userId);
  }

  @override
  Future<bool> hasPreferences({required String userId}) {
    return datasource.hasPreferences(userId: userId);
  }

  @override
  Future<User> getUserById({required String userId}) {
    return datasource.getUserById(userId: userId);
  }
  
  @override
  Future<bool> updateUserPreferences({required String userId, required List<String> preferences}) {
    return datasource.updateUserPreferences(userId: userId, preferences: preferences);
  }
}
