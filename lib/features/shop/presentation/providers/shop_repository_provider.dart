import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:trixo_frontend/features/shop/infrastructure/shop_infrastructure.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return ShopRepositoryImpl(
    ShopDatasourceImpl(
      getAccessToken: () async {
        final user = auth.currentUser;
        if (user == null) throw Exception('Usuario no autenticado');
        return await user.getIdToken();
      },
    ),
  );
});
