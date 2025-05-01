import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trixo_frontend/config/config.dart';

class PostCard extends StatefulWidget {
  final List<String> imageUrls;
  final String username;
  final String avatarUrl;
  final String description;
  final int likeCount;
  final int commentsCount;
  final VoidCallback onDoubleTapImage;

  const PostCard({
    super.key,
    required this.imageUrls,
    required this.username,
    required this.avatarUrl,
    required this.description,
    required this.likeCount,
    required this.commentsCount,
    required this.onDoubleTapImage,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late final PageController _pageController;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  int _currentPage = 0;
  final double _cardRadius = 12;
  final double _pageIndicatorSize = 6;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  bool _isLiked = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimationLike;

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
  String _randomEmoji = '🧢';
  late String randomEmojis = '🧢🕶️🐐';
  final random = Random();

  double _currentScale = 1.0;
  late AnimationController _zoomController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _scaleAnimation = _createScaleAnimation();
    _setupAnimationListener();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimationLike = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    final shuffled = List<String>.from(_fashionEmojis)..shuffle(random);
    randomEmojis = shuffled.take(3).join();

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Animation<double> _createScaleAnimation() => Tween<double>(begin: 0, end: 1.5)
      .chain(CurveTween(curve: Curves.easeOut))
      .animate(_animationController);

  void _setupAnimationListener() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(_animationDuration, () {
          if (mounted) _animationController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _controller.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentScale = 1.0; // Resetear zoom al cambiar de imagen
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: _buildCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          _buildUserHeader(),
          _buildDescriptionSection(),
          _buildCommentsSection(context),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(_cardRadius),
      );

  Widget _buildImageSection(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onDoubleTap: () {
            final random = Random();
            setState(() {
              _randomEmoji =
                  _fashionEmojis[random.nextInt(_fashionEmojis.length)];
            });

            // Siempre reproduce la animación del corazón flotante
            _animationController.forward(from: 0);

            // Solo da like si no estaba activado previamente
            if (!_isLiked) {
              setState(() => _isLiked = true);
              _controller.forward(); // Animación del icono
              widget.onDoubleTapImage(); // Lógica futura (Firebase)
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildImageCarousel(),
              _buildLikeAnimation(),
              if (widget.imageUrls.length > 1) _buildPageIndicators(),
              _buildLikesBadge(context),
            ],
          ),
        ));
  }

  Widget _buildImageCarousel() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _handlePageChange,
      itemCount: widget.imageUrls.length,
      itemBuilder: (_, index) => GestureDetector(
        onScaleStart: (_) => _zoomController.stop(),
        onScaleUpdate: (details) {
          setState(() => _currentScale = details.scale.clamp(1.0, 5.0));
        },
        onScaleEnd: (_) {
          _zoomController.animateTo(0,
              duration: const Duration(milliseconds: 300))
            .whenComplete(() => setState(() => _currentScale = 1.0));
        },
        child: Transform.scale(
          scale: _currentScale,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              progressIndicatorBuilder: (_, __, ___) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikeAnimation() {
    return FadeTransition(
        opacity: _animationController.drive(Tween(begin: 0.0, end: 1.0)),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Transform.rotate(
            angle: random.nextDouble() * 0.4 - 0.2,
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
        ));
  }

  Widget _buildPageIndicators() {
    return Positioned(
      bottom: 10,
      child: Wrap(
        spacing: 4,
        children: List.generate(
            widget.imageUrls.length,
            (i) => Container(
                  width: _pageIndicatorSize,
                  height: _pageIndicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i
                        ? AppColors.accent
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                  ),
                )),
      ),
    );
  }

  Widget _buildLikesBadge(BuildContext context) {
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
              TextSpan(text: randomEmojis),
              const WidgetSpan(child: SizedBox(width: 4)),
              TextSpan(
                text: HumanFormats.number(widget.likeCount),
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Sección izquierda: Avatar y nombre
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
              const SizedBox(width: 12),
              Text(
                widget.username,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),

          // Espacio flexible para empujar los botones a la derecha
          Expanded(child: Container()),

          // Botones de acción
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          //TODO: arreglar para utilizar svg send
          icon: Icons.send_rounded,
          onPressed: () {},
        ),
        const SizedBox(width: 5),
        _buildAnimatedLikeButton(),
      ],
    );
  }

  Widget _buildAnimatedLikeButton() {
    const double likeIconSize = 26.0;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLiked = !_isLiked;
          if (_isLiked) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimationLike.value,
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              size: likeIconSize,
              color: _isLiked ? Colors.red : Theme.of(context).iconTheme.color,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButton(
      {required dynamic icon, required VoidCallback onPressed}) {
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
        onPressed: onPressed);
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        widget.description,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Visibility(
        visible: widget.commentsCount > 0,
        child: GestureDetector(
          onTap: () {},
          child: Text(
            Intl.plural(
              widget.commentsCount,
              one: 'Ver todos los comentarios',
              other: 'Ver los ${widget.commentsCount} comentarios',
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
