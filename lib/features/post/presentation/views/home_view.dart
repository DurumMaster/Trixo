import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late final PageController _pageController;
  final List<String> _tabs = ['Para ti', 'Top', 'Novedades'];

  @override
  void initState() {
    super.initState();
    final initialPage = ref.read(postProvider).currentSection.index;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    final section = HomeSection.values[index];
    ref.read(postProvider.notifier).setCurrentSection(section);
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sincroniza PageController con cambios de sección
    ref.listen<PostState>(postProvider, (previous, next) {
      final idx = next.currentSection.index;
      if (_pageController.hasClients && _pageController.page?.round() != idx) {
        _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Stack(
      children: [
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(postProvider.notifier)
                .refreshSection(postState.currentSection),
            color: isDark ? AppColors.white : AppColors.black,
            child: Scaffold(
              backgroundColor:
                  isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              appBar: AppBar(
                backgroundColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                elevation: 0,
                titleSpacing: 0,
                title: Center(
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_tabs.length, (index) {
                        final selected =
                            postState.currentSection.index == index;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () => _onTabSelected(index),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _tabs[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? (isDark
                                            ? AppColors.white
                                            : AppColors.black)
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 2,
                                  width: selected ? 24 : 0,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.black,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              body: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                onPageChanged: (i) {
                  final section = HomeSection.values[i];
                  if (postState.currentSection != section) {
                    ref.read(postProvider.notifier).setCurrentSection(section);
                  }
                },
                itemCount: HomeSection.values.length,
                itemBuilder: (context, index) {
                  final section = HomeSection.values[index];
                  return HomeSectionPage(section: section);
                },
              ),
            ),
          ),
        ),
        // Overlay de carga global
        if (_isAnySectionLoading(postState))
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isAnySectionLoading(PostState state) {
    final sec = state.sections[state.currentSection]!;
    return switch (state.currentSection) {
      HomeSection.forYou => sec.isLoadingForYou || sec.isLoadingRest,
      HomeSection.top => sec.isLoadingTop,
      HomeSection.recents => sec.isLoadingRecents,
    };
  }
}

/// Widget que representa cada sección y mantiene el estado (scroll) vivo
class HomeSectionPage extends ConsumerWidget {
  final HomeSection section;
  const HomeSectionPage({required this.section, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postProvider);
    final secState = postState.sections[section]!;

    return ListView.builder(
      key: PageStorageKey(section),
      controller: secState.scrollController, // <- usa este
      itemCount: secState.posts.length + (secState.hasError ? 1 : 0),
      itemBuilder: (context, i) {
        if (secState.hasError && i == secState.posts.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: IconButton(
                onPressed: () =>
                    ref.read(postProvider.notifier).loadMore(section),
                icon: const Icon(Icons.refresh),
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          );
        }
        final post = secState.posts[i];
        return PostCard(
          post: post,
          onLike: () => ref.read(postProvider.notifier).toggleLike(post.id),
          onShare: () => ref.read(postProvider.notifier).sharePost(post.images),
        );
      },
    );
  }
}
