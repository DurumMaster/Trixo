import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

final firebaseUserProvider = StreamProvider<firebase_auth.User?>(
  (ref) => firebase_auth.FirebaseAuth.instance.authStateChanges(),
);
final userIdProvider =
    Provider<String?>((ref) => ref.watch(firebaseUserProvider).value?.uid);

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier(
    repository: ref.read(postRepositoryProvider),
    userId: ref.watch(userIdProvider),
    ref: ref,
  );
});

enum HomeSection { forYou, top, recents }

class SectionState {
  final List<Post> posts;
  final int forYouOffset;
  final bool isLoadingForYou;
  final bool hasMoreForYou;
  final int restOffset;
  final bool isLoadingRest;
  final bool hasMoreRest;
  final int topOffset;
  final bool isLoadingTop;
  final bool hasMoreTop;
  final int recentsOffset;
  final bool isLoadingRecents;
  final bool hasMoreRecents;
  final bool hasError;
  final ScrollController scrollController;

  const SectionState({
    this.posts = const [],
    this.forYouOffset = 0,
    this.isLoadingForYou = false,
    this.hasMoreForYou = true,
    this.restOffset = 0,
    this.isLoadingRest = false,
    this.hasMoreRest = true,
    this.topOffset = 0,
    this.isLoadingTop = false,
    this.hasMoreTop = true,
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

class PostNotifier extends StateNotifier<PostState> {
  final Ref ref;
  final PostRepository repository;
  final String? userId;
  static const int pageSize = 5;
  bool _isDisposed = false;
  final Map<HomeSection, Timer?> _debounceTimers = {};

  PostNotifier({required this.repository, required this.userId, required this.ref})
      : super(PostState.initial()) {
    _initControllers();
    _initialLoad();
  }

  void _initControllers() {
    for (final section in state.sections.keys) {
      _debounceTimers[section] = null;
      state.sections[section]!.scrollController.addListener(() {
        _debounceTimers[section]?.cancel();
        _debounceTimers[section] = Timer(const Duration(milliseconds: 200), () {
          if (_shouldLoadMore(section)) {
            loadMore(section);
          }
        });
      });
    }
  }

  Future<void> _initialLoad() async {
    if (userId == null) return;
    await _loadSection(HomeSection.forYou, initialLoad: true);
  }

  bool _shouldLoadMore(HomeSection section) {
    final ctrl = state.sections[section]!.scrollController;
    if (!ctrl.hasClients) return false;
    final pos = ctrl.position.pixels;
    final max = ctrl.position.maxScrollExtent;
    if (max - pos > 300) return false;

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

  List<Post> _mergePosts(List<Post> current, List<Post> incoming) {
    final existingIds = current.map((p) => p.id).toSet();
    return [...current, ...incoming.where((p) => !existingIds.contains(p.id))];
  }

  Future<void> loadMore(HomeSection section) async {
    if (_isDisposed) return;
    await _loadSection(section);
    final controller = state.sections[section]!.scrollController;
    if (controller.hasClients) {
      controller.animateTo(
        controller.offset + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadSection(HomeSection section,
      {bool initialLoad = false}) async {
    if (userId == null && section == HomeSection.forYou) return;

    final st = state.sections[section]!;

    switch (section) {
      case HomeSection.forYou:
        if (st.hasMoreForYou) {
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
            ref.read(postCacheProvider.notifier).upsertAll(page);
            final filtered = _mergePosts(initialLoad ? [] : st.posts, page);
            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(
                posts: filtered,
                forYouOffset: st.forYouOffset + page.length,
                hasMoreForYou: page.isNotEmpty,
                isLoadingForYou: false,
              ),
            });
          } catch (e) {
            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(isLoadingForYou: false, hasError: true),
            });
          }
          return;
        }

        if (st.hasMoreRest) {
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(isLoadingRest: true, hasError: false),
          });

          try {
            final page = await repository.getAllPosts(pageSize, st.restOffset);
            ref.read(postCacheProvider.notifier).upsertAll(page);
            final filtered = _mergePosts(st.posts, page);
            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(
                posts: filtered,
                restOffset: st.restOffset + page.length,
                hasMoreRest: page.isNotEmpty,
                isLoadingRest: false,
              ),
            });
          } catch (e) {
            state = state.copyWith(sections: {
              ...state.sections,
              section: st.copyWith(isLoadingRest: false, hasError: true),
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
          ref.read(postCacheProvider.notifier).upsertAll(page);
          final filtered = _mergePosts(initialLoad ? [] : st.posts, page);
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              posts: filtered,
              topOffset: st.topOffset + page.length,
              hasMoreTop: page.isNotEmpty,
              isLoadingTop: false,
            ),
          });
        } catch (e) {
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(isLoadingTop: false, hasError: true),
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
          ref.read(postCacheProvider.notifier).upsertAll(page);
          final filtered = _mergePosts(initialLoad ? [] : st.posts, page);
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(
              posts: filtered,
              recentsOffset: st.recentsOffset + page.length,
              hasMoreRecents: page.isNotEmpty,
              isLoadingRecents: false,
            ),
          });
        } catch (e) {
          state = state.copyWith(sections: {
            ...state.sections,
            section: st.copyWith(isLoadingRecents: false, hasError: true),
          });
        }
        break;
    }
  }

  void setCurrentSection(HomeSection sec) {
    state = state.copyWith(currentSection: sec);
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
    // 1. Obtener el post actual desde la caché global
    final currentPost = ref.read(postCacheProvider)[postId];
    if (currentPost == null) return;

    // 2. Generar un nuevo post con el like invertido (optimista)
    final optimistic = currentPost.copyWith(
      isLiked: !currentPost.isLiked,
      likesCount: currentPost.likesCount + (currentPost.isLiked ? -1 : 1),
    );

    // 3. Actualizar la caché global optimistamente
    ref.read(postCacheProvider.notifier).replace(optimistic);

    try {
      // 4. Enviar al servidor
      final updated = await repository.toggleLike(postId);

      // 5. Actualizar la caché con la respuesta real
      ref.read(postCacheProvider.notifier).replace(updated);
    } catch (_) {
      // 6. Revertir si falla
      ref.read(postCacheProvider.notifier).replace(currentPost);
    }
  }

  Future<void> sendReport(String postId, String reason) async {
    await repository.sendReport(postId, reason);
  }

  Future<void> sharePost(List<String> imageUrls) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = <XFile>[];

      for (var idx = 0; idx < imageUrls.length; idx++) {
        final res = await http.get(Uri.parse(imageUrls[idx]));
        final path = '${tempDir.path}/img_$idx.jpg';
        final file = File(path)..writeAsBytesSync(res.bodyBytes);
        files.add(XFile(file.path));
      }

      await Share.shareXFiles(
        files,
        text: '¡Mira este diseño de Trixo!',
      );
    } catch (e) {
      debugPrint('Error al compartir: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimers.forEach((_, timer) {
      timer?.cancel();
    });
    for (var st in state.sections.values) {
      st.scrollController.dispose();
    }
    super.dispose();
  }
}
