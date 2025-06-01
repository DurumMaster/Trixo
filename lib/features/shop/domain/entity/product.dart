
class Product {
  final int id;
  final String nombre;
  final double precio;
  final String talla;
  final DateTime fechaCreacion;
  final int stock;
  final bool activo;
  final String descripcion;
  final String materiales;
  final String envio;
  final double valoracion;

  // --- Campos “derivados” de IMAGENES_PRODUCTOS ---
  /// Lista de URLs de imágenes asociadas a este producto
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.talla,
    required this.fechaCreacion,
    required this.stock,
    required this.activo,
    required this.descripcion,
    required this.materiales,
    required this.envio,
    required this.valoracion,
    required this.imageUrls,
  });

  /// Factory para construir un Product a partir de un JSON simulado
  /// El JSON esperado debe tener la forma:
  ///
  /// {
  ///   "id": 1,
  ///   "nombre": "Letterman Jacket",
  ///   "precio": 99.0,
  ///   "talla": "S,M,L,XL",
  ///   "fecha_creacion": "2023-08-15T10:23:00Z",
  ///   "stock": 42,
  ///   "activo": true,
  ///   "descripcion": "Texto largo de descripción...",
  ///   "materiales": "Cuerpo: Fieltro de lana... \nMangas: Piel vegana...",
  ///   "envio": "Envío estándar 3-5 días hábiles",
  ///   "valoracion": 4.5,
  ///   "imagenes": [
  ///     {"id": 10, "producto_id": 1, "url": "https://.../img1.png"},
  ///     {"id": 11, "producto_id": 1, "url": "https://.../img2.png"}
  ///   ]
  /// }
  ///
  factory Product.fromJson(Map<String, dynamic> json) {
    // Se asume que "imagenes" es una lista de objetos con clave "url"
    List<dynamic> rawImages = json['imagenes'] as List<dynamic>? ?? [];
    List<String> urls = rawImages
        .map((imgObj) => imgObj['url'] as String)
        .toList();

    return Product(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      talla: json['talla'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      stock: json['stock'] as int,
      activo: json['activo'] as bool,
      descripcion: json['descripcion'] as String,
      materiales: json['materiales'] as String,
      envio: json['envio'] as String,
      valoracion: (json['valoracion'] as num).toDouble(),
      imageUrls: urls,
    );
  }

  /// Opcional: convertir a JSON (por si se necesita enviar al backend)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'nombre': nombre,
  //     'precio': precio,
  //     'talla': talla,
  //     'fecha_creacion': fechaCreacion.toUtc().toIso8601String(),
  //     'stock': stock,
  //     'activo': activo,
  //     'descripcion': descripcion,
  //     'materiales': materiales,
  //     'envio': envio,
  //     'valoracion': valoracion,
  //     // Normalmente IMAGENES_PRODUCTOS se envía aparte, pero si quisiéramos anidarlas:
  //     'imagenes': imageUrls.map((url) => {'url': url}).toList(),
  //   };
  // }

}
