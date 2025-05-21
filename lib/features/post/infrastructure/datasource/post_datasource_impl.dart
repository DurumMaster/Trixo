import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:trixo_frontend/features/auth/domain/entity/user.dart';
import 'package:trixo_frontend/features/auth/infrastructure/auth_infrastructure.dart';
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
    final response = await dio.get('/posts/top', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    final List<Post> posts = [];

    for (final post in response.data ?? []) {
      posts.add(PostMapper.postJsonToEntity(post));
    }

    return posts;
  }

  @override
  Future<Post> toggleLike(String postId) async {
    try {
      final response = await dio.put('/posts/$postId/like');
      return PostMapper.postJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autenticado');
      }
      throw Exception('Error al actualizar el like: ${e.message}');
    }
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await dio.get('/api/comments/$postId');

      final List<dynamic> data = response.data;

      return data.map<Comment>((item) {
        final map = item as Map<String, dynamic>;
        final id = map['comment_id'] as String;
        return CommentMapper.fromMap(id, map);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener comentarios: $e');
    }
  }

  @override
  Future<void> sendComment(Comment comment) async {
    try {
      final map = CommentMapper.toMap(comment);
      await dio.post('/comments', data: map);
    } catch (e) {
      throw Exception('Error al insertar comentario: $e');
    }
  }

  @override
  Future<List<Post>> getLikedPosts(String userId, int limit, int offset) async {
    try {
      final response =
          await dio.get('/posts/$userId/likedPosts', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final List<Post> posts = [];

      for (final post in response.data ?? []) {
        posts.add(PostMapper.postJsonToEntity(post));
      }

      return posts;
    } on DioException catch (e) {
      throw Exception('Error al obtener likes: ${e.message}');
    }
  }

  @override
  Future<User> getUser(String userId) async {
    try {
      final response = await dio.get('/users/$userId');
      return UserMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener usuario: ${e.message}');
    }
  }

  @override
  Future<List<Post>> getUserPosts(String userId, int limit, int offset) async {
    try {
      final response = await dio.get('/posts/$userId/posts', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      final List<Post> posts = [];

      for (final post in response.data ?? []) {
        posts.add(PostMapper.postJsonToEntity(post));
      }

      return posts;
    } on DioException catch (e) {
      throw Exception('Error al obtener posts: ${e.message}');
    }
  }

  @override
  Future<List<XFile>> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      return images;
    } catch (e) {
      throw Exception('Error al seleccionar imágenes: $e');
    }
  }

  @override
  Future<void> sendReport(String postId, String reason) async {
    try {
      await dio.post("/$postId/report/$reason");
    } catch (e) {
      throw Exception('Error al enviar reporte: $e');
    }
  }
  
  @override
  Future<List<Post>> getForYouPosts(String userID, int limit, int offset) async {
    final response = await dio.get("posts/forYou/$userID", 
        queryParameters: {
          'limit': limit,
          'offset': offset,
        });


    final List<Post> posts = [];
    for (final post in response.data ?? []) {
      posts.add(PostMapper.postJsonToEntity(post));
    }

    return posts;
  }

  @override
  Future<List<Post>> getRecentPosts(int limit, int offset) async {
    final response = await dio.get("posts/recent",
        queryParameters: {
          'limit': limit,
          'offset': offset,
        });

    final List<Post> posts = [];
    for (final post in response.data ?? []) {
      posts.add(PostMapper.postJsonToEntity(post));
    }

    return posts;
  }

}

  // Future<void> deleteComment(String commentId) async {
  //   try {
  //     await dio.post('/delete', data: commentId);
  //   } catch (e) {
  //     throw Exception('Error al eliminar comentario: $e');
  //   }
  // }
