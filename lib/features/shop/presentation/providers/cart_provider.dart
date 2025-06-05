import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(CartItem newItem) {
    final index = state.indexWhere((item) => item.id == newItem.id && item.size == newItem.size);
    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItem(
              id: state[i].id,
              name: state[i].name,
              size: state[i].size,
              price: state[i].price,
              imageUrl: state[i].imageUrl,
              quantity: state[i].quantity + 1,
            )
          else
            state[i],
      ];
    } else {
      state = [...state, newItem];
    }
  }

  void removeFromCart(int id, String size) {
    state = state.where((item) => !(item.id == id && item.size == size)).toList();
  }

  void increaseQuantity(int id, String size) {
    state = state.map((item) {
      if (item.id == id && item.size == size) {
        return CartItem(
          id: item.id,
          name: item.name,
          size: item.size,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity + 1,
        );
      }
      return item;
    }).toList();
  }

  void decreaseQuantity(int id, String size) {
    state = state.map((item) {
      if (item.id == id && item.size == size && item.quantity > 1) {
        return CartItem(
          id: item.id,
          name: item.name,
          size: item.size,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity - 1,
        );
      }
      return item;
    }).toList();
  }

  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());
