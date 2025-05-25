import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

// Proveedores Firebase + userId
final firebaseUserProvider = StreamProvider<firebase_auth.User?>(
  (ref) => firebase_auth.FirebaseAuth.instance.authStateChanges(),
);
final userIdProvider =
    Provider<String?>((ref) => ref.watch(firebaseUserProvider).value?.uid);

// PostProvider
final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier(
    repository: ref.read(postRepositoryProvider),
    userId: ref.watch(userIdProvider),
  );
});

// Secciones
enum HomeSection { forYou, top, recents }

// Estado por sección
class SectionState {
  final List<Post> posts;

  // For You
  final int forYouOffset;
  final bool isLoadingForYou;
  final bool hasMoreForYou;

  // Resto (fallback)
  final int restOffset;
  final bool isLoadingRest;
  final bool hasMoreRest;

  // Top
  final int topOffset;
  final bool isLoadingTop;
  final bool hasMoreTop;

  // Recents
  final int recentsOffset;
  final bool isLoadingRecents;
  final bool hasMoreRecents;

  // Error común
  final bool hasError;

  // Controller
  final ScrollController scrollController;

  const SectionState({
    this.posts = const [],
    // For You
    this.forYouOffset = 0,
    this.isLoadingForYou = false,
    this.hasMoreForYou = true,
    // Rest
    this.restOffset = 0,
    this.isLoadingRest = false,
    this.hasMoreRest = true,
    // Top
    this.topOffset = 0,
    this.isLoadingTop = false,
    this.hasMoreTop = true,
    // Recents
    this.recentsOffset = 0,
    this.isLoadingRecents = false,
    this.hasMoreRecents = true,
    this.hasError = false,
    required this.scrollController,
  });

  SectionState copyWith({
    List<Post>? posts,
    int? forYouOffset,
    bool? isLoadingForYou,
    bool? hasMoreForYou,
    int? restOffset,
    bool? isLoadingRest,
    bool? hasMoreRest,
    int? topOffset,
    bool? isLoadingTop,
    bool? hasMoreTop,
    int? recentsOffset,
    bool? isLoadingRecents,
    bool? hasMoreRecents,
    bool? hasError,
  }) {
    return SectionState(
      posts: posts ?? this.posts,
      forYouOffset: forYouOffset ?? this.forYouOffset,
      isLoadingForYou: isLoadingForYou ?? this.isLoadingForYou,
      hasMoreForYou: hasMoreForYou ?? this.hasMoreForYou,
      restOffset: restOffset ?? this.restOffset,
      isLoadingRest: isLoadingRest ?? this.isLoadingRest,
      hasMoreRest: hasMoreRest ?? this.hasMoreRest,
      topOffset: topOffset ?? this.topOffset,
      isLoadingTop: isLoadingTop ?? this.isLoadingTop,
      hasMoreTop: hasMoreTop ?? this.hasMoreTop,
      recentsOffset: recentsOffset ?? this.recentsOffset,
      isLoadingRecents: isLoadingRecents ?? this.isLoadingRecents,
      hasMoreRecents: hasMoreRecents ?? this.hasMoreRecents,
      hasError: hasError ?? this.hasError,
      scrollController: scrollController,
    );
  }
}

// Estado global
class PostState {
  final Map<HomeSection, SectionState> sections;
  final HomeSection currentSection;

  const PostState({
    required this.sections,
    required this.currentSection,
  });

  factory PostState.initial() {
    final controllers = {
      for (var s in HomeSection.values) s: ScrollController(),
    };
    return PostState(
      currentSection: HomeSection.forYou,
      sections: {
        for (var s in HomeSection.values)
          s: SectionState(scrollController: controllers[s]!),
      },
    );
  }

  PostState copyWith({
    Map<HomeSection, SectionState>? sections,
    HomeSection? currentSection,
  }) {
    return PostState(
      sections: sections ?? this.sections,
      currentSection: currentSection ?? this.currentSection,
    );
  }
}

// Notifier
class PostNotifier extends StateNotifier<PostState> {
  final PostRepository repository;
  final String? userId;
  static const int pageSize = 5;
  bool _isDisposed = false;

  PostNotifier({required this.repository, required this.userId})
      : super(PostState.initial()) {
    _initControllers();
    _initialLoad();
  }

  void _initControllers() {
    for (final section in state.sections.keys) {
      state.sections[section]!.scrollController.addListener(() {
        if (_shouldLoadMore(section)) {
          loadMore(section);
        }
      });
    }
  }

  Future<void> _initialLoad() async {
    if (userId == null) return;
    // Solo cargar la sección "forYou" al inicio
    await _loadSection(HomeSection.forYou, initialLoad: true);
  }

  bool _shouldLoadMore(HomeSection section) {
    final ctrl = state.sections[section]!.scrollController;
    if (!ctrl.hasClients) return false;
    final pos = ctrl.position.pixels;
    final max = ctrl.position.maxScrollExtent;
    if (max - pos > 300) return false; // a más de 300px no cargamos

    final st = state.sections[section]!;
    switch (section) {
      case HomeSection.forYou:
        return (!st.isLoadingForYou && st.hasMoreForYou) ||
            (!st.isLoadingRest && st.hasMoreRest);
      case HomeSection.top:
        return !st.isLoadingTop && st.hasMoreTop;
      case HomeSection.recents:
        return !st.isLoadingRecents && st.hasMoreRecents;
    }
  }

  Future<void> loadMore(HomeSection section) async {
    if (_isDisposed) return;
    await _loadSection(section);
  }

  Future<void> _loadSection(HomeSection section,
      {bool initialLoad = false}) async {
    if (userId == null && section == HomeSection.forYou) return;

    final st = state.sections[section]!;

    switch (section) {
      case HomeSection.forYou:
        // Primero recomendados
        if (st.hasMoreForYou) {
          // marcaremos isLoadingForYou
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              isLoadingForYou: true,
              hasError: false,
              posts: initialLoad ? [] : st.posts,
            ),
          });

          try {
            final page = await repository.getForYouPosts(
                userId!, pageSize, st.forYouOffset);
            final hasMore = page.isNotEmpty;
            final merged = initialLoad ? page : [...st.posts, ...page];

            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(
                posts: merged,
                forYouOffset: st.forYouOffset + page.length,
                hasMoreForYou: hasMore,
                isLoadingForYou: false,
              ),
            });
          } catch (e) {
            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(
                isLoadingForYou: false,
                hasError: true,
              ),
            });
          }
          return;
        }
        // Luego fallback "rest"
        if (st.hasMoreRest) {
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              isLoadingRest: true,
              hasError: false,
            ),
          });

          try {
            final page = await repository.getAllPosts(pageSize, st.restOffset);
            final hasMore = page.isNotEmpty;
            final merged = [...st.posts, ...page];

            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(
                posts: merged,
                restOffset: st.restOffset + page.length,
                hasMoreRest: hasMore,
                isLoadingRest: false,
              ),
            });
          } catch (e) {
            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(
                isLoadingRest: false,
                hasError: true,
              ),
            });
          }
        }
        break;

      case HomeSection.top:
        if (!st.hasMoreTop || st.isLoadingTop) return;
        state = state.copyWith(sections: {
          ...state.sections,
          section: st.copyWith(isLoadingTop: true, hasError: false),
        });
        try {
          final page =
              await repository.getPostsByPageRanking(pageSize, st.topOffset);
          final hasMore = page.isNotEmpty;
          final merged = initialLoad ? page : [...st.posts, ...page];

          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              posts: merged,
              topOffset: st.topOffset + page.length,
              hasMoreTop: hasMore,
              isLoadingTop: false,
            ),
          });
        } catch (e) {
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              isLoadingTop: false,
              hasError: true,
            ),
          });
        }
        break;

      case HomeSection.recents:
        if (!st.hasMoreRecents || st.isLoadingRecents) return;
        state = state.copyWith(sections: {
          ...state.sections,
          section: st.copyWith(isLoadingRecents: true, hasError: false),
        });
        try {
          final page =
              await repository.getRecentPosts(pageSize, st.recentsOffset);
          final hasMore = page.isNotEmpty;
          final merged = initialLoad ? page : [...st.posts, ...page];

          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              posts: merged,
              recentsOffset: st.recentsOffset + page.length,
              hasMoreRecents: hasMore,
              isLoadingRecents: false,
            ),
          });
        } catch (e) {
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              isLoadingRecents: false,
              hasError: true,
            ),
          });
        }
        break;
    }
  }

  void setCurrentSection(HomeSection sec) {
    state = state.copyWith(currentSection: sec);
    // Cargar si no hay nada aún
    if (state.sections[sec]!.posts.isEmpty) {
      _loadSection(sec, initialLoad: true);
    }
  }

  Future<void> refreshSection(HomeSection sec) async {
    final st = state.sections[sec]!;
    state = state.copyWith(sections: {
      ...state.sections,
      sec: SectionState(scrollController: st.scrollController),
    });
    await _loadSection(sec, initialLoad: true);
  }

  Future<void> toggleLike(String postId) async {
    final st = state.sections[state.currentSection]!;
    // Actualización optimista solo en la sección actual
    final updated = st.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(
          isLiked: !p.isLiked,
          likesCount: p.likesCount + (p.isLiked ? -1 : 1),
        );
      }
      return p;
    }).toList();

    state = state.copyWith(sections: {
      ...state.sections,
      state.currentSection: st.copyWith(posts: updated),
    });

    try {
      await repository.toggleLike(postId);
    } catch (_) {
      // revertir
      final reverted = updated.map((p) {
        if (p.id == postId) {
          return p.copyWith(
            isLiked: !p.isLiked,
            likesCount: p.likesCount + (p.isLiked ? -1 : 1),
          );
        }
        return p;
      }).toList();
      state = state.copyWith(sections: {
        ...state.sections,
        state.currentSection: st.copyWith(posts: reverted),
      });
      rethrow;
    }
  }

  Future<void> sendReport(String postId, String reason) async {
    await repository.sendReport(postId, reason);
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (var st in state.sections.values) {
      st.scrollController.dispose();
    }
    super.dispose();
  }
}
