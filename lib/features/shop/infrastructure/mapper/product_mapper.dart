import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

class ProductMapper {
  static Product fromJson(Map<String, dynamic> json) {
    final List<String> imageUrls = (json['images'] as List<dynamic>? ?? [])
        .map((e) => e as String)
        .toList();

    return Product(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      talla: json['talla'] as String? ?? '',
      userID: json['userID'] as String? ?? '',
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime(1970, 1, 1),
      stock: json['stock'] as int? ?? 0,
      activo: json['activo'] as bool? ?? false,
      descripcion: json['descripcion'] as String? ?? '',
      materiales: json['materiales'] as String? ?? '',
      envio: json['envio'] as String? ?? '',
      valoracion: (json['valoracion'] as num?)?.toDouble() ?? 0.0,
      imageUrls: imageUrls,
    );
  }
}
