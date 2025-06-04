class Review {
  final int id;
  final String message;
  final double rating;
  final String userID;
  final DateTime fechaCreacion;

  Review({
    required this.id,
    required this.message,
    required this.rating,
    required this.userID,
    required this.fechaCreacion,
  });
}
