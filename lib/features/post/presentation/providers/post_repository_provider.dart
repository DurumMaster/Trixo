import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/infrastructure/post_infrastructure.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  
  return PostRepositoryImpl(
    PostDatasourceImpl(
      getAccessToken: () async {
        final user = auth.currentUser;
        if (user == null) throw Exception('Usuario no autenticado');
        return await user.getIdToken();
      }
    )
  );
});
