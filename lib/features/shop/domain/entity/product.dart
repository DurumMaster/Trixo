class Product {
  final int id;
  final String nombre;
  final double precio;
  final String talla;
  final String userID;
  final DateTime fechaCreacion;
  final int stock;
  final bool activo;
  final String descripcion;
  final String materiales;
  final String envio;
  final double valoracion;
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.talla,
    required this.userID,
    required this.fechaCreacion,
    required this.stock,
    required this.activo,
    required this.descripcion,
    required this.materiales,
    required this.envio,
    required this.valoracion,
    required this.imageUrls,
  });
}
