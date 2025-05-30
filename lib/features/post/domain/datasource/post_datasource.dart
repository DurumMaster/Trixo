import 'package:image_picker/image_picker.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';

abstract class PostDatasource {
  Future<List<Post>> getPostsByPageRanking(int limit, int offset);
  Future<List<Post>> getForYouPosts(String userID, int limit, int offset);
  Future<List<Post>> getRecentPosts(int limit, int offset);
  Future<List<Post>> getAllPosts(int limit, int offset);
  Future<List<Post>> searchPosts(String query, int limit, int offset);
  Future<Post> toggleLike(String postId);
  Future<List<Comment>> getComments(String postId);
  Future<void> sendComment(Comment comment);
  Future<User> getUser(String userId);
  Future<List<Post>> getUserPosts(String userId, int limit, int offset);
  Future<List<Post>> getLikedPosts(String userId, int limit, int offset);
  Future<List<XFile>> pickImages();
  Future<void> sendReport(String postId, String reason);
  Future<List<String>> uploadImages(List<String> localPaths);
  Future<void> createPost(PostDto post);
  Future<String> uploadAvatar(String userId, String avatarPath);
  Future<bool> updateUser(String uid, UserUpdate user);
}
