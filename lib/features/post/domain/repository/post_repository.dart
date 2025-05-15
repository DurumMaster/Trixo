import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

abstract class PostRepository {
  Future<List<Post>> getPostsByPageRanking({int limit = 10, int offset = 0});
  Future<Post> toggleLike(String postId);
  Future<List<Comment>> getComments(String postId);
  Future<void> sendComment(Comment comment);
  Future<User> getUser(String userId);
  Future<List<Post>> getUserPosts(String userId, int limit);
  Future<List<Post>> getLikedPosts(String userId, int limit);
}
