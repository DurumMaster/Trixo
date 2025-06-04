import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

class ReviewMapper {
  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userID: json['userID'] as String? ?? '',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : DateTime(1970, 1, 1),
    );
  }

  static Map<String, dynamic> toJson(Review review) {
    return {
      'id': review.id,
      'message': review.message,
      'rating': review.rating,
      'userID': review.userID,
      'fecha_creacion': review.fechaCreacion.toIso8601String(),
    };
  }
}