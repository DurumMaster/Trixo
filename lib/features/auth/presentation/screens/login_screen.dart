import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_button/sign_button.dart';
import 'package:go_router/go_router.dart';

import 'package:trixo_frontend/features/auth/presentation/providers/login_form_provider.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/shared/widgets/loading_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Icon(Icons.account_circle_rounded, size: 100),
                const SizedBox(height: 50),
                Text('¡Hola! Bienvenido a Trixo 👋',
                    style: textTheme.titleMedium),
                const SizedBox(height: 50),
                CustomTextFormField(
                  label: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: notifier.onEmailChanged,
                  errorMessage: loginForm.isFormPosted
                      ? loginForm.email.errorMessage
                      : null,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Contraseña',
                  showPasswordToggle: true,
                  obscureText: true,
                  onChanged: notifier.onPasswordChange,
                  onFieldSubmitted: (_) => _submit(context, ref),
                  errorMessage: loginForm.isFormPosted
                      ? loginForm.password.errorMessage
                      : null,
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        context.go('/reset_password');
                      }
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                MUILoadingButton(
                  text: 'Iniciar sesión',
                  loadingStateText: 'Iniciando sesión...',
                  onPressed: loginForm.isPosting
                      ? () async {}
                      : () async {
                          await _submit(context, ref);
                        },
                ),
                const SizedBox(height: 60),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SignInButton(
                        buttonType: ButtonType.google,
                        onPressed: loginForm.isPosting
                            ? () {}
                            : () => _googleSignIn(context, ref),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        text: 'Regístrate',
                        onPressed: () {
                          if (context.mounted) {
                            context.go('/signin');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final verified = await ref.read(loginFormProvider.notifier).onFormSubmit();

    if (!verified && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Credenciales inválidas o correo no verificado. Revisa tu email.',
          ),
        ),
      );
      return;
    }

    if (context.mounted) {
      context.go('/home');
    }
  }

  Future<void> _googleSignIn(BuildContext context, WidgetRef ref) async {
    final verified =
        await ref.read(loginFormProvider.notifier).signInWithGoogle();

    if (!verified && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error con Google o correo no verificado. Revisa tu email.',
          ),
        ),
      );
      return;
    }

    if (context.mounted) {
      context.go('/home');
    }
  }
}
