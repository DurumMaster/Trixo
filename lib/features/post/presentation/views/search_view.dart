import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_provider.dart';
import 'package:trixo_frontend/features/post/domain/entity/post.dart';
import 'package:trixo_frontend/features/post/presentation/providers/search_provider.dart';
import 'package:trixo_frontend/features/post/presentation/views/post_views.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_post_card.dart';

class SearchView extends ConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        title: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: SizedBox(
                  child: TextField(
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                      ref.read(searchProvider.notifier).search(value);
                    },
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      hintText: 'Buscar diseños...',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54),
                      prefixIcon: Icon(Icons.search,
                          color: isDark ? Colors.white : Colors.black),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon:
                  Icon(Icons.tag, color: isDark ? Colors.white : Colors.black),
              onPressed: () async {
                final selectedTags =
                    await Navigator.of(context, rootNavigator: true)
                        .push<List<String>>(
                  MaterialPageRoute(
                    builder: (_) => CreatePostSelectTagsView(
                      availableTags: AppConstants().allPreferences,
                      initialTags: ref.read(searchProvider).tags,
                    ),
                  ),
                );

                if (selectedTags != null) {
                  ref.read(searchProvider.notifier).searchByTags(selectedTags);
                }
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (searchState.tags.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros seleccionados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(searchProvider.notifier).searchByTags([]);
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Borrar todos'),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: searchState.tags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              final updatedTags = [...searchState.tags]
                                ..remove(tag);
                              ref
                                  .read(searchProvider.notifier)
                                  .searchByTags(updatedTags);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            if (searchState.posts.isEmpty) ...[
              if (searchState.isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'No se han encontrado diseños',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
            ] else
              Expanded(
                child: MasonryGridView.count(
                  controller: searchState.scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 6,
                  itemCount: searchState.posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == searchState.posts.length) {
                      if (searchState.isLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    final post = searchState.posts[index];
                    final imageUrl =
                        post.images.isNotEmpty ? post.images.first : null;

                    if (imageUrl == null) {
                      return const SizedBox();
                    }

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: (value - 0.9) * 10,
                          child: Transform.scale(
                            scale: value,
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(
                                initialIndex: index,
                                posts: searchState.posts,
                                userId: post.user!.id,
                              ),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AspectRatio(
                              aspectRatio: 4 / 5,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                        child: Icon(Icons.refresh, size: 40)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PostDetailScreen extends ConsumerStatefulWidget {
  final List<Post> posts;
  final int initialIndex;
  final String userId;

  const PostDetailScreen({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.userId,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final Set<String> _toggledPostIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController.scrollTo(
        index: widget.initialIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop && _toggledPostIds.isNotEmpty) {
      final notifier = ref.read(searchNotiProvider(widget.userId).notifier);
      for (var postId in _toggledPostIds) {
        notifier.toggleLike(postId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final posts = widget.posts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isLight ? Colors.white : Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isLight ? Colors.black : Colors.white),
          onPressed: () async {
            final didPop = await Navigator.of(context).maybePop();
            _onPopInvoked(didPop, null);
          },
        ),
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemCount: posts.length,
        itemBuilder: (context, i) {
          final post = posts[i];
          final isLikedLocally =
              _toggledPostIds.contains(post.id) ? !post.isLiked : post.isLiked;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: PostCard(
              post: post.copyWith(isLiked: isLikedLocally),
              onLike: () {
                setState(() {
                  if (!_toggledPostIds.remove(post.id)) {
                    _toggledPostIds.add(post.id);
                  }
                });
              },
              onShare: () {
                ref.read(postProvider.notifier).sharePost(post.images);
              },
            ),
          );
        },
      ),
    );
  }
}
