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
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0;
  final List<String> _tabs = ['Para tí', 'Top', 'Siguiendo'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !ref
              .read(postProvider)
              .sections[ref.read(postProvider).currentSection]!
              .isLoading &&
          !ref
              .read(postProvider)
              .sections[ref.read(postProvider).currentSection]!
              .isLastPage) {
        ref.read(postProvider.notifier).loadNextPage();
      }
    });
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
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
    return postState.sections[postState.currentSection]!.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _buildContent(postState);
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
            controller: _pageController,
            onPageChanged: (index) {
              final section = HomeSection.values[index];
              ref.read(postProvider.notifier).setCurrentSection(section);
            },
            itemBuilder: (context, index) {
              final section = HomeSection.values[index];
              final sectionPosts = state.sections[section]!.posts;

              return ListView.builder(
                controller: _scrollController,
                itemCount: sectionPosts.length,
                itemBuilder: (context, i) {
                  final post = sectionPosts[i];
                  return PostCard(
                    imageUrls: post.images,
                    username: post.user?.username,
                    avatarUrl: post.user?.avatarImg,
                    description: post.caption,
                    likeCount: post.likesCount,
                    commentsCount: post.commentsCount,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
