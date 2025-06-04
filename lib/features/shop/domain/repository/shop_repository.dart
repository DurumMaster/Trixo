import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

abstract class ShopRepository {
  Future<List<Product>> getActiveProducts();
  Future<List<Review>> getReviews(int productId);
  Future<void> sendReview(int productId, Review review);
}
