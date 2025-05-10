import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trixo_frontend/config/theme/app_colors.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

class OnboardingPreferencesView extends ConsumerWidget {
  const OnboardingPreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(preferencesProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Solo un paso más!',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona tus preferencias de moda y estilo para que podamos ofrecerte una experiencia personalizada.',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: provider.allPreferences.entries.map((entry) {
                    return CustomTagButton(
                      text: entry.key,
                      color: entry.value,
                      selected: provider.isSelected(entry.key),
                      onTap: () => provider.togglePreference(entry.key),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: MUILoadingButton(
                text: 'Guardar preferencias',
                loadingStateText: 'Guardando...',
                onPressed: provider.canSubmit
                    ? () async {
                        final repo = ref.read(preferencesRepositoryProvider);
                        await repo.saveUserPreferences(
                            preferences: provider.selectedPreferences.toList());
                        if (context.mounted) {
                          context.go('/home');
                        }
                      }
                    : () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '¡Debes seleccionar al menos una preferencia!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            backgroundColor:
                                null, // Deja el fondo según el tema actual
                          ),
                        );

                        return;
                      },
                leadingIcon: Icons.check,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
