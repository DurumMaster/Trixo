import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/config/config.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({
    super.key,
    required this.userId,
    required this.actualUser,
  });

  final String userId;
  final bool actualUser;

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  OverlayEntry? _zoomOverlay;
  late final AnimationController _zoomAnimController;
  late final Animation<double> _zoomAnim;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _zoomAnim = CurvedAnimation(
      parent: _zoomAnimController,
      curve: Curves.easeOutBack,
    );

    _scrollController.addListener(() {
      final state = ref.read(profileProvider(widget.userId));
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          state.error == null) {
        final notifier = ref.read(profileProvider(widget.userId).notifier);
        if (state.currentTab == 0) {
          notifier.loadMorePosts(scrollController: _scrollController);
        } else {
          notifier.loadMoreLikedPosts(scrollController: _scrollController);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _zoomAnimController.dispose();
    super.dispose();
  }

  void _showZoomOverlay(String imageUrl) {
    _zoomAnimController.forward(from: 0);
    _zoomOverlay = OverlayEntry(builder: (context) {
      final isLight = Theme.of(context).brightness == Brightness.light;
      return GestureDetector(
        onTap: _removeZoomOverlay,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: ScaleTransition(
              scale: _zoomAnim,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    size: 50,
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
    Overlay.of(context).insert(_zoomOverlay!);
  }

  void _removeZoomOverlay() {
    _zoomOverlay?.remove();
    _zoomOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider(widget.userId));
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final loadingBoxColor =
        isLight ? Colors.grey.shade300 : Colors.grey.shade800;
    final overlayGradientBottom =
        isLight ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.9);

    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,
      body: RefreshIndicator(
        color: isLight ? Colors.black : Colors.white,
        onRefresh: () async {
          ref.invalidate(profileProvider(widget.userId));
          await ref
              .read(profileProvider(widget.userId).notifier)
              .loadProfileData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Encabezado de perfil...
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: state.isLoading
                        ? ColoredBox(color: loadingBoxColor)
                        : Image.network(
                            state.user?.avatarImg ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              size: 100,
                              color: isLight ? Colors.black : Colors.white,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, overlayGradientBottom],
                        ),
                      ),
                    ),
                  ),
                  if (!widget.actualUser)
                    Positioned(
                      top: 0,
                      left: 20,
                      child: SafeArea(
                        child: SizedBox(
                          height: 56,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.actualUser)
                    Positioned(
                      top: 0,
                      right: 20,
                      child: SafeArea(
                        child: SizedBox(
                          height: 56,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: IMPLEMENTAR AJUSTES
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Stats y bio...
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(
                          title: 'Seguidores',
                          value: state.isLoading
                              ? '0'
                              : HumanFormats.number(state.followers),
                        ),
                        _Stat(
                          title: 'Seguidos',
                          value: state.isLoading
                              ? '0'
                              : HumanFormats.number(state.following),
                        ),
                        _Stat(
                          title: 'Diseños',
                          value: state.isLoading
                              ? '0'
                              : HumanFormats.number(state.designs),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.isLoading) ...[
                      const SizedBox(height: 16),
                      Container(width: 200, height: 24, color: loadingBoxColor),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 18, color: loadingBoxColor),
                    ] else ...[
                      Text(
                        state.user?.username ?? '',
                        style: textTheme.titleLarge?.copyWith(
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.user?.bio ?? '',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: (isLight ? Colors.black : Colors.white)
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Tabs...
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: _ProfileTabs(
                  current: state.currentTab,
                  onChanged: (i) => ref
                      .read(profileProvider(widget.userId).notifier)
                      .switchTab(i),
                ),
              ),
            ),
            // Loader/Error/Grilla...
            if (state.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 38, color: colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        'Ha ocurrido un error al cargar el perfil',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildPostsGrid(state, loadingBoxColor, isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid(
      ProfileState state, Color loadingBoxColor, bool isLight) {
    final posts = state.currentTab == 0 ? state.posts : state.likedPosts;
    if (posts.isEmpty) {
      final isUser = widget.actualUser;
      final isLiked = state.currentTab == 1;
      final message = isLiked
          ? (isUser
              ? 'Todavía no has dado like a ningún diseño'
              : 'Este usuario aún no ha dado like a ningún diseño')
          : (isUser
              ? 'Sube tu primer diseño y empieza a destacar 🎨'
              : 'Este usuario aún no tiene diseños');
      final icon = isLiked ? Icons.disabled_visible : Icons.draw_rounded;
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 48, color: isLight ? Colors.black54 : Colors.white70),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: isLight ? Colors.black : Colors.white)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, idx) {
            if (idx >= posts.length) return null;
            final post = posts[idx];
            final imageUrl = post.images.first;
            return GestureDetector(
              onLongPressStart: (_) => _showZoomOverlay(imageUrl),
              onLongPressEnd: (_) => _removeZoomOverlay(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePostsDetailScreen(
                        initialIndex: idx, userId: widget.userId),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, prog) =>
                      prog == null ? child : ColoredBox(color: loadingBoxColor),
                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image,
                      color: isLight ? Colors.black45 : Colors.white70),
                ),
              ),
            );
          },
          childCount: posts.length,
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = isLight ? Colors.black : Colors.white;
    final secondary = primary.withOpacity(0.7);
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: primary)),
        const SizedBox(height: 4),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: secondary)),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final sel = isLight ? Colors.black : Colors.white;
    final unsel = sel.withOpacity(0.5);
    Widget tab(IconData icon, int i) {
      final s = current == i;
      return GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(icon, key: ValueKey(s), color: s ? sel : unsel),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2,
                width: 24,
                color: s ? sel : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      tab(Icons.grid_view, 0),
      const SizedBox(width: 32),
      tab(Icons.favorite_border, 1)
    ]);
  }
}

class ProfilePostsDetailScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  final String userId;

  const ProfilePostsDetailScreen({
    super.key,
    required this.initialIndex,
    required this.userId,
  });

  @override
  ConsumerState<ProfilePostsDetailScreen> createState() =>
      _ProfilePostsDetailScreenState();
}

class _ProfilePostsDetailScreenState
    extends ConsumerState<ProfilePostsDetailScreen> {
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

  /// Se llama **después** de que el pop haya ocurrido.
  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop && _toggledPostIds.isNotEmpty) {
      final notifier = ref.read(profileProvider(widget.userId).notifier);
      for (var postId in _toggledPostIds) {
        notifier.toggleLikePost(postId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider(widget.userId));
    final posts = profileState.currentTab == 0
        ? profileState.posts
        : profileState.likedPosts;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return PopScope<bool>(
      canPop: true,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isLight ? Colors.white : Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isLight ? Colors.black : Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final post = posts[i];
            final isLikedLocally = _toggledPostIds.contains(post.id)
                ? !post.isLiked
                : post.isLiked;

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
                onShare: () =>
                    ref.read(postProvider.notifier).sharePost(post.images),
              ),
            );
          },
        ),
      ),
    );
  }
}
