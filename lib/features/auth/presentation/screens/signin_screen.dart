import 'dart:async';
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

    Future<void> submit() async {
      final created = await notifier.onFormSubmit();
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
      // Se envió el email de verificación: abrimos el diálogo
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _EmailVerificationDialog(),
        );
      }
    }

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
  const _EmailVerificationDialog();

  @override
  State<_EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog> {
  bool _checking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Cada 3 segundos recargamos al usuario
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _reloadUser());
  }

  Future<void> _reloadUser() async {
    setState(() => _checking = true);
    final verified = await AuthService().isEmailVerified();
    setState(() => _checking = false);

    if (verified) {
      _timer?.cancel();
      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo
        context.go('/home');
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
          child: const Text('Cancelar'),
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
