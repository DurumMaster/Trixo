import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';
import 'package:trixo_frontend/config/config.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final state = ref.read(profileProvider(widget.userId));

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final notifier = ref.read(profileProvider(widget.userId).notifier);
        if (state.currentTab == 0) {
          notifier.loadMorePosts();
        } else {
          notifier.loadMoreLikedPosts();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider(widget.userId));
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider(widget.userId));
          await ref
              .read(profileProvider(widget.userId).notifier)
              .loadProfileData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Header Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: state.isLoading
                        ? const ColoredBox(color: Colors.grey)
                        : Image.network(
                            state.user?.avatarImg ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 100),
                          ),
                  ),

                  // Gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            isLight
                                ? AppColors.backgroundLight
                                : AppColors.backgroundDark,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Menu Button
                  const Positioned(
                    top: 40,
                    right: 20,
                    child: Icon(Icons.menu, color: Colors.white),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(
                          title: 'Seguidores',
                          value: state.isLoading
                              ? '--'
                              : HumanFormats.number(state.followers),
                        ),
                        _Stat(
                          title: 'Seguidos',
                          value: state.isLoading
                              ? '--'
                              : HumanFormats.number(state.following),
                        ),
                        _Stat(
                          title: 'Diseños',
                          value: state.isLoading
                              ? '--'
                              : HumanFormats.number(state.designs),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // User Info
                    if (state.isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Container(
                        width: 200,
                        height: 24,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 18,
                        color: Colors.grey,
                      ),
                    ] else ...[
                      Text(state.user?.username ?? '',
                          style: textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        state.user?.bio ?? '',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tabs
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: _ProfileTabs(
                  current: state.currentTab,
                  onChanged: (index) => ref
                      .read(profileProvider(widget.userId).notifier)
                      .switchTab(index),
                ),
              ),
            ),

            // Content
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: Center(child: Text('Error: ${state.error}')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final posts = state.currentTab == 0
                          ? state.posts
                          : state.likedPosts;
                      if (index >= posts.length) return null;
                      return Image.network(
                        posts[index].images.first,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const ColoredBox(color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;

  const _Stat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(title, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _ProfileTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.grid_view,
              color: current == 0 ? AppColors.accent : iconColor),
          onPressed: () => onChanged(0),
        ),
        IconButton(
          icon: Icon(Icons.favorite_border,
              color: current == 1 ? AppColors.accent : iconColor),
          onPressed: () => onChanged(1),
        ),
      ],
    );
  }
}

// class _PostsGrid extends StatelessWidget {
//   final List<Post> posts;

//   const _PostsGrid({required this.posts});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: posts.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 0.75,
//       ),
//       itemBuilder: (context, index) => Image.network(posts[index].images.first),
//     );
//   }
// }
