import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';
import 'package:trixo_frontend/features/post/presentation/views/post_views.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onShare,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _likeController;
  late final Animation<double> _scaleAnimationLike;
  late final AnimationController _zoomController;

  final List<String> _fashionEmojis = const [
    '🧢',
    '👟',
    '🕶️',
    '🐐',
    '💸',
    '👀',
    '✨',
    '💎',
    '🧊',
    '🔥',
  ];

  int _currentPage = 0;
  String _randomEmoji = '🧢';
  late String _randomEmojis;
  final Random _random = Random();
  final double _cardRadius = 12;
  final double _pageIndicatorSize = 6;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  late final AnimationController _overlayPopupController;
  late final Animation<double> _overlayPopupAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _generateRandomEmojis();
    _overlayPopupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _overlayPopupAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _overlayPopupController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _initializeControllers() {
    _pageController = PageController(initialPage: 0, keepPage: false);

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(begin: 0, end: 1.5)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_animationController);

    _scaleAnimationLike = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(_animationDuration, () {
          if (mounted) _animationController.reverse();
        });
      }
    });
  }

  void _generateRandomEmojis() {
    final shuffled = List<String>.from(_fashionEmojis)..shuffle(_random);
    _randomEmojis = shuffled.take(3).join();
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _handleDoubleTap() {
    setState(() {
      _randomEmoji = _fashionEmojis[_random.nextInt(_fashionEmojis.length)];
    });
    _animationController.forward(from: 0);

    if (!widget.post.isLiked) {
      widget.onLike();
      _likeController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _likeController.dispose();
    _zoomController.dispose();
    _overlayPopupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: _buildCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          _buildPageIndicators(),
          _buildUserHeader(),
          _buildDescriptionSection(),
          _buildCommentsSection(),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(_cardRadius),
      );

  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: _buildImageCarousel(),
          ),
          _buildLikeAnimation(),
          _buildLikesBadge(),
          _buildPostOptions(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PageView.builder(
      controller: _pageController,
      physics: const ClampingScrollPhysics(),
      onPageChanged: _handlePageChange,
      itemCount: widget.post.images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPressStart: (details) {
            _showZoomOverlay(widget.post.images[index], details.globalPosition);
          },
          onLongPressEnd: (_) {
            _removeZoomOverlay();
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.images[index],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    progressIndicatorBuilder: (_, __, ___) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.white : AppColors.black,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Icon(
                      Icons.replay_rounded,
                      size: 50,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  OverlayEntry? _zoomOverlay;

  void _showZoomOverlay(String imageUrl, Offset _) {
    _overlayPopupController.forward(from: 0);

    _zoomOverlay = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _removeZoomOverlay,
          onLongPressEnd: (_) => _removeZoomOverlay(),
          child: Container(
            color: Colors.black.withOpacity(0.95),
            child: Center(
              child: ScaleTransition(
                scale: _overlayPopupAnimation,
                child: Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white,
                    ),
                    progressIndicatorBuilder: (_, __, ___) =>
                        const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_zoomOverlay!);
  }

  void _removeZoomOverlay() {
    _zoomOverlay?.remove();
    _zoomOverlay = null;
  }

  Widget _buildLikeAnimation() {
    return FadeTransition(
      opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Transform.rotate(
          angle: _random.nextDouble() * 0.4 - 0.2,
          child: Text(
            _randomEmoji,
            style: const TextStyle(
              fontSize: 64,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black45,
                  offset: Offset(0, 2),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    if (widget.post.images.length <= 1) {
      return const SizedBox(height: 10);
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.post.images.length,
          (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _pageIndicatorSize,
            height: _pageIndicatorSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == i
                  ? Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.black
                  : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikesBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: _randomEmojis),
              const WidgetSpan(child: SizedBox(width: 4)),
              TextSpan(
                text: HumanFormats.number(widget.post.likesCount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPostOptions() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Material(
          color: Colors.transparent,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            onSelected: (String value) {
              if (value == 'report') {
                _showReportDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: AppColors.error, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Reportar',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final textColor =
            isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Por qué quieres reportar esta publicación?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.flag, color: AppColors.error),
                title: const Text(
                  'Contenido inapropiado',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                tileColor: AppColors.error.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  _showReportMessageDialog(context, 'Contenido inapropiado');
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.airline_stops_rounded,
                    color: AppColors.error),
                title: const Text(
                  'Robo de diseño o plagio',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                tileColor: AppColors.error.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  _showReportMessageDialog(context, 'Contenido inapropiado');
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.bug_report, color: AppColors.error),
                title: const Text(
                  'Problema técnico',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                tileColor: AppColors.error.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  _showReportMessageDialog(context, 'Contenido inapropiado');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportMessageDialog(BuildContext context, String reason) {
    final TextEditingController controller = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              title: Text(
                'Reportar: $reason',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¿Quieres añadir un mensaje explicando el motivo del reporte?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 3,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu comentario (opcional)',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actions: [
                TextButton(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    final message = reason + controller.text;
                    ref.watch(postProvider.notifier).sendReport(
                          widget.post.id,
                          message,
                        );

                    Navigator.of(context).pop();
                    Navigator.of(context).maybePop();

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reporte enviado: $reason',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.post.user?.id != null) {
                context.push('/user/${widget.post.user!.id}');
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage(widget.post.user?.avatarImg ?? ""),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.post.user?.username ?? "Anónimo",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: 'assets/icons/send.svg',
          onPressed: () {
            widget.onShare();
          },
        ),
        const SizedBox(width: 5),
        _buildAnimatedLikeButton(),
      ],
    );
  }

  Widget _buildAnimatedLikeButton() {
    return GestureDetector(
      onTap: widget.onLike,
      child: AnimatedBuilder(
        animation: _likeController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimationLike.value,
            child: Icon(
              widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 26,
              color: widget.post.isLiked ? Colors.red : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButton({
    required dynamic icon,
    required VoidCallback onPressed,
  }) {
    const double iconSize = 26.0;

    if (icon is String) {
      return IconButton(
        icon: SvgPicture.asset(
          icon,
          width: 26,
          height: 26,
          colorFilter: ColorFilter.mode(
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.black,
            BlendMode.srcIn,
          ),
        ),
        iconSize: iconSize,
        onPressed: onPressed,
      );
    }

    return IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        widget.post.caption,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => CommentBottomSheet(
              postId: widget.post.id,
              userId: FirebaseAuth.instance.currentUser?.uid ?? "",
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.post.commentsCount == 0
                  ? 'Ver todos los comentarios'
                  : 'Ver los ${widget.post.commentsCount} comentarios',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            Text(HumanFormats.timeAgo(DateTime.parse(widget.post.createdAt))),
          ],
        ),
      ),
    );
  }
}
