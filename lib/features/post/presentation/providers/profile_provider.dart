import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/infrastructure/post_infrastructure.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

final profileRepositoryProvider = Provider<PostRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return PostRepositoryImpl(PostDatasourceImpl(getAccessToken: () async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    return await user.getIdToken();
  }));
});

final profileProvider =
    StateNotifierProvider.family<ProfileNotifier, ProfileState, String>(
  (ref, userId) =>
      ProfileNotifier(ref.watch(profileRepositoryProvider), userId),
);

class ProfileNotifier extends StateNotifier<ProfileState> {
  final PostRepository repository;
  final String userId;
  static const int pageSize = 10;
  bool _isLoadingMorePosts = false;
  bool _isLoadingMoreLikedPosts = false;

  ProfileNotifier(this.repository, this.userId) : super(ProfileState()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await repository.getUser(userId);
      final posts = await repository.getUserPosts(userId, pageSize, 0);
      final likedPosts = await repository.getLikedPosts(userId, pageSize, 0);
      state = state.copyWith(
        user: user,
        posts: posts,
        likedPosts: likedPosts,
        postsOffset: posts.length,
        likedPostsOffset: likedPosts.length,
        hasMorePosts: posts.length == pageSize,
        hasMoreLikedPosts: likedPosts.length == pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> loadMorePosts({ScrollController? scrollController}) async {
    if (_isLoadingMorePosts || !state.hasMorePosts) return;
    _isLoadingMorePosts = true;

    try {
      final newPosts = await repository.getUserPosts(
        userId,
        pageSize,
        state.postsOffset,
      );

      final existingIds = state.posts.map((e) => e.id).toSet();
      final filteredNewPosts =
          newPosts.where((p) => !existingIds.contains(p.id)).toList();

      final updatedPosts = [...state.posts, ...filteredNewPosts];

      state = state.copyWith(
        posts: updatedPosts,
        postsOffset: state.postsOffset + filteredNewPosts.length,
        hasMorePosts: filteredNewPosts.length == pageSize,
      );

      if (scrollController != null && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.offset + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      // Error opcional
    } finally {
      _isLoadingMorePosts = false;
    }
  }

  Future<void> loadMoreLikedPosts({ScrollController? scrollController}) async {
    if (_isLoadingMoreLikedPosts || !state.hasMoreLikedPosts) return;
    _isLoadingMoreLikedPosts = true;

    try {
      final newLikedPosts = await repository.getLikedPosts(
        userId,
        pageSize,
        state.likedPostsOffset,
      );

      final existingIds = state.likedPosts.map((e) => e.id).toSet();
      final filteredNewLiked =
          newLikedPosts.where((p) => !existingIds.contains(p.id)).toList();

      final updatedLikedPosts = [...state.likedPosts, ...filteredNewLiked];

      state = state.copyWith(
        likedPosts: updatedLikedPosts,
        likedPostsOffset: state.likedPostsOffset + filteredNewLiked.length,
        hasMoreLikedPosts: filteredNewLiked.length == pageSize,
      );

      if (scrollController != null && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.offset + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      // Error opcional
    } finally {
      _isLoadingMoreLikedPosts = false;
    }
  }

  void switchTab(int index) {
    state = state.copyWith(currentTab: index);
  }

  Future<void> toggleLikePost(String postId) async {
    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(
          isLiked: !p.isLiked,
          likesCount: p.likesCount + (p.isLiked ? -1 : 1),
        );
      }
      return p;
    }).toList();

    final updatedLiked = state.likedPosts
        .map((p) {
          if (p.id == postId) {
            return p.copyWith(
              isLiked: !p.isLiked,
              likesCount: p.likesCount + (p.isLiked ? -1 : 1),
            );
          }
          return p;
        })
        .where((p) => p.isLiked)
        .toList();

    state = state.copyWith(
      posts: updatedPosts,
      likedPosts: updatedLiked,
    );

    try {
      await repository.toggleLike(postId);
    } catch (e) {
      state = state.copyWith(
        posts: state.posts,
        likedPosts: state.likedPosts,
      );
      rethrow;
    }
  }
}

class ProfileState {
  final User? user;
  final List<Post> posts;
  final List<Post> likedPosts;
  final int postsOffset;
  final int likedPostsOffset;
  final int currentTab;
  final bool isLoading;
  final Object? error;
  final bool hasMorePosts;
  final bool hasMoreLikedPosts;

  int get followers => 0;
  int get following => 0;
  int get designs => posts.length;

  ProfileState({
    this.user,
    this.posts = const [],
    this.likedPosts = const [],
    this.postsOffset = 0,
    this.likedPostsOffset = 0,
    this.currentTab = 0,
    this.isLoading = false,
    this.error,
    this.hasMorePosts = true,
    this.hasMoreLikedPosts = true,
  });

  ProfileState copyWith({
    User? user,
    List<Post>? posts,
    List<Post>? likedPosts,
    int? postsOffset,
    int? likedPostsOffset,
    int? currentTab,
    bool? isLoading,
    Object? error,
    bool? hasMorePosts,
    bool? hasMoreLikedPosts,
  }) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      likedPosts: likedPosts ?? this.likedPosts,
      postsOffset: postsOffset ?? this.postsOffset,
      likedPostsOffset: likedPostsOffset ?? this.likedPostsOffset,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      hasMoreLikedPosts: hasMoreLikedPosts ?? this.hasMoreLikedPosts,
    );
  }
}
