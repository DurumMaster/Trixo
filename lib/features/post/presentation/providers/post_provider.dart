import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  final authState = ref.watch(currentUserID);
  if (authState.value == null) {
    throw Exception("User is not authenticated. Please try again.");
  }
  return PostNotifier(repository: repository, userId: authState.value!);
});

enum HomeSection { forYou, top, recents }

class SectionState {
  final bool isLastPage;
  final int offset;
  final bool isLoading;
  final List<Post> posts;

  const SectionState({
    this.isLastPage = false,
    this.offset = 0,
    this.isLoading = false,
    this.posts = const [],
  });

  SectionState copyWith({
    bool? isLastPage,
    int? offset,
    bool? isLoading,
    List<Post>? posts,
  }) {
    return SectionState(
      isLastPage: isLastPage ?? this.isLastPage,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
    );
  }
}

class PostState {
  final Map<HomeSection, SectionState> sections;
  final int limit;
  final HomeSection currentSection;

  const PostState({
    required this.sections,
    this.limit = 10,
    this.currentSection = HomeSection.forYou,
  });

  PostState copyWith({
    Map<HomeSection, SectionState>? sections,
    int? limit,
    HomeSection? currentSection,
  }) {
    return PostState(
      sections: sections ?? this.sections,
      limit: limit ?? this.limit,
      currentSection: currentSection ?? this.currentSection,
    );
  }
}

class PostInteraction {
  final bool isLiked;
  final int likesCount;

  const PostInteraction({
    required this.isLiked,
    required this.likesCount,
  });
}

class PostNotifier extends StateNotifier<PostState> {
  final PostRepository repository;
  final String userId;

  PostNotifier({required this.repository, required this.userId})
      : super(const PostState(
          sections: {
            HomeSection.forYou: SectionState(),
            HomeSection.top: SectionState(),
            HomeSection.recents: SectionState(),
          },
          limit: 10,
          currentSection: HomeSection.forYou,
        )) {
    _loadInitialSection();
  }

  Future<void> _loadInitialSection() async {
    await loadNextPage();
  }

  void setCurrentSection(HomeSection section) {
    if (state.currentSection == section) return;

    state = state.copyWith(currentSection: section);

    final sectionState = state.sections[section] ?? const SectionState();
    if (sectionState.posts.isEmpty) {
      loadNextPage();
    }
  }

  Future<void> loadNextPage() async {
    final currentSection = state.currentSection;
    final sectionState = state.sections[currentSection]!;

    if (sectionState.isLoading || sectionState.isLastPage) return;

    state = state.copyWith(
      sections: {
        ...state.sections,
        currentSection: sectionState.copyWith(isLoading: true),
      },
    );

    try {
      List<Post> posts;
      switch (currentSection) {
        case HomeSection.top:
          log("Offset actual: $sectionState.offset", name: "PostNotifier");
          posts = await repository.getPostsByPageRanking(
            limit: state.limit,
            offset: sectionState.offset,
          );
          break;
        case HomeSection.forYou:
          log("Offset actual: $sectionState.offset", name: "PostNotifier");
          posts = await repository.getForYouPosts(
            userId,
            state.limit,
            sectionState.offset,
          );
          break;
        case HomeSection.recents:
          log("Offset actual: $sectionState.offset", name: "PostNotifier");
          posts = await repository.getRecentPosts(
            state.limit,
            sectionState.offset,
          );
          break;
      }

      final newSectionState = sectionState.copyWith(
        isLoading: false,
        isLastPage: posts.isEmpty,
        offset: sectionState.offset + state.limit,
        posts: [...sectionState.posts, ...posts],
      );

      state = state.copyWith(
        sections: {
          ...state.sections,
          currentSection: newSectionState,
        },
      );
    } catch (e) {
      state = state.copyWith(
        sections: {
          ...state.sections,
          currentSection: sectionState.copyWith(isLoading: false),
        },
      );
    }
  }

  Future<void> refreshCurrentSection() async {
    final currentSection = state.currentSection;

    state = state.copyWith(
      sections: {
        ...state.sections,
        currentSection: const SectionState(),
      },
    );

    await loadNextPage();
  }

  Future<void> toggleLike(String postId) async {
    try {
      // Actualización optimista
      state = _updatePostInState(
          postId,
          (post) => post.copyWith(
              isLiked: !post.isLiked,
              likesCount: post.likesCount + (post.isLiked ? -1 : 1)));

      await repository.toggleLike(postId);
    } catch (e) {
      // Rollback
      state = _updatePostInState(
          postId,
          (post) => post.copyWith(
              isLiked: !post.isLiked,
              likesCount: post.likesCount - (post.isLiked ? -1 : 1)));
      rethrow;
    }
  }

  PostState _updatePostInState(String postId, Post Function(Post) updateFn) {
    final newSections = Map<HomeSection, SectionState>.from(state.sections);

    for (final section in newSections.keys) {
      final posts = newSections[section]!.posts.map((post) {
        return post.id == postId ? updateFn(post) : post;
      }).toList();

      newSections[section] = newSections[section]!.copyWith(posts: posts);
    }

    return state.copyWith(sections: newSections);
  }

  Future<void> sendReport(String postId, String reason) async {
    try {
      await repository.sendReport(postId, reason);
    } catch (e) {
      rethrow;
    }
  }
}
