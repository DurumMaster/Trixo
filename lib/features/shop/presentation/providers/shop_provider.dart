import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

class ShopNotifier extends ChangeNotifier {
  Product? _product;
  int _currentImageIndex = 0;
  String? _selectedSize;

  Product? get product => _product;
  int get currentImageIndex => _currentImageIndex;
  String? get selectedSize => _selectedSize;

  /// Simula la carga de un producto desde el backend (por ahora: JSON hardcode).
  /// En un caso real, aquí harías una llamada HTTP y mapearías con Product.fromJson.
  Future<void> loadProductById(int productId) async {
    // Simulación de retraso en red
    await Future.delayed(const Duration(milliseconds: 500));

    // JSON simulado que vendría de tu endpoint: /api/productos/1
    final simulatedJson = {
      "id": 1,
      "nombre": "Americana a cuadros",
      "precio": 99.0,
      "talla": "S,M,L,XL",
      "fecha_creacion": "2023-08-15T10:23:00Z",
      "stock": 42,
      "activo": true,
      "descripcion":
          "Rinde homenaje al espíritu competitivo, la hermandad y el orgullo académico que definieron generaciones en los campus estadounidenses. Rediseñada para el entorno urbano moderno, esta prenda encapsula el equilibrio perfecto entre nostalgia college y estilo contemporáneo.",
      "materiales":
          "Cuerpo:\n  • Fieltro de lana premium (80% lana, 20% poliéster) en azul royal.\n\nMangas:\n  • Piel vegana blanca con textura suave y acabado mate.\n\nForro:\n  • Satén acolchado gris perla, transpirable y suave.\n\nRibetes:\n  • Canalé elástico azul y blanco en cuello, puños y cintura.\n\nCierre:\n  • Botones metálicos a presión en níquel pulido.\n\nBolsillos:\n  • Dos exteriores con ribete blanco y uno interior con cierre.",
      "envio": "Envío estándar 3-5 días hábiles",
      "valoracion": 4.5,
      // Lista de imágenes: esto vendría de IMAGENES_PRODUCTOS filtrado por producto_id = 1
      "imagenes": [
        {
          "id": 10,
          "producto_id": 1,
          "url":
              "https://firebasestorage.googleapis.com/v0/b/trixo-1eacc.firebasestorage.app/o/shop_items%2Fwoman-business-suit-by-brick-wall%20(1).jpg?alt=media&token=e26b470f-a70a-4f55-b0e5-15d79781bae9"
        },
        {
          "id": 11,
          "producto_id": 1,
          "url":
              "https://firebasestorage.googleapis.com/v0/b/trixo-1eacc.firebasestorage.app/o/shop_items%2Fwoman-business-suit-by-brick-wall.jpg?alt=media&token=b8d01884-dd46-4e63-8be2-054153aec7d1"
        },
        {
          "id": 12,
          "producto_id": 1,
          "url":
              "https://firebasestorage.googleapis.com/v0/b/trixo-1eacc.firebasestorage.app/o/shop_items%2Fyoung-beautiful-woman-business-suit.jpg?alt=media&token=cde37b8a-3982-4d52-9b61-9a95a8599210"
        },
      ]
    };

    // Mapeamos el JSON simulado a un objeto Product
    _product = Product.fromJson(simulatedJson);
    // Reseteamos estado
    _currentImageIndex = 0;
    _selectedSize = null;
    notifyListeners();
  }

  /// Cambia la imagen actual en el carrusel (índice)
  void setImageIndex(int index) {
    if (_product == null) return;
    if (index < 0 || index >= _product!.imageUrls.length) return;
    _currentImageIndex = index;
    notifyListeners();
  }

  /// Selecciona una talla (p.e. "S", "M", "L", "XL")
  void selectSize(String size) {
    _selectedSize = size;
    notifyListeners();
  }

  /// “Añadir al carrito” (puedes ampliar con lógica de tu repositorio/servicio)
  void addToCart() {
    if (_product == null) return;

    // Aquí iría la llamada real a un repositorio o servicio:
    //   carritoService.addItem(_product.id, _selectedSize, quantity: 1);
    // Por simplicidad ahora:
    print(
      'Añadiendo al carrito: productoId=${_product!.id}, '
      'nombre=${_product!.nombre}, talla=$_selectedSize',
    );
  }
}

final shopProvider =
    ChangeNotifierProvider<ShopNotifier>((ref) => ShopNotifier());
