import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:trixo_frontend/features/shared/infrastructure/inputs/inputs.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

final signUpFormProvider =
    StateNotifierProvider.autoDispose<SignUpFormNotifier, SignUpFormState>(
        (ref) {
  final authService = ref.watch(loginAuthServiceProvider);
  return SignUpFormNotifier(authService: authService);
});

class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  final AuthService authService;

  SignUpFormNotifier({required this.authService})
      : super(const SignUpFormState());

  void onEmailChanged(String email) {
    final emailValidation = Email.dirty(email);
    state = state.copyWith(email: emailValidation);
  }

  void onUsernameChanged(String username) {
    final usernameValidation = Username.dirty(username);
    state = state.copyWith(username: usernameValidation);
  }

  void onPasswordChanged(String password) {
    final passwordValidation = Password.dirty(password);
    state = state.copyWith(password: passwordValidation);
  }

  void onConfirmPasswordChanged(String confirmPassword) {
    final confirmPasswordValidation = ConfirmPassword.dirty(
      value: confirmPassword,
      password: state.password.value,
    );
    state = state.copyWith(confirmPassword: confirmPasswordValidation);
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return false;

    state = state.copyWith(isSubmitting: true);

    final signinSuccess = await authService.signUp(
      email: state.email.value,
      password: state.password.value,
    );

    state = state.copyWith(isSubmitting: false);
    // if (!signinSuccess) {
    //   return false;
    // }

    // final verified = await authService.isEmailVerified();
    // state = state.copyWith(isSubmitting: false);

    return signinSuccess;
  }

  _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final username = Username.dirty(state.username.value);
    final password = Password.dirty(state.password.value);
    final confirmPassword = ConfirmPassword.dirty(
      value: state.confirmPassword.value,
      password: state.password.value,
    );

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      isValid: Formz.validate([email, username, password, confirmPassword]),
    );
  }
}

class SignUpFormState {
  final Email email;
  final Username username;
  final Password password;
  final ConfirmPassword confirmPassword;
  final bool isValid;
  final bool isSubmitting;
  final bool isFormPosted;

  const SignUpFormState({
    this.email = const Email.pure(),
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.isValid = false,
    this.isSubmitting = false,
    this.isFormPosted = false,
  });

  SignUpFormState copyWith({
    Email? email,
    Username? username,
    Password? password,
    ConfirmPassword? confirmPassword,
    bool? isValid,
    bool? isSubmitting,
    bool? isFormPosted,
  }) {
    return SignUpFormState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
    );
  }
}
