import 'package:dio/dio.dart';

import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/infrastructure/shop_infrastructure.dart';

class ShopDatasourceImpl extends ShopDatasource {
  late final Dio dio;
  final Future<String?> Function() getAccessToken;

  ShopDatasourceImpl({required this.getAccessToken})
      : dio = Dio(BaseOptions(baseUrl: Environment.apiUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    try {
      final response = await dio.get('/products/active');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductMapper.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener productos activos: $e');
    }
  }

  @override
  Future<List<Review>> getReviews(int productId) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/products/$productId/ratings',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> body = response.data!;
        return body
            .map((json) => ReviewMapper.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Error al obtener valoraciones (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Fallo al cargar valoraciones: $e');
    }
  }
  
  @override
  Future<void> sendReview(int productId, Review review) async {
        try {
      final response = await dio.post<String>(
        '/products/$productId/ratings',
        data: ReviewMapper.toJson(review),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
            'Error al enviar valoración (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Fallo al enviar valoración: $e');
    }
  }
  
}
