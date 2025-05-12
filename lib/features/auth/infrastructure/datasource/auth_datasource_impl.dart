import 'package:dio/dio.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/domain/datasource/auth_datasource.dart';

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
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/users/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
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
  Future<bool> hasPreferences({required String userId}) async {
    try {
      final response = await dio.get('/users/getPreferences', queryParameters: {
        'userID': userId,
      });

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to get user preferences');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid input: ${e.response?.data}');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error: ${e.response?.data}');
      }
      throw Exception('Error during getting user preferences: ${e.message}');
    }
  }
}
