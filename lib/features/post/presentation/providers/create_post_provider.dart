import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

class PostSubmitState {
  final String description;
  final List<String> tags;
  final bool isLoading;
  final String? error;

  PostSubmitState({
    this.description = '',
    this.tags = const [],
    this.isLoading = false,
    this.error,
  });

  PostSubmitState copyWith({
    String? description,
    List<String>? tags,
    bool? isLoading,
    String? error,
  }) => PostSubmitState(
        description: description ?? this.description,
        tags: tags ?? this.tags,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class PostSubmitNotifier extends StateNotifier<PostSubmitState> {
  final PostRepository _repo;
  final List<String> images;

  PostSubmitNotifier(this._repo, this.images)
      : super(PostSubmitState());

  void setDescription(String text) {
    state = state.copyWith(description: text);
  }

  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  Future<bool> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final post = Post(
        id: '',
        caption: state.description,
        images: images,
        createdAt: DateTime.now().toIso8601String(),
        likesCount: 0,
        commentsCount: 0,
        tags: state.tags,
        user: null,
        isLiked: false,
      );
      //await _repo.submitPost(post);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final postSubmitProvider = StateNotifierProvider.family<
    PostSubmitNotifier, PostSubmitState, List<String>>((ref, images) {
  final repo = ref.read(postRepositoryProvider);
  return PostSubmitNotifier(repo, images);
});