import 'package:trixo_frontend/features/shop/domain/dto/payment_dto.dart';
import 'package:trixo_frontend/features/shop/domain/entity/customer.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

abstract class ShopDatasource {
  Future<List<Product>> getActiveProducts();
  Future<List<Review>> getReviews(int productId);
  Future<void> sendReview(int productId, Review review);
  Future<Customer> getCustomer(String email);
  Future<void> insertCardToCustomer(PaymentDto paymentDto, String paymentMethodId);
  Future<Customer> insertCustomer(Customer customer);
  Future<bool> hasSavedPaymentMethod(String customerId);
  Future<void> updateCustomer(Customer customer);
  Future<void> reduceStock(Map<int, int> productos);
}
