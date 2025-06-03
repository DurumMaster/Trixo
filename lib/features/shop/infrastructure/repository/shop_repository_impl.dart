import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

class ShopRepositoryImpl extends ShopRepository {
  final ShopDatasource datasource;

  ShopRepositoryImpl(this.datasource);

  @override
  Future<List<Product>> getActiveProducts() {
    return datasource.getActiveProducts();
  }
}
