import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:trixo_frontend/features/shared/widgets/auth_animation_widget.dart';

import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/config/config.dart';

class SignInScreen extends ConsumerStatefulWidget {
  SignInScreen({super.key});

  final GlobalKey<AuthAnimationWidgetState> animationKey = GlobalKey();

  void switchAnimations(bool isFocus, String animation) {
    final animState = animationKey.currentState;
    if (animState == null) return;

    if (animation == "password") {
      animState.playHat();
    } else {
      animState.removeHat();
    }
  }

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late TextEditingController usernameController;

  @override
  void initState() {
    super.initState();
    final username = ref.read(signUpFormProvider).username.value;
    usernameController = TextEditingController(text: username);
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final created = await ref.read(signUpFormProvider.notifier).onFormSubmit();
    if (!created && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al registrarte. Verifica los datos ingresados.',
          ),
        ),
      );

      return;
    }

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _EmailVerificationDialog(ref: ref),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpForm = ref.watch(signUpFormProvider);
    final notifier = ref.read(signUpFormProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(leading: const CustomBackArrow(route: '/login')),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                    AuthAnimationWidget(key: widget.animationKey),
                    const SizedBox(height: 25),
                Text('¡Crea tu cuenta en Trixo! 🎉',
                    style: textTheme.titleMedium),
                const SizedBox(height: 50),
                CustomTextFormField(
                  label: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: notifier.onEmailChanged,
                  onTap: () => widget.switchAnimations(true, "email"),
                  errorMessage: signUpForm.isFormPosted
                      ? signUpForm.email.errorMessage
                      : null,
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Nombre de usuario',
                  controller: usernameController,
                  onChanged: notifier.onUsernameChanged,
                  onTap: () => widget.switchAnimations(true, "username"),
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
                  onTap: () => widget.switchAnimations(true, "password"),
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
                  onTap: () => widget.switchAnimations(true, "password"),
                  errorMessage: signUpForm.isFormPosted
                      ? signUpForm.confirmPassword.errorMessage
                      : null,
                ),
                const SizedBox(height: 30),
                MUILoadingButton(
                  text: 'Registrarme',
                  loadingStateText: 'Registrando...',
                  onPressed: signUpForm.isSubmitting ? null : submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailVerificationDialog extends StatefulWidget {
  final WidgetRef ref;

  const _EmailVerificationDialog({required this.ref});

  @override
  State<_EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog> {
  Timer? _timer;
  bool _hasRegisteredInDB = false;

  @override
  void initState() {
    super.initState();
    // Cada 3 segundos recargamos al usuario
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _reloadUser());
  }

  Future<void> _reloadUser() async {
    final verified = await AuthService().isEmailVerified();

    if (verified && !_hasRegisteredInDB) {
      _timer?.cancel();
      _hasRegisteredInDB = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await widget.ref.read(authRepositoryProvider).registerUser(
              id: user.uid,
              username: widget.ref.read(signUpFormProvider).username.value,
              email: user.email!,
              avatar_img: user.photoURL ?? '',
              registration_date: DateTime.now(),
            );
      }

      final hasPreferences =
          await widget.ref.read(hasPreferencesProvider.future);
      if (mounted) {
        if (hasPreferences) {
          context.go('/home'); // Si tiene preferencias, ir al home
        } else {
          context
              .go('/onboarding'); // Si no tiene preferencias, ir al onboarding
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verifica tu correo'),
      content: const Text(
        'Te hemos enviado un correo con un enlace de verificación.\n'
        'Entra al enlace en tu email y para verificarte".',
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();

            Navigator.of(context).pop(); // Cierra y regresa al registro
          },
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
        MUILoadingButton(
          text: 'He verificado',
          loadingStateText: 'Verificando...',
          onPressed: () async {
            await _reloadUser();
            if (!mounted) return;
            if (!(await AuthService().isEmailVerified())) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correo aún no verificado.'),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
