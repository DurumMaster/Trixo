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
  final PageController _pageController = PageController();
  final Map<HomeSection, ScrollController> _scrollControllers = {
    HomeSection.forYou: ScrollController(),
    HomeSection.top: ScrollController(),
    HomeSection.following: ScrollController(),
  };
  int _selectedTab = 0;
  final List<String> _tabs = ['Para tí', 'Top', 'Siguiendo'];

  @override
  void initState() {
    super.initState();
    _setupScrollListeners();
  }

  void _setupScrollListeners() {
    for (final controller in _scrollControllers.values) {
      controller.addListener(() {
        final currentState = ref.read(postProvider);
        final currentSection = currentState.currentSection;

        if (controller != _scrollControllers[currentSection]) return;

        final sectionState = currentState.sections[currentSection]!;
        final position = controller.position;

        if (position.pixels >= position.maxScrollExtent - 300 &&
            !sectionState.isLoading &&
            !sectionState.isLastPage) {
          ref.read(postProvider.notifier).loadNextPage();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _scrollControllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSectionPage(HomeSection section) {
    return _PostsSection(
      section: section,
      scrollController: _scrollControllers[section]!,
    );
  }

  void _onTabSelected(int index) {
    final section = HomeSection.values[index];
    ref.read(postProvider.notifier).setCurrentSection(section);
    setState(() {
      _selectedTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);
    final isLoading = postState.sections[postState.currentSection]!.isLoading;

    return Stack(
      children: [
        _buildContent(postState),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(PostState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> refresh() async {
      await ref.read(postProvider.notifier).refreshCurrentSection();
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        color: isDark ? AppColors.white : AppColors.black,
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            elevation: 0,
            titleSpacing: 0,
            title: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_tabs.length, (index) {
                    final selected = _selectedTab == index;
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
                                color:
                                    isDark ? AppColors.white : AppColors.black,
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
            actions: [
              IconButton(
                icon: Icon(Icons.search,
                    color: isDark ? AppColors.white : AppColors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: PageView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: HomeSection.values.length,
            controller: _pageController,
            onPageChanged: (index) {
              final section = HomeSection.values[index];
              ref.read(postProvider.notifier).setCurrentSection(section);
              setState(() {
                _selectedTab = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildSectionPage(HomeSection.values[index]);
            },
          ),
        ),
      ),
    );
  }
}

class _PostsSection extends ConsumerStatefulWidget {
  final HomeSection section;
  final ScrollController scrollController;

  const _PostsSection({
    required this.section,
    required this.scrollController,
  });

  @override
  ConsumerState<_PostsSection> createState() => _PostsSectionState();
}

class _PostsSectionState extends ConsumerState<_PostsSection>
    with AutomaticKeepAliveClientMixin {
  final PageStorageKey _pageStorageKey = PageStorageKey(UniqueKey());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(postProvider);
    final posts = state.sections[widget.section]!.posts;
    final isLoading = state.sections[widget.section]!.isLoading;

    return Stack(
      children: [
        ListView.builder(
          key: _pageStorageKey,
          controller: widget.scrollController,
          itemCount: posts.length,
          itemBuilder: (context, i) {
            return PostCard(
              post: posts[i],
              onLike: () =>
                  ref.read(postProvider.notifier).toggleLike(posts[i].id),
            );
          },
        ),
        // if (isLoading)
        //   Positioned(
        //     bottom: 20,
        //     left: 0,
        //     right: 0,
        //     child: _buildLoadingIndicator(),
        //   ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
