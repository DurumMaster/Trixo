import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

extension ColorUtils on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}

class OnboardingPreferencesView extends ConsumerStatefulWidget {
  const OnboardingPreferencesView({super.key});

  @override
  ConsumerState<OnboardingPreferencesView> createState() =>
      _OnboardingPreferencesViewState();
}

class _OnboardingPreferencesViewState
    extends ConsumerState<OnboardingPreferencesView> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final user = FirebaseAuth.instance.currentUser;
    final preferences = AppConstants().allPreferences.entries.toList();

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
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona tus preferencias de moda y estilo para que podamos ofrecerte una experiencia personalizada.',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preferencias seleccionadas: ${provider.selected.length} / ${PreferencesProvider.maxSelections}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SurpriseButton(
                      onSurprise: () => notifier.selectRandom(
                        preferences.map((e) => e.key).toList(),
                        count: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: preferences.length,
                  itemBuilder: (context, index) {
                    final entry = preferences[index];
                    final key = entry.key;
                    final isSelected = provider.isSelected(key);
                    final randomHeight = [1, 1.2, 1.5][index % 3];

                    return GestureDetector(
                      onTap: () => notifier.togglePreference(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        height: 56.0 * randomHeight,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? entry.value.withOpacity(0.9)
                              : entry.value.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected
                              ? Border.all(
                                  color: entry.value.darken(0.3),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            key,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : textColor,
                                ),
                          ),
                        ),
                      ),
                    );
                  },
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
                        final sanitized = provider.selected
                            .map((tag) => tag.contains(' ')
                                ? tag.split(' ').sublist(1).join(' ')
                                : tag)
                            .toList();
                        await repo.saveUserPreferences(
                          preferences: sanitized,
                          userId: user!.uid,
                        );
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
                          ),
                        );
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

class SurpriseButton extends StatefulWidget {
  final VoidCallback onSurprise;

  const SurpriseButton({super.key, required this.onSurprise});

  @override
  State<SurpriseButton> createState() => _SurpriseButtonState();
}

class _SurpriseButtonState extends State<SurpriseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _animateAndSurprise() {
    _controller.forward(from: 0);
    widget.onSurprise();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _animateAndSurprise,
      icon: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
        ),
        child: const Icon(Icons.casino_rounded),
      ),
      label: const Text('Sorpréndeme'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
