import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

final postProvider =
    StateNotifierProvider<PostNotifier,PostState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostNotifier(repository: repository);
});

enum HomeSection { forYou, top, following }

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

  PostNotifier({required this.repository})
      : super(const PostState(
          sections: {
            HomeSection.forYou: SectionState(),
            HomeSection.top: SectionState(),
            HomeSection.following: SectionState(),
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

    final sectionState = state.sections[section]!;
    if (sectionState.posts.isEmpty && !sectionState.isLoading) {
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
          posts = await repository.getPostsByPageRanking(
            limit: state.limit,
            offset: sectionState.offset,
          );
          break;
        case HomeSection.forYou:
          // TODO: CAMBIAR CON EL METODO PARA FORYOU
          posts = await repository.getPostsByPageRanking(
            limit: state.limit,
            offset: sectionState.offset,
          );
          break;
        case HomeSection.following:
          // TODO: CAMBIAR CON EL METODO PARA FOLLOWING
          posts = await repository.getPostsByPageRanking(
            limit: state.limit,
            offset: sectionState.offset,
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
}
