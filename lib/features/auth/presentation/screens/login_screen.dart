import "dart:developer";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_button/sign_button.dart';
import 'package:go_router/go_router.dart';

import 'package:trixo_frontend/features/auth/presentation/providers/login_form_provider.dart';
import 'package:trixo_frontend/features/shared/widgets/auth_animation_widget.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final GlobalKey<AuthAnimationWidgetState> animationKey = GlobalKey();

  void switchAnimations(bool isFocus, String animation) async {
    final current = animationKey.currentState?.currentAnimation;
    log("Current animation: $current", name: "LoginScreen");
    if (isFocus) {
      if (animation == "email") {
        if (current == "Hands_up") {
          await animationKey.currentState?.switchAnimation("hands_down", 500);
        } else {
          if (current != "idle") {
            await animationKey.currentState?.switchAnimation("idle", 250);
          }
        }
      } else if (animation == "password") {
        if (current != "Hands_up") {
          await animationKey.currentState?.switchAnimation("Hands_up", 500);
        }
      }
    } else {
      if (animation == "fail") {
        if (current != "fail") {
          await animationKey.currentState?.switchAnimation("fail", 500);
        }
      } else if (animation == "success") {
        if (current != "success") {
          await animationKey.currentState?.switchAnimation("success", 500);
        }
      } else {
        if (current != "idle") {
          await animationKey.currentState?.switchAnimation("idle", 500);
        }
      }
    }
  }

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
                const SizedBox(height: 50),
                AuthAnimationWidget(key: animationKey),
                const SizedBox(height: 25),
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
                  onTap: () => switchAnimations(true, "email"),
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
                  onTap: () => switchAnimations(true, "password"),
                ),
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
                      ? null
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
                            ? null
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
                    const SizedBox(height: 25),
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
      switchAnimations(false, "fail");
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
      switchAnimations(false, "fail");
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
