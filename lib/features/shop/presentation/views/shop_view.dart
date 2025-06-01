import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';

/// --- VIEW PRINCIPAL: StoreView ---
/// Consumidor de Riverpod (ConsumerStatefulWidget) para poder hacer una llamada
/// a loadProductById() en initState y manejar un PageController.
class ShopView extends ConsumerStatefulWidget {
  const ShopView({super.key});

  @override
  _StoreViewState createState() => _StoreViewState();
}

class _StoreViewState extends ConsumerState<ShopView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Creamos un PageController, el índice inicial lo leeremos cuando cargue el producto
    _pageController = PageController(initialPage: 0, viewportFraction: 1);

    // Pedimos al provider que cargue el producto de ID = 1 (por ejemplo)
    // Cuando termine, el notifier notificará y reconstruirá la UI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopProvider).loadProductById(1);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeNotifier = ref.watch(shopProvider);
    final product = storeNotifier.product;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              //TODO: CARRITO
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: product == null
          // Mientras el producto se carga ─indicamos un spinner
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          // Cuando ya tenemos el producto, dibujamos la UI
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1) Imagen principal (PageView) con el controlador
                  _MainProductImage(
                    pageController: _pageController,
                    product: product,
                  ),

                  // 2) Carrusel de dots + flechas
                  _DotsWithArrows(
                    pageController: _pageController,
                    product: product,
                  ),

                  // 3) Nombre y precio
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: _NameAndPriceRow(product: product),
                  ),

                  // 4) Selector de tallas (parseamos la cadena product.talla)
                  //    + Autor (no tenemos autor en la DB, lo omitimos aquí)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _SizeSelector(product: product),
                  ),

                  // 5) Botón "Add to cart"
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 16.0),
                    child: _AddToCartButton(),
                  ),

                  // 6) Rating (valoración) + “Ver reseñas”
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _RatingAndReviewsLink(product: product),
                  ),

                  // 7) Sección de especificaciones (scrollable)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: _SpecificationsSection(product: product),
                  ),
                ],
              ),
            ),
    );
  }
}

/// 1) Carrusel de indicadores (dots + flechas)
class _DotsWithArrows extends ConsumerWidget {
  final PageController pageController;
  final Product product;

  const _DotsWithArrows({
    required this.pageController,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeNotifier = ref.watch(shopProvider);
    final total = product.imageUrls.length;
    final current = storeNotifier.currentImageIndex;

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flecha izquierda
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
            onPressed: current > 0
                ? () {
                    pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                : null,
          ),

          // Dots
          Row(
            children: List.generate(total, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: current == index ? 12 : 8,
                height: current == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: current == index ? Colors.white : Colors.white38,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          // Flecha derecha
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
            onPressed: current < total - 1
                ? () {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// 2) Imagen principal (PageView) que muestra cada URL de product.imageUrls
class _MainProductImage extends ConsumerWidget {
  final PageController pageController;
  final Product product;

  const _MainProductImage({
    required this.pageController,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Actualizamos el índice cuando el usuario desliza
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: pageController,
        itemCount: product.imageUrls.length,
        onPageChanged: (idx) {
          ref.read(shopProvider).setImageIndex(idx);
        },
        itemBuilder: (context, index) {
          return Image.network(
            product.imageUrls[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}

/// 3) Fila con el nombre (nombre) y el precio
class _NameAndPriceRow extends StatelessWidget {
  final Product product;

  const _NameAndPriceRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nombre (nombre)
        Text(
          product.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Precio (precio—tipo decimal)
        Text(
          '${product.precio.toStringAsFixed(0)}€',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 4) Selector de tallas + (aquí no hay autor, porque la DB no lo define)
class _SizeSelector extends ConsumerWidget {
  final Product product;

  const _SizeSelector({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parseamos la cadena product.talla: por ejemplo "S,M,L,XL"
    final opciones = product.talla.split(',').map((s) => s.trim()).toList();
    final selected = ref.watch(shopProvider.select((s) => s.selectedSize));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label "Tallas"
        const Text(
          'Tallas',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),

        // Botones para cada opción de talla
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 10,
            children: opciones.map((tallaCad) {
              final isSelected = (selected == tallaCad);
              return GestureDetector(
                onTap: () {
                  ref.read(shopProvider).selectSize(tallaCad);
                },
                child: Container(
                  width: 40,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.white38,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tallaCad,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// 5) Botón "Add to Cart"
class _AddToCartButton extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shopProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: MUILoadingButton(
              text: 'Añadir al carrito',
              // Si quieres texto distinto mientras carga:
              loadingStateText: 'Añadiendo...',
              onPressed: notifier.product == null
                  ? null
                  : () async {
                      // Lógica síncrona convertida en Future para que el botón muestre loading
                      notifier.addToCart();
                    },
              borderRadius: 12.0,
              animationDuration: 250,
              hapticsEnabled: false,
              // Ajusta factores a tu gusto o déjalos por defecto
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
        ],
      ),
    );
  }
}

/// 6) Rating con estrellas + enlace a la pantalla de reseñas
class _RatingAndReviewsLink extends StatelessWidget {
  final Product product;

  const _RatingAndReviewsLink({required this.product});

  Widget _starIcon(bool filled) {
    return Icon(
      filled ? Icons.star : Icons.star_border,
      size: 24,
      color: Colors.yellow[700],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Valoración (ej. 4.5) la convertimos en estrellas completas/medias
    final fullStars = product.valoracion.floor();
    final hasHalfStar = (product.valoracion - fullStars) >= 0.5;

    return Row(
      children: [
        // Estrellas
        Row(
          children: List.generate(5, (index) {
            if (index < fullStars) {
              return _starIcon(true);
            } else if (index == fullStars && hasHalfStar) {
              return Icon(
                Icons.star_half,
                size: 24,
                color: Colors.yellow[700],
              );
            } else {
              return _starIcon(false);
            }
          }),
        ),

        const SizedBox(width: 12),

        // Texto “Ver reseñas” (aquí no tenemos el conteo, así que simplemente navega)
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/reviews');
          },
          child: const Text(
            'Ver reseñas',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

/// 7) Sección de especificaciones SIN scroll propio,
/// ahora es un simple Column que forma parte del scroll general.
class _SpecificationsSection extends StatelessWidget {
  final Product product;

  const _SpecificationsSection({required this.product})
;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fondo distinto y bordes superiores redondeados
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 7.1) Descripción
          const Text(
            'Descripción',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // 7.2) Materiales
          const Text(
            'Materiales',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.materiales,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // 7.3) Envío
          const Text(
            'Envío',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.envio,
            style: const TextStyle(
              color: Colors.white70,
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
