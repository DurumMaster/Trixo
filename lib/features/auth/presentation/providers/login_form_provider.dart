import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/shared/infrastructure/inputs/inputs.dart';

final loginAuthServiceProvider = Provider<AuthService>((ref) => AuthService());

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  final authService = ref.watch(loginAuthServiceProvider);

  return LoginFormNotifier(authService: authService);
});

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final AuthService authService;

  LoginFormNotifier({required this.authService}) : super(LoginFormState());

  onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
        email: newEmail, isValid: Formz.validate([newEmail, state.password]));
  }

  onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate([state.email, newPassword]));
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);

    final loginSuccess = await authService.signIn(
      email: state.email.value,
      password: state.password.value,
    );

    if (!loginSuccess) {
      state = state.copyWith(isPosting: false);
      return false;
    }

    final verified = await authService.isEmailVerified();
    state = state.copyWith(isPosting: false);

    return verified;
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isPosting: true);

    final loginSuccess = await authService.signInWithGoogle();
    if (!loginSuccess) {
      state = state.copyWith(isPosting: false);
      return false;
    }

    final verified = await authService.isEmailVerified();
    state = state.copyWith(isPosting: false);

    return verified;
  }

  _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
        isFormPosted: true,
        email: email,
        password: password,
        isValid: Formz.validate([email, password]));
  }
}

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
    Password? password,
  }) =>
      LoginFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        email: email ?? this.email,
        password: password ?? this.password,
      );
}
