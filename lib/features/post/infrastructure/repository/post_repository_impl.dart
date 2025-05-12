import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class PostRepositoryImpl extends PostRepository {
  final PostDatasource datasource;

  PostRepositoryImpl(this.datasource);

  @override
  Future<List<Post>> getPostsByPageRanking({int limit = 10, int offset = 0}) {
    return datasource.getPostsByPageRanking(limit: limit, offset: offset);
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
}
