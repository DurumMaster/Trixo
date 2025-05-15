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

  ProfileNotifier(this.repository, this.userId) : super(ProfileState()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await repository.getUser(userId);
      final posts = await repository.getUserPosts(userId, 10);
      final likedPosts = await repository.getLikedPosts(userId, 10);
      state = state.copyWith(
        user: user,
        posts: posts,
        likedPosts: likedPosts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoading: false);
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
    this.currentTab = 0,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    User? user,
    List<Post>? posts,
    List<Post>? likedPosts,
    int? currentTab,
    bool? isLoading,
    Object? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      likedPosts: likedPosts ?? this.likedPosts,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
