import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/infrastructure/post_infrastructure.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchState {
  final List<Post> allPosts;
  final List<Post> posts;
  final int offset;
  final bool isLoading;
  final bool hasMore;
  final bool hasError;
  final List<String> tags;
  final ScrollController scrollController;

  const SearchState({
    this.allPosts = const [],
    this.posts = const [],
    this.offset = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.hasError = false,
    this.tags = const [],
    required this.scrollController,
  });

  SearchState copyWith({
    List<Post>? allPosts,
    List<Post>? posts,
    int? offset,
    bool? isLoading,
    bool? hasMore,
    bool? hasError,
    List<String>? tags, // ← AÑADIR ESTO
  }) {
    return SearchState(
      allPosts: allPosts ?? this.allPosts,
      posts: posts ?? this.posts,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      hasError: hasError ?? this.hasError,
      tags: tags ?? this.tags, // ← AÑADIR ESTO
      scrollController: scrollController,
    );
  }
}

final searchRepositoryProvider = Provider<PostRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return PostRepositoryImpl(PostDatasourceImpl(getAccessToken: () async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    return await user.getIdToken();
  }));
});

  final searchNotiProvider =
    StateNotifierProvider.family<SearchNotifier, SearchState, String>(
  (ref, userId) =>
      SearchNotifier(ref.watch(searchRepositoryProvider), ref),
);


class SearchNotifier extends StateNotifier<SearchState> {
  final PostRepository repository;
  final Ref ref;
  static const int pageSize = 10;
  Timer? _debounce;

  SearchNotifier(this.repository, this.ref)
      : super(SearchState(scrollController: ScrollController())) {
    state.scrollController.addListener(_onScroll);
    loadMore();
  }

  void _onScroll() {
    if (state.scrollController.position.pixels >=
            state.scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        state.hasMore) {
      loadMore(); 
    }
  }

  void search(String query) {
    final cleanedQuery = query.trim().toLowerCase();
    final cleanedSelectedTags = state.tags.map((tag) => cleanTag(tag).toLowerCase()).toList();

    List<Post> filteredPosts;

    if (cleanedSelectedTags.isNotEmpty && cleanedQuery.isNotEmpty) {
      // Filtrar por tags Y query
      filteredPosts = state.allPosts.where((post) {
        final cleanedPostTags = post.tags.map((tag) => cleanTag(tag).toLowerCase()).toList();
        final matchesTags = cleanedSelectedTags.any((tag) => cleanedPostTags.contains(tag));
        final matchesQuery = post.caption.toLowerCase().contains(cleanedQuery);
        return matchesTags && matchesQuery;
      }).toList();
    } else if (cleanedSelectedTags.isNotEmpty) {
      // Filtrar solo por tags
      filteredPosts = state.allPosts.where((post) {
        final cleanedPostTags = post.tags.map((tag) => cleanTag(tag).toLowerCase()).toList();
        return cleanedSelectedTags.any((tag) => cleanedPostTags.contains(tag));
      }).toList();
    } else if (cleanedQuery.isNotEmpty) {
      // Filtrar solo por query
      filteredPosts = state.allPosts.where((post) {
        return post.caption.toLowerCase().contains(cleanedQuery);
      }).toList();
    } else {
      // No hay query ni tags: mostrar todos
      filteredPosts = state.allPosts;
    }

    state = state.copyWith(posts: filteredPosts);
  }


  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final newPosts =
          await repository.getAllPosts(SearchNotifier.pageSize, state.offset);
      final updatedAll = [...state.allPosts, ...newPosts];

      state = state.copyWith(
        allPosts: updatedAll,
        offset: state.offset + newPosts.length,
        hasMore: newPosts.length == SearchNotifier.pageSize,
        isLoading: false,
      );

      final query = ref.read(searchQueryProvider).toLowerCase();
      search(query);
    } catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  void searchByTags(List<String> tags) {
    state = state.copyWith(tags: tags);
    search(ref.read(searchQueryProvider));
  }

  String cleanTag(String tag) {
    return tag.replaceFirst(RegExp(r'^[^\w]+'), '');
  }

  void toggleLike(String postId) async {
    try {
      final updatedPost = await repository.toggleLike(postId);
      final updatedPosts = state.posts.map((post) {
        return post.id == updatedPost.id ? updatedPost : post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      // Manejar error al actualizar el like
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    state.scrollController.dispose();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(postRepositoryProvider), ref);
});
