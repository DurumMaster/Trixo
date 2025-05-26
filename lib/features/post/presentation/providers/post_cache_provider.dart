import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

final postCacheProvider =
    StateNotifierProvider<PostCacheNotifier, Map<String, Post>>(
  (ref) => PostCacheNotifier(),
);

class PostCacheNotifier extends StateNotifier<Map<String, Post>> {
  PostCacheNotifier() : super({});

  void upsertAll(List<Post> posts) {
    final updated = Map<String, Post>.from(state);
    for (final post in posts) {
      updated[post.id] = post;
    }
    state = updated;
  }

  void replace(Post post) {
    state = {
      ...state,
      post.id: post,
    };
  }

  Post? get(String id) => state[id];
}