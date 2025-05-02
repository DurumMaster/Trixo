import 'package:trixo_frontend/features/post/domain/post_domain.dart';

abstract class PostRepository {
  Future<List<Post>> getPostsByPageRanking({int limit = 10, int offset = 0});
}
