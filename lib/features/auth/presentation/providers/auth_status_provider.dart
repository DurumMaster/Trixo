import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  AuthNotifier() : super(const AuthState()) {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        state = state.copyWith(
          authStatus: AuthStatus.authenticated,
          userId: firebaseUser.uid,
        );
      } else {
        state = state.copyWith(
          authStatus: AuthStatus.notAuthenticated,
          userId: null,
        );
      }
    });
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final String? userId;

  const AuthState({
    this.authStatus = AuthStatus.checking,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    String? userId,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        userId: userId ?? this.userId,
      );
}
