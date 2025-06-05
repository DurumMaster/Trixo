import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lista de items en el carrito
    final cartItems = ref.watch(cartProvider);
    // Precio total (sin envío)
    final subtotal = ref.watch(cartProvider.notifier).totalPrice;
    // Tarifa de envío fija (puedes cambiarla o calcularla)
    const double delivery = 3.99;
    // Suma de subtotal + envío
    final total = subtotal + delivery;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito"),
        leading: const BackButton(),
      ),
      // El cuerpo muestra la lista de productos
      body: ListView(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          // Dejamos un espacio extra en la parte inferior
          // para que no quede oculto por el bottomSheet
          bottom: 160,
        ),
        children: [
          if (cartItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No hay productos en el carrito',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ...cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Botones de incrementar / decrementar cantidad
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .increaseQuantity(item.id, item.size),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .decreaseQuantity(item.id, item.size),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Tarjeta con imagen, nombre, talla y precio unitario
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Primera imagen del producto
                          Image.network(
                            item.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('Talla: ${item.size}'),
                                const SizedBox(height: 2),
                                Text('${item.price.toStringAsFixed(2)} €'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de eliminar producto
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => ref
                        .read(cartProvider.notifier)
                        .removeFromCart(item.id, item.size),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      // Aquí añadimos el CheckoutSummary en la parte inferior
      bottomSheet: CheckoutSummary(
        subtotal: subtotal,
        delivery: delivery,
        total: total,
        onCheckout: () {
          // Acción al pulsar Checkout. Por ejemplo, navegar a la pantalla de confirmación:
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) {
              // Reemplaza esto por la pantalla real de checkout
              //TODO: llevar zona stripe
              return Scaffold(
                appBar: AppBar(title: const Text('Checkout')),
                body: const Center(child: Text('Aquí iría el proceso de pago')),
              );
            }),
          );
        },
      ),
    );
  }
}
