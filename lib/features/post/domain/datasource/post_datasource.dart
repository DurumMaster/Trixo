import 'package:trixo_frontend/features/post/domain/post_domain.dart';

abstract class PostDatasource {
  Future<List<Post>> getPostsByPageRanking({int limit = 10, int offset = 0});
  Future<Post> toggleLike(String postId);
}
