import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trixo_frontend/config/config.dart';

// Widget principal de la tarjeta de publicación
class PostCard extends StatefulWidget {
  // Datos que recibirá este widget:
  final List<String> imageUrls; // URLs de las imágenes del carrusel
  final String username; // Nombre de usuario creador de la publicación
  final String avatarUrl; // URL de la foto de perfil
  final String description; // Descripción del post
  final int likeCount; // Número total de likes
  final String lastLikes; // Emoji del último like (e.g., "❤️", "🔥")
  final int commentsCount; // Cantidad de comentarios
  final VoidCallback
      onDoubleTapImage; // Callback cuando se hace doble tap en la imagen ??? [No se si necesario mandarlo en vez de hacerlo directamente en el widget]

  const PostCard({
    super.key,
    required this.imageUrls,
    required this.username,
    required this.avatarUrl,
    required this.description,
    required this.likeCount,
    required this.lastLikes,
    required this.commentsCount,
    required this.onDoubleTapImage, // Aquí enlazarás la lógica para registrar el like
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  // Controlador de páginas para el carrusel
  final PageController _pageController = PageController();
  // Índice de la página actual
  int _currentPage = 0;
  // Controlador para zoom/panning de la imagen
  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false; // Estado de zoom

  // Animación para el emoji de like en el centro
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializamos el AnimationController para la animación del emoji
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Tween de escala de 0 a 1.5 con curva easeOut
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_animationController);
    // Al completar la animación, esperamos 300ms y luego revertimos
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _animationController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Resetea el zoom al valor original
  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _isZoomed = false);
  }

  // Maneja el doble tap: lanza la animación y ejecuta callback para lógica externa
  void _handleDoubleTap() {
    _animationController.forward(from: 0.0);
    widget.onDoubleTapImage(); // <-- Aquí añades la lógica de like en la BD
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si está en modo oscuro o claro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARRUSEL DE IMÁGENES + ZOOM + DOBLE TAP
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                onInteractionEnd: (_) => _resetZoom(),
                panEnabled: false,
                minScale: 1,
                maxScale: 4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // El PageView muestra las imágenes deslizando
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    // EMOJI DE LIKE ANIMADO EN EL CENTRO
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Opacity(
                        opacity: _animationController.value > 0 ? 1.0 : 0.0,
                        child: Text(
                          widget.lastLikes,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),

                    // INDICADORES DE PÁGINA (círculos abajo)
                    if (widget.imageUrls.length > 1)
                      Positioned(
                        bottom: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.imageUrls.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? AppColors.accent
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // BADGE DE LIKE (esquina superior izquierda)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(widget.lastLikes),
                            const SizedBox(width: 4),
                            Text(
                              HumanFormats.number(widget.likeCount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LIST TILE: Avatar + Username + Más opciones
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            title: Text(
              widget.username,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: const Icon(Icons.more_horiz),
            onTap: () {
              // <-- Aquí navegas al perfil del usuario
            },
          ),

          // DESCRIPCIÓN (máx 3 líneas con "... more")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const TextSpan(
                    text: '... más',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // TEXTO DE COMENTARIOS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GestureDetector(
              onTap: () {
                // <-- Aquí navegas a la pantalla de comentarios
              },
              child: Text(
                //TODO: solo hacer si hay algún comentario (si hay uno quitar 's')
                'Ver los ${widget.commentsCount} comentarios',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),

          // ICONOS DE ACCIONES (enviar y like)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/send.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .colorScheme
                          .onSurface, // Se adapta al tema claro/oscuro
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    // <-- Lógica para compartir
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // <-- Lógica para dar like manual
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
