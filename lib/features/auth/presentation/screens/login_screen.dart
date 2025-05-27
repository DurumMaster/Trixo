import "dart:developer";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_button/sign_button.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_providers.dart';

import 'package:trixo_frontend/features/auth/presentation/providers/login_form_provider.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/onboarding_provider.dart';
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
        if (current == "SwitchDefault") {
          await animationKey.currentState
              ?.switchAnimation("SwitchDefault", 500);
        } else {
          if (current != "idle") {
            await animationKey.currentState?.switchAnimation("idle", 250);
          }
        }
      } else if (animation == "password") {
        if (current != "SwitchHat") {
          await animationKey.currentState?.switchAnimation("SwitchHat", 500);
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
    final loginStatus = ref.watch(authProvider);

    return loginStatus.when(
      data: (isLoggedIn) {
        if (isLoggedIn) {
          final hasPreferences = ref.watch(hasPreferencesProvider);

          return hasPreferences.when(
            data: (hasPrefs) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(hasPrefs ? '/home' : '/onboarding');
              });
              return const SizedBox.shrink();
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error al comprobar preferencias: $error'),
            ),
          );
        }

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
                    Text(
                      '¡Hola! Bienvenido a Trixo 👋',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 50),
                    CustomTextFormField(
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                      onChanged:
                          ref.read(loginFormProvider.notifier).onEmailChanged,
                      errorMessage: ref.watch(loginFormProvider).isFormPosted
                          ? ref.watch(loginFormProvider).email.errorMessage
                          : null,
                      onTap: () => switchAnimations(true, "email"),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      label: 'Contraseña',
                      showPasswordToggle: true,
                      obscureText: true,
                      onChanged:
                          ref.read(loginFormProvider.notifier).onPasswordChange,
                      onFieldSubmitted: (_) => _submit(context, ref),
                      errorMessage: ref.watch(loginFormProvider).isFormPosted
                          ? ref.watch(loginFormProvider).password.errorMessage
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      onPressed: ref.watch(loginFormProvider).isPosting
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
                            onPressed: ref.watch(loginFormProvider).isPosting
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final verified = await ref.read(loginFormProvider.notifier).onFormSubmit();

    if (!verified) {
      if (context.mounted) {
        switchAnimations(false, "fail");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Credenciales inválidas o correo no verificado. Revisa tu email.',
            ),
          ),
        );
      }
      return;
    }

    final hasPreferences = await ref.read(hasPreferencesProvider.future);
    if (context.mounted) {
      if (hasPreferences) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  Future<void> _googleSignIn(BuildContext context, WidgetRef ref) async {
    final verified =
        await ref.read(loginFormProvider.notifier).signInWithGoogle();
    AuthRepository authRepository = ref.watch(authRepositoryProvider);
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;

    if(user != null){
      final userDB = await authRepository.getUserById(userId: user.uid);
      if(userDB.id.isEmpty && userDB.email.isEmpty){
        await ref.watch(authRepositoryProvider).registerUser(
          id: user.uid, 
          username: user.displayName ?? '', 
          email: user.email!, 
          avatar_img: user.photoURL ?? '', 
          registration_date: DateTime.now(),
        );
      }
    }

    if (!verified) {
      if (context.mounted) {
        switchAnimations(false, "fail");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error con Google o correo no verificado. Revisa tu email.',
            ),
          ),
        );
      }
      return;
    }

    final hasPreferences = await ref.read(hasPreferencesProvider.future);
    if (context.mounted) {
      if (hasPreferences) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }
}
