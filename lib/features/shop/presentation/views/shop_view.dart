import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';
import 'package:trixo_frontend/features/shop/presentation/views/shop_views.dart';

class CustomPagePhysics extends ScrollPhysics {
  const CustomPagePhysics({super.parent});

  @override
  CustomPagePhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPagePhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 60,
        stiffness: 150,
        damping: 0.8,
      );
}

class TopCurvedCarousel extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<int> onProductChanged;
  final double height;
  final double itemWidth;
  final double radius;

  const TopCurvedCarousel({
    required this.products,
    required this.onProductChanged,
    this.height = 100,
    this.itemWidth = 50,
    this.radius = 220,
    super.key,
  });

  @override
  TopCurvedCarouselState createState() => TopCurvedCarouselState();
}

class TopCurvedCarouselState extends State<TopCurvedCarousel> {
  late PageController _pageController;
  final ValueNotifier<double> _pageOffset = ValueNotifier(5000.0);
  bool _initialized = false;
  late int _lastReportedIndex;

  @override
  void initState() {
    super.initState();
    _lastReportedIndex = 5000 % widget.products.length;
    _pageController = PageController(initialPage: 5000);
    _pageController.addListener(_onPageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onProductChanged(_lastReportedIndex);
    });
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      _pageOffset.value = _pageController.page!;
      final newIndex = (_pageController.page!.round()) % widget.products.length;
      if (newIndex != _lastReportedIndex) {
        _lastReportedIndex = newIndex;
        widget.onProductChanged(newIndex);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      const gap = 80.0;
      final fraction = (widget.itemWidth + gap) / screenWidth;

      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: 5000,
      );
      _pageController.addListener(_onPageChanged);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _pageOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalWidth = MediaQuery.of(context).size.width;
    final totalHeight = widget.height;

    const dotY = 20.0;
    const leftDotX = 70.0;
    final rightDotX = totalWidth - 70.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? Colors.white : Colors.black87;
    final arcColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Arco invertido (U)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: CustomPaint(
                    painter: _InvertedArcPainter(
                      color: arcColor,
                      strokeWidth: 4,
                    ),
                  ),
                ),
              ),

              // Dots en extremos
              Positioned(
                left: leftDotX,
                top: dotY,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: rightDotX - 8,
                top: dotY,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // PageView infinito
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 10000,
                  physics: const CustomPagePhysics(),
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final idxReal = index % widget.products.length;
                    final product = widget.products[idxReal];

                    return ValueListenableBuilder<double>(
                      valueListenable: _pageOffset,
                      builder: (context, pageOffset, child) {
                        final diff = index - pageOffset;
                        final absDiff = diff.abs();

                        final double angle = (diff * 0.22).clamp(-0.4, 0.4);
                        final double scale =
                            (1 - (absDiff * 0.12)).clamp(0.7, 1.0);

                        const double baseElevation = -35.0;

                        double valleyCurve = 0;
                        if (absDiff < 2.5) {
                          valleyCurve = pow(absDiff, 1.5) * 25;
                        }

                        double yOffset = baseElevation - valleyCurve;

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..translate(0.0, yOffset)
                            ..rotateY(angle)
                            ..scale(scale, scale),
                          alignment: Alignment.center,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: SizedBox(
                              width: widget.itemWidth,
                              height: totalHeight,
                              child: _ThumbnailCard(product: product),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Flechas inferiores con animación mejorada
              Positioned(
                bottom: 22,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedArrowButton(
                      icon: Icons.arrow_back_ios,
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _AnimatedArrowButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                        );
                      },
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
}

class _AnimatedArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedArrowButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  _AnimatedArrowButtonState createState() => _AnimatedArrowButtonState();
}

class _AnimatedArrowButtonState extends State<_AnimatedArrowButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(widget.icon, color: iconColor, size: 18),
        ),
      ),
    );
  }
}

// Arco invertido "U"
class _InvertedArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _InvertedArcPainter({required this.color, this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height * 0.9, size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Tarjeta miniatura
class _ThumbnailCard extends StatelessWidget {
  final Product product;
  const _ThumbnailCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbUrl =
        (product.imageUrls.isNotEmpty) ? product.imageUrls.first : null;

    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.3);
    final iconColor = isDark ? Colors.white38 : Colors.black38;
    final progressColor = isDark ? Colors.white54 : Colors.black45;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (thumbUrl != null)
            ? Image.network(
                thumbUrl,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: progressColor,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.refresh,
                  color: iconColor,
                  size: 32,
                ),
              ),
      ),
    );
  }
}

/// ------------------------------------------------
///  PINTOR DEL ARCO GRISÁCEO DE FONDO
/// ------------------------------------------------
class ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ArcPainter({required this.color, this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final curveDepth = size.height * 1.5;
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      size.width / 2,
      curveDepth, // punto más bajo
      size.width,
      0,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ------------------------------------------------
/// 2) CARRUSEL “PLANO” DE IMÁGENES DEL PRODUCTO
/// ------------------------------------------------

class MainImageCarousel extends StatefulWidget {
  final Product product;
  final ValueChanged<int>? onImageChanged;
  final PageController? externalController;

  const MainImageCarousel({
    required this.product,
    this.onImageChanged,
    this.externalController,
    super.key,
  });

  @override
  MainImageCarouselState createState() => MainImageCarouselState();
}

class MainImageCarouselState extends State<MainImageCarousel> {
  late PageController _pageController;
  int _currentInner = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
  }

  @override
  void didUpdateWidget(covariant MainImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _currentInner = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrls;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeDotColor = isDark ? Colors.white : Colors.black;
    final inactiveDotColor = isDark ? Colors.white30 : Colors.grey[500];
    final loaderColor = isDark ? Colors.white : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (idx) {
              setState(() => _currentInner = idx);
              if (widget.onImageChanged != null) widget.onImageChanged!(idx);
            },
            itemBuilder: (context, index) {
              final url = images[index];
              return Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, prog) {
                  if (prog == null) return child;
                  return Center(
                    child: CircularProgressIndicator(color: loaderColor),
                  );
                },
              );
            },
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final isActive = _currentInner == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? activeDotColor : inactiveDotColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// ------------------------------------------------
/// 3) SECCIÓN “Info” (Nombre, Precio, Tallas, Avatar)
/// ------------------------------------------------

class ProductInfoSection extends ConsumerWidget {
  final Product product;

  const ProductInfoSection({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSize = ref.watch(shopProvider.select((s) => s.selectedSize));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black87;
    final fadedBorderColor = isDark ? Colors.white38 : Colors.black26;
    final selectedSizeBg = isDark ? Colors.white : Colors.black;
    final selectedSizeText = isDark ? Colors.black : Colors.white;
    final unselectedSizeText = isDark ? Colors.white : Colors.black;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nombre + Precio
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${product.precio.toStringAsFixed(0)}€',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tallas y creador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tallas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tallas',
                      style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: product.talla
                          .split(',')
                          .map((s) => s.trim())
                          .map((sizeCad) {
                        final isSel = (selectedSize == sizeCad);
                        return GestureDetector(
                          onTap: () {
                            ref.read(shopProvider).selectSize(sizeCad);
                          },
                          child: Container(
                            width: 40,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  isSel ? selectedSizeBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isSel ? selectedSizeText : fadedBorderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              sizeCad,
                              style: TextStyle(
                                color: isSel
                                    ? selectedSizeText
                                    : unselectedSizeText,
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () => context.push('/user/${product.userID}'),
                  child: _UserCreatorInfo(uid: product.userID),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCreatorInfo extends ConsumerWidget {
  final String uid;

  const _UserCreatorInfo({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(creatorProvider(uid));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final borderColor = isDark ? Colors.white30 : Colors.black26;
    final loaderColor = isDark ? Colors.white : Colors.black;
    const errorColor = Colors.red;

    return userAsync.when(
      loading: () => Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: loaderColor),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Center(
              child: Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: loaderColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
      error: (error, stack) => const Column(
        children: [
          Icon(Icons.error_outline, color: errorColor, size: 24),
          SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              'Error',
              style: TextStyle(color: errorColor, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      data: (user) => Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: ClipOval(
              child: Image.network(
                user.avatarImg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, color: textColor, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              user.username,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------
/// 4) BOTÓN “Add To Cart”
/// ------------------------------------------------

class AddToCartSection extends ConsumerWidget {
  const AddToCartSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shopProvider);
    final selectedSize = ref.watch(shopProvider.select((s) => s.selectedSize));
    final product = notifier.product;
    final isOutOfStock = product?.stock == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: MUILoadingButton(
          text: isOutOfStock ? 'Agotado' : 'Añadir al carrito',
          loadingStateText: 'Añadiendo...',
          onPressed: (product == null || isOutOfStock)
              ? null
              : () async {
                  if (selectedSize == null || selectedSize.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, selecciona una talla antes de añadir al carrito',
                        ),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  ref.read(cartProvider.notifier).addToCart(
                        CartItem(
                          id: product.id,
                          name: product.nombre,
                          price: product.precio,
                          imageUrl: product.imageUrls.first,
                          size: selectedSize,
                        ),
                      );
                },
          leadingIcon: isOutOfStock ? Icons.lock : null,
          borderRadius: 12.0,
          animationDuration: 250,
          hapticsEnabled: false,
          widthFactorUnpressed: 0.04,
          widthFactorPressed: 0.035,
          heightFactorUnPressed: 0.03,
          heightFactorPressed: 0.025,
          maxHorizontalPadding: 50,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------
/// 5) RATING + “Read all X reviews”
/// ------------------------------------------------

class RatingReviewsSection extends StatelessWidget {
  final Product product;

  const RatingReviewsSection({required this.product, super.key});

  Widget _starIcon(bool filled, Color color) {
    return Icon(
      filled ? Icons.star : Icons.star_border,
      size: 24,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final starColor = Colors.yellow[700]!;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    final int fullStars = product.valoracion.floor();
    final bool hasHalf = (product.valoracion - fullStars) >= 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Estrellas
          Row(
            children: List.generate(5, (i) {
              if (i < fullStars) {
                return _starIcon(true, starColor);
              } else if (i == fullStars && hasHalf) {
                return Icon(Icons.star_half, size: 24, color: starColor);
              } else {
                return _starIcon(false, starColor);
              }
            }),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                return;
              }

              final uid = currentUser.uid;

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => ReviewBottomSheet(
                  productId: product.id,
                  userId: uid,
                ),
              );
            },
            child: Text(
              'Ver todas las valoraciones',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------
/// 6) SECCIÓN “Especificaciones y Descripción”
/// ------------------------------------------------

class SpecsAndDescriptionSection extends StatelessWidget {
  final Product product;

  const SpecsAndDescriptionSection({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 6.1) Descripción
          Text(
            'Descripción',
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.descripcion,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),
          // 6.2) Materiales
          Text(
            'Materiales',
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.materiales,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),
          // 6.3) Envío
          Text(
            'Envío',
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.envio,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// ------------------------------------------------
/// 7) PANTALLA PRINCIPAL: ShopView (ConsumerStateful)
/// ------------------------------------------------

class ShopView extends ConsumerStatefulWidget {
  const ShopView({super.key});

  @override
  ShopViewState createState() => ShopViewState();
}

class ShopViewState extends ConsumerState<ShopView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 1) Cargo TODOS los productos
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(shopProvider).loadAllProducts();
      final todos = ref.read(shopProvider).products;
      if (todos.isNotEmpty) {
        // 2) Muestro el primer producto por defecto
        await ref.read(shopProvider).loadProductById(todos.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeNotifier = ref.watch(shopProvider);
    final List<Product> allProducts = storeNotifier.products;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final Product? producto =
        allProducts.isNotEmpty && _selectedIndex < allProducts.length
            ? allProducts[_selectedIndex]
            : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartView()),
              );
            },
          ),
        ],
      ),
      body: allProducts.isEmpty
          // ─────────── Mostrar loader general ───────────
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : Colors.black87,
              ),
            )
          // ───────────────────────────────────────────────
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ══ 7.1) TOP CURVED CAROUSEL (miniaturas) ══
                  TopCurvedCarousel(
                    products: allProducts,
                    height: 80,
                    itemWidth: 40,
                    radius: 200,
                    onProductChanged: (indexEnCarrusel) {
                      setState(() {
                        _selectedIndex = indexEnCarrusel;
                      });
                    },
                  ),

                  // ══ 7.2) MAIN IMAGE CAROUSEL (imágenes del producto) ══
                  if (producto != null)
                    MainImageCarousel(
                      product: producto,
                      onImageChanged: (innerIdx) {
                        // Opcional: podrías notificar al provider de la imagen actual
                        ref.read(shopProvider).setImageIndex(innerIdx);
                      },
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                  // ══ 7.3) Product Info (Nombre + Precio + Tallas) ══
                  if (producto != null)
                    ProductInfoSection(product: producto)
                  else
                    const SizedBox.shrink(),

                  // ══ 7.4) Add to Cart ══
                  const AddToCartSection(),

                  // ══ 7.5) Rating + Reviews ══
                  if (producto != null)
                    RatingReviewsSection(product: producto)
                  else
                    const SizedBox.shrink(),

                  // ══ 7.6) Specs & Description ══
                  if (producto != null)
                    SpecsAndDescriptionSection(product: producto)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }
}
