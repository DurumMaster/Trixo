import 'package:dio/dio.dart';

import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

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

}
