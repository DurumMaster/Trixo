import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

abstract class ShopDatasource {
  Future<List<Product>> getActiveProducts();
}
