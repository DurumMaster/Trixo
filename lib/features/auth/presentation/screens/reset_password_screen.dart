import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetPasswordState = ref.watch(resetPasswordFormProvider);
    final resetPasswordNotifier = ref.watch(resetPasswordFormProvider.notifier);

    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackArrow(route: '/login'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Ingresa tu correo y te enviaremos un enlace para que puedas crear una nueva contraseña.\n¡Revisa tu bandeja de entrada!',
                      textAlign: TextAlign.start,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    // Campo para el correo
                    CustomTextFormField(
                      label: 'Introduce tu correo electrónico',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: resetPasswordNotifier.onEmailChanged,
                      errorMessage: resetPasswordState.isFormPosted
                          ? resetPasswordState.email.errorMessage
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Botón de envío
                    MUILoadingButton(
                      text: resetPasswordState.isPosting
                          ? 'Enviando...'
                          : 'Enviar correo',
                      loadingStateText: 'Enviando...',
                      onPressed: resetPasswordState.isPosting
                          ? null
                          : () async {
                              final success =
                                  await resetPasswordNotifier.onFormSubmit();

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Se ha enviado un correo de recuperación de contraseña'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Hubo un error al enviar el correo. Inténtalo de nuevo.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
