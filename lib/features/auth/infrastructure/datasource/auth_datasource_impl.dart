import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trixo_frontend/features/auth/domain/entity/user.dart' as trixo_user;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/domain/datasource/auth_datasource.dart';
import 'package:trixo_frontend/features/auth/infrastructure/auth_infrastructure.dart';

class AuthDatasourceImpl extends AuthDataSource {
  late final Dio dio;
  final Future<String?> Function() getAccessToken;

  AuthDatasourceImpl({required this.getAccessToken})
      : dio = Dio(BaseOptions(baseUrl: Environment.apiUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
  }

  @override
  Future<void> registerUser({
    required String id,
    required String username,
    required String email,
    required String avatar_img,
    required DateTime registration_date,
  }) async {
    try {
      final response = await dio.post(
        '/users/register',
        data: {
          'id': id,
          'username': username,
          'email': email,
          'avatar_img': avatar_img,
          'registration_date': registration_date.toIso8601String(),
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to register user');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid input: ${e.response?.data}');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error: ${e.response?.data}');
      }
      throw Exception('Error during registration: ${e.message}');
    }
  }

  @override
  Future<void> saveUserPreferences({
    required List<String> preferences,
    required String userId,
  }) async {
    try {
      final response = await dio.post(
        '/users/registerPreferences',
        data: {
          'userID': userId,
          'preferences': preferences,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update user preferences');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid input: ${e.response?.data}');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error: ${e.response?.data}');
      }
      throw Exception('Error during updating user preferences: ${e.message}');
    }
  }

  @override
  Future<List<String>> getUserPreferences({required String userId}) async {
    try {
      final response = await dio.get('/users/$userId/preferencesList');

      if (response.statusCode != 200) {
        throw Exception('Failed to get user preferences');
      }

      return List<String>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Error getting preferences: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<bool> hasPreferences({required String userId}) async {
    try {
      final response = await dio.get('/users/$userId/preferences');

      if (response.statusCode != 200) {
        throw Exception('Failed to get user preferences');
      }

      return response.data == true;
    } on DioException catch (e) {
      throw Exception(
          'Error getting preferences: ${e.response?.data ?? e.message}');
    }
  }

@override
  Future<bool> updateUserPreferences({
    required String userId,
    required List<String> preferences,
  }) async {
    try {
      final response = await dio.put<String>(
        '/users/$userId/preferences',
        data: preferences,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return false;
      }
      else if (e.response?.statusCode == 500) {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logOut() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove("jwt_token");
    await FirebaseAuth.instance.signOut();
  }
  
  @override
  Future<trixo_user.User> getUserById({required String userId}) async {
    try {
      final response = await dio.get('/users/$userId');

      if (response.statusCode != 200) {
        return UserMapper.userJsonToEntity(response.data);
      }

      return UserMapper.userJsonToEntity(response.data);
    } catch (e) {
      return UserMapper.userJsonToEntity({
        'id': "",
        'username': 'Unknown',
        'email': 'Unknown',
        'avatar_img': '',
        'registration_date': "",
      });
    }
  }
}
