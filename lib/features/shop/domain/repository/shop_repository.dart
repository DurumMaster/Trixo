import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

abstract class ShopRepository {
  Future<List<Product>> getActiveProducts();
}
