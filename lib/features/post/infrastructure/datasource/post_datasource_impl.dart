import 'package:dio/dio.dart';

import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/infrastructure/post_infrastructure.dart';
import 'package:trixo_frontend/config/config.dart';

class PostDatasourceImpl extends PostDatasource {
  late final Dio dio;
  final Future<String?> Function() getAccessToken;

  PostDatasourceImpl({required this.getAccessToken})
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
  Future<List<Post>> getPostsByPageRanking(
      {int limit = 10, int offset = 0}) async {
    final response = await dio.get('/posts/top?limit=$limit');
    final List<Post> posts = [];

    for (final post in response.data ?? []) {
      posts.add(PostMapper.postJsonToEntity(post));
    }

    return posts;
  }

  @override
  Future<Post> toggleLike(String postId) async {
    try {
      final response = await dio.post('/posts/$postId/like');
      return PostMapper.postJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autenticado');
      }
      throw Exception('Error al actualizar el like: ${e.message}');
    }
  }
}
