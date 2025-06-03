import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';

class ShopNotifier extends ChangeNotifier {
  final ShopRepository _repository;

  ShopNotifier(this._repository);

  List<Product> _products = [];
  Product? _product;
  int _currentImageIndex = 0;
  String? _selectedSize;

  List<Product> get products => _products;
  Product? get product => _product;
  int get currentImageIndex => _currentImageIndex;
  String? get selectedSize => _selectedSize;

  /// Cargar todos los productos desde el backend
  Future<void> loadAllProducts() async {
    try {
      final result = await _repository.getActiveProducts();
      _products = result;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }
  }

  /// Cargar un producto específico por ID desde la lista local
  Future<void> loadProductById(int productId) async {
    if (_products.isEmpty) {
      await loadAllProducts();
    }

    _product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );
    _currentImageIndex = 0;
    _selectedSize = null;
    notifyListeners();
  }

  void setImageIndex(int index) {
    if (_product == null) return;
    if (index < 0 || index >= _product!.imageUrls.length) return;
    _currentImageIndex = index;
    notifyListeners();
  }

  void selectSize(String size) {
    _selectedSize = size;
    notifyListeners();
  }

  void addToCart() {
    if (_product == null) return;

    debugPrint(
      'Añadiendo al carrito: productoId=${_product!.id}, '
      'nombre=${_product!.nombre}, talla=$_selectedSize',
    );
  }
}

final shopProvider = ChangeNotifierProvider<ShopNotifier>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return ShopNotifier(repository);
});

//*CREATOR

final creatorProvider = FutureProvider.family<User, String>((ref, userId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getUser(userId);
});
