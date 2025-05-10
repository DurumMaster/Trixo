import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/infrastructure/auth_infrastructure.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final preferencesRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return AuthRepositoryImpl(
    AuthDatasourceImpl(
      getAccessToken: () async {
        final user = auth.currentUser;
        if (user == null) throw Exception('Usuario no autenticado');
        return await user.getIdToken();
      },
    ),
  );
});
