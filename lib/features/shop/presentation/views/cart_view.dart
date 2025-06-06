import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/cart_provider.dart';
import 'package:trixo_frontend/features/shared/widgets/checkout_summary.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<CartItem> cartItems = ref.watch(cartProvider);

    final double subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    double delivery = cartItems.isEmpty ? 0.00 : 3.99;

    final double total = subtotal + delivery;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Carrito",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: BackButton(
          color: isDark ? Colors.white : Colors.black,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No hay productos en el carrito',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            // [+] [quantity] [-]
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .increaseQuantity(
                                          item.id,
                                          item.size,
                                        );
                                  },
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .decreaseQuantity(
                                          item.id,
                                          item.size,
                                        );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(width: 8),

                            // Tarjeta con imagen, nombre, talla y precio unitario
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white : Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.refresh),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Talla: ${item.size}',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.black87
                                                  : Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.price.toStringAsFixed(2)} €',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.black87
                                                  : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                ref.read(cartProvider.notifier).removeFromCart(
                                      item.id,
                                      item.size,
                                    );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          CheckoutSummary(
            subtotal: subtotal,
            delivery: delivery,
            total: total,
            onCheckout: () async {
              if (cartItems.isNotEmpty) {
                context.push(
                  "/checkout_confirmation",
                  extra: {
                    'subtotal': subtotal,
                    'delivery': delivery,
                    'total': total,
                  },
                );
              } else {
                null;
              }
            },
          ),
        ],
      ),
    );
  }
}
