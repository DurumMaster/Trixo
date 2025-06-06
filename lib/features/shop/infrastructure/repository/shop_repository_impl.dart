import 'package:trixo_frontend/features/shop/domain/dto/payment_dto.dart';
import 'package:trixo_frontend/features/shop/domain/entity/customer.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

class ShopRepositoryImpl extends ShopRepository {
  final ShopDatasource datasource;

  ShopRepositoryImpl(this.datasource);

  @override
  Future<List<Product>> getActiveProducts() {
    return datasource.getActiveProducts();
  }

  @override
  Future<List<Review>> getReviews(int productId) {
    return datasource.getReviews(productId);
  }

  @override
  Future<void> sendReview(int productId, Review review) {
    return datasource.sendReview(productId, review);
  }

  @override
  Future<Customer> getCustomer(String email) {
    return datasource.getCustomer(email);
  }

  @override
  Future<void> insertCardToCustomer(PaymentDto paymentDto, String paymentMethodId) {
    return datasource.insertCardToCustomer(paymentDto, paymentMethodId);
  }

  @override
  Future<Customer> insertCustomer(Customer customer) {
    return datasource.insertCustomer(customer);
  }

  @override
  Future<bool> hasSavedPaymentMethod(String customerId) {
    return datasource.hasSavedPaymentMethod(customerId);
  }

  @override
  Future<void> updateCustomer(Customer customer) {
    return datasource.updateCustomer(customer);
  }

  @override
  Future<void> reduceStock(Map<int, int> productos) {
    return datasource.reduceStock(productos);
  }
}
