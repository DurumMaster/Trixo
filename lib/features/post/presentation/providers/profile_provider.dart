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
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMorePosts) return;
    _isLoadingMorePosts = true;

    try {
      final newPosts = await repository.getUserPosts(
        userId,
        pageSize,
        state.postsOffset,
      );

      if (newPosts.isNotEmpty) {
        state = state.copyWith(
          posts: [...state.posts, ...newPosts],
          postsOffset: state.postsOffset + newPosts.length,
        );
      }
    } catch (e) {
      // Opcional: manejar error al cargar más posts
    } finally {
      _isLoadingMorePosts = false;
    }
  }

  Future<void> loadMoreLikedPosts() async {
    if (_isLoadingMoreLikedPosts) return;
    _isLoadingMoreLikedPosts = true;

    try {
      final newLikedPosts = await repository.getLikedPosts(
        userId,
        pageSize,
        state.likedPostsOffset,
      );

      if (newLikedPosts.isNotEmpty) {
        state = state.copyWith(
          likedPosts: [...state.likedPosts, ...newLikedPosts],
          likedPostsOffset: state.likedPostsOffset + newLikedPosts.length,
        );
      }
    } catch (e) {
      // Opcional: manejar error al cargar más liked posts
    } finally {
      _isLoadingMoreLikedPosts = false;
    }
  }

  void switchTab(int index) {
    state = state.copyWith(currentTab: index);
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

  int get followers => 0; //user?.badges ?? 0;
  int get following => 0; //user?.likesReceived ?? 0;
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
  }) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      likedPosts: likedPosts ?? this.likedPosts,
      currentTab: currentTab ?? this.currentTab,
      postsOffset: postsOffset ?? this.postsOffset,
      likedPostsOffset: likedPostsOffset ?? this.likedPostsOffset,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
