import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/shared/infrastructure/inputs/inputs.dart';

// Provider para el servicio de autenticación
final resetPasswdAuthServiceProvider =
    Provider<AuthService>((ref) => AuthService());

// Provider del formulario de restablecimiento de contraseña
final resetPasswordFormProvider = StateNotifierProvider.autoDispose<
    ResetPasswordFormNotifier, ResetPasswordFormState>((ref) {
  final authService = ref.watch(resetPasswdAuthServiceProvider);

  return ResetPasswordFormNotifier(authService: authService);
});

// Notificador que maneja el estado del formulario de restablecimiento
class ResetPasswordFormNotifier extends StateNotifier<ResetPasswordFormState> {
  final AuthService authService;

  ResetPasswordFormNotifier({required this.authService})
      : super(ResetPasswordFormState());

  // Lógica para cambiar el correo
  onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail]),
    );
  }

  // Lógica de envío del formulario
  Future<bool> onFormSubmit() async {
    // Marcar todos los campos como "tocados" para mostrar errores
    _touchEveryField();

    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);

    // Aquí iría la lógica de enviar el correo para el restablecimiento de la contraseña
    final resetSuccess =
        await authService.resetPassword(email: state.email.value);

    state = state.copyWith(isPosting: false);

    return resetSuccess;
  }

  // Marcar todos los campos como "tocados"
  _touchEveryField() {
    final email = Email.dirty(state.email.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      isValid: Formz.validate([email]),
    );
  }
}

// Estado del formulario de restablecimiento
class ResetPasswordFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;

  ResetPasswordFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
  });

  ResetPasswordFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
  }) =>
      ResetPasswordFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        email: email ?? this.email,
      );
}
