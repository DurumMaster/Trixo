import 'package:trixo_frontend/features/auth/domain/entity/user.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class PostRepositoryImpl extends PostRepository {
  final PostDatasource datasource;

  PostRepositoryImpl(this.datasource);

  @override
  Future<List<Post>> getPostsByPageRanking(int limit, int offset) {
    return datasource.getPostsByPageRanking(limit, offset);
  }

  @override
  Future<Post> toggleLike(String postId) async {
    return await datasource.toggleLike(postId);
  }

  @override
  Future<List<Comment>> getComments(String postId) {
    return datasource.getComments(postId);
  }

  @override
  Future<void> sendComment(Comment comment) {
    return datasource.sendComment(comment);
  }

  @override
  Future<List<Post>> getLikedPosts(String userId, int limit, int offset) {
    return datasource.getLikedPosts(userId, limit, offset);
  }

  @override
  Future<User> getUser(String userId) {
    return datasource.getUser(userId);
  }

  @override
  Future<List<Post>> getUserPosts(String userId, int limit, int offset) {
    return datasource.getUserPosts(userId, limit, offset);
  }

  @override
  Future<List<String>> pickImages() async {
    final xFiles = await datasource.pickImages();
    return xFiles.map((xFile) => xFile.path).toList();
  }

  @override
  Future<List<Post>> getForYouPosts(String userId, int limit, int offset) {
    return datasource.getForYouPosts(userId, limit, offset);
  }

  @override
  Future<void> sendReport(String postId, String reason) {
    return datasource.sendReport(postId, reason);
  }

  @override
  Future<List<Post>> getRecentPosts(int limit, int offset) {
    return datasource.getRecentPosts(limit, offset);
  }

  @override
  Future<List<Post>> getAllPosts(int limit, int offset) {
    return datasource.getAllPosts(limit, offset);
  }

 @override
  Future<void> submitPost(PostDto post) async {
    // 1) Subir imágenes y obtener URLs
    final urls = await datasource.uploadImages(post.images);

    // 2) Crear DTO con solo lo que el backend necesita
    final dto = PostDto(
      caption: post.caption,
      images: urls,
      tags: post.tags,
      user: post.user,
      createdAt: post.createdAt,
    );

    // 3) Llamar al endpoint de creación
    await datasource.createPost(dto);
  }
}
