import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
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
  double _currentScale = 1.0;
  String _randomEmoji = '🧢';
  late String _randomEmojis;
  final Random _random = Random();
  final double _cardRadius = 12;
  final double _pageIndicatorSize = 6;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _generateRandomEmojis();
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
      _currentScale = 1.0;
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
          onScaleStart: (_) => _zoomController.stop(),
          onScaleUpdate: (details) {
            setState(() => _currentScale = details.scale.clamp(1.0, 5.0));
          },
          onScaleEnd: (_) {
            _zoomController
                .animateTo(0)
                .whenComplete(() => setState(() => _currentScale = 1.0));
          },
          child: Transform.scale(
            scale: _currentScale,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: widget.post.images[index],
                fit: BoxFit.cover,
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
        );
      },
    );
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

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      child: Row(
        children: [
          Row(
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
          icon: Icons.send_rounded,
          onPressed: () {},
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
          width: 32,
          height: 32,
          colorFilter: const ColorFilter.mode(
            Colors.red,
            BlendMode.srcIn,
          ),
        ),
        iconSize: iconSize + 8,
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
      child: Visibility(
        visible: widget.post.commentsCount > 0,
        child: GestureDetector(
          onTap: () {},
          child: Text(
            Intl.plural(
              widget.post.commentsCount,
              one: 'Ver todos los comentarios',
              other: 'Ver los ${widget.post.commentsCount} comentarios',
            ),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
