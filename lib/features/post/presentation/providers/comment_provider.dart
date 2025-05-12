import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

class CommentState {
  final List<Comment> comments;
  final bool isLoading;

  CommentState({
    this.comments = const [],
    this.isLoading = false,
  });

  CommentState copyWith({
    List<Comment>? comments,
    bool? isLoading,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, CommentState, String>(
  (ref, postId) => CommentNotifier(postId, ref.watch(postRepositoryProvider)),
);

class CommentNotifier extends StateNotifier<CommentState> {
  final String postId;
  final PostRepository repository;

  CommentNotifier(this.postId, this.repository) : super(CommentState());

  Future<void> loadComments() async {
    try {
      state = state.copyWith(isLoading: true);
      final comments = await repository.getComments(postId);
      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Aquí podrías manejar errores si lo necesitas
    }
  }

  Future<void> sendComment(Comment comment) async {
    try {
      await repository.sendComment(comment);
      state = state.copyWith(comments: [comment, ...state.comments]);
    } catch (e) {
      // Manejador de errores opcional
    }
  }
}
