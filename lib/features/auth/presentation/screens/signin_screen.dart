import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpForm = ref.watch(signUpFormProvider);
    final notifier = ref.read(signUpFormProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackArrow(route: '/login'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Icon(Icons.account_circle_rounded, size: 100),
                const SizedBox(height: 50),
                Text('¡Crea tu cuenta en Trixo! 🎉',
                    style: textTheme.titleMedium),
                const SizedBox(height: 50),
                CustomTextFormField(
                  label: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: notifier.onEmailChanged,
                  errorMessage: signUpForm.isFormPosted
                      ? signUpForm.email.errorMessage
                      : null,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Nombre de usuario',
                  onChanged: notifier.onUsernameChanged,
                  errorMessage: signUpForm.isFormPosted
                      ? signUpForm.username.errorMessage
                      : null,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Contraseña',
                  obscureText: true,
                  showPasswordToggle: true,
                  onChanged: notifier.onPasswordChanged,
                  errorMessage: signUpForm.isFormPosted
                      ? signUpForm.password.errorMessage
                      : null,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Repetir contraseña',
                  obscureText: true,
                  showPasswordToggle: true,
                  onChanged: notifier.onConfirmPasswordChanged,
                  errorMessage: signUpForm.isFormPosted
                      ? signUpForm.confirmPassword.errorMessage
                      : null,
                ),
                const SizedBox(height: 30),
                MUILoadingButton(
                  text: 'Registrarme',
                  loadingStateText: 'Registrando...',
                  onPressed: signUpForm.isSubmitting
                      ? null
                      : () async {
                          await _submit(context, ref);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _submit(BuildContext context, WidgetRef ref) async {
  final verified = await ref.read(signUpFormProvider.notifier).onFormSubmit();

  if (!verified && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Hubo un error al registrarte. Verifica los datos ingresados o confirma tu correo con el email enviado.',
        ),
      ),
    );
    return;
  }

  if (context.mounted) {
    context.go('/login');
  }
}
