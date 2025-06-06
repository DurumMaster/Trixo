import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/shared/infrastructure/inputs/inputs.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import '../../../post/presentation/providers/post_providers.dart';

//* EDITAR PERFIL
class EditProfileBottomSheet extends ConsumerStatefulWidget {
  final User user;
  const EditProfileBottomSheet({super.key, required this.user});

  @override
  ConsumerState<EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState
    extends ConsumerState<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  // Usamos Formz Username para validar
  Username _usernameInput = const Username.pure();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _newImagePath = widget.user.avatarImg;
    // Inicializamos el Formz input
    _usernameInput = Username.dirty(widget.user.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (picked != null) {
      setState(() {
        _newImagePath = picked.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    // Validamos Formz
    _usernameInput = Username.dirty(_usernameController.text.trim());
    if (!_usernameInput.isValid) {
      setState(() {}); // para mostrar error
      return;
    }

    final uid = fa.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final repo = ref.read(profileRepositoryProvider);

    String? finalAvatarUrl;

    // Si la imagen ha cambiado y es local, la subimos
    if (_newImagePath != null &&
        _newImagePath!.isNotEmpty &&
        !_newImagePath!.startsWith('http')) {
      finalAvatarUrl = await repo.uploadAvatar(uid, _newImagePath!);
    }

    // Si no se ha cambiado (sigue siendo una URL), mantenemos la anterior
    if (_newImagePath == widget.user.avatarImg ||
        (_newImagePath?.startsWith('http') ?? false)) {
      finalAvatarUrl = widget.user.avatarImg;
    }

    final updated = UserUpdate(
      username: _usernameController.text.trim() != widget.user.username
          ? _usernameController.text.trim()
          : null,
      bio: _bioController.text.trim() != widget.user.bio
          ? _bioController.text.trim()
          : null,
      avatarImg:
          finalAvatarUrl != widget.user.avatarImg ? finalAvatarUrl : null,
    );

    final success = await repo.updateUser(uid, updated);
    if (!mounted) return;

    Navigator.of(context).pop(success);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Perfil actualizado' : 'Error al actualizar perfil',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.4,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            controller: scroll,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _newImagePath != null && _newImagePath!.isNotEmpty
                                ? (_newImagePath!.startsWith('http')
                                    ? NetworkImage(_newImagePath!)
                                    : FileImage(File(_newImagePath!))
                                        as ImageProvider)
                                : null,
                        child: (_newImagePath == null || _newImagePath!.isEmpty)
                            ? const Icon(Icons.person,
                                size: 48, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username usando Formz validator
                      CustomTextFormField(
                        label: 'Nombre de usuario',
                        controller: _usernameController,
                        errorMessage:
                            _usernameInput.displayError == UsernameError.empty
                                ? _usernameInput.errorMessage
                                : null,
                        onChanged: (val) {
                          setState(() {
                            _usernameInput = Username.dirty(val.trim());
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Bio con fondo contrastado
                      CustomTextFormField(
                        label: 'Biografía',
                        controller: _bioController,
                        hint: 'Cuéntanos sobre ti...',
                        validator: null,
                      ),
                      const SizedBox(height: 24),
                      MUILoadingButton(
                        text: 'Guardar cambios',
                        loadingStateText: 'Guardando...',
                        onPressed: _saveChanges,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//* FAQ
class FAQBottomSheet extends StatelessWidget {
  final bool isDarkMode;

  const FAQBottomSheet({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final faqs = [
      {
        'question': '¿Cómo funciona Trixo?',
        'answer':
            'Trixo es una app donde puedes subir tus diseños, votar los de otros y comprar los más votados como drops exclusivos.'
      },
      {
        'question': '¿Quién puede subir diseños?',
        'answer':
            'Cualquier usuario puede subir diseños, sin importar su experiencia.'
      },
      {
        'question': '¿Qué es un drop?',
        'answer':
            'Un drop es una colección limitada de prendas seleccionadas por votación popular. Una vez agotado, no se repite.'
      },
      {
        'question': '¿Cómo me notifican si mi diseño ha sido seleccionado?',
        'answer':
            'Recibirás un correo si tu diseño ha sido elegido para un drop.'
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return _FAQCard(
                question: faq['question']!,
                answer: faq['answer']!,
                textColor: textColor,
                isDarkMode: isDarkMode,
              );
            },
          ),
        );
      },
    );
  }
}

class _FAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final Color textColor;
  final bool isDarkMode;

  const _FAQCard({
    required this.question,
    required this.answer,
    required this.textColor,
    required this.isDarkMode,
  });

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[100];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!_isExpanded)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: widget.textColor,
        ),
        onExpansionChanged: (value) {
          setState(() => _isExpanded = value);
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              widget.answer,
              style: TextStyle(color: widget.textColor),
            ),
          ),
        ],
      ),
    );
  }
}

//* UPDATE PREFERENCES

extension ColorUtils on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}

class UpdatePreferencesView extends ConsumerStatefulWidget {
  const UpdatePreferencesView({super.key});

  @override
  ConsumerState<UpdatePreferencesView> createState() =>
      _UpdatePreferencesViewState();
}

class _UpdatePreferencesViewState extends ConsumerState<UpdatePreferencesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPreferences();
    });
  }

  Future<void> _loadUserPreferences() async {
    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    try {
      final userPrefs = await repo.getUserPreferences(userId: user.uid);

      final notifier = ref.read(preferencesProvider.notifier);
      notifier.clearAll();

      final allValidKeys = AppConstants().allPreferences.keys.toSet();
      for (final rawTag in userPrefs) {
        final matchKey = allValidKeys.firstWhere(
          (fullKey) {
            final parts = fullKey.split(' ');
            final textWithoutEmoji = parts.sublist(1).join(' ');
            return textWithoutEmoji == rawTag;
          },
          orElse: () => '',
        );

        if (matchKey.isNotEmpty) {
          notifier.togglePreference(matchKey);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error cargando preferencias'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesMap = AppConstants().allPreferences;
    final allKeys = preferencesMap.keys.toList();
    final provider = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final user = fa.FirebaseAuth.instance.currentUser;

    // Lista de preferencias seleccionadas y no seleccionadas
    final selectedKeys = provider.selected;
    final unselectedKeys =
        allKeys.where((key) => !selectedKeys.contains(key)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: Text(
          'Actualizar preferencias',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Título y contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tus preferencias',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedKeys.length} / ${PreferencesProvider.maxSelections} seleccionadas',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),

            // Sección de preferencias seleccionadas (Scroll horizontal)
            if (selectedKeys.isNotEmpty) ...[
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedKeys.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final key = selectedKeys[index];
                    final color = preferencesMap[key]!;
                    return InputChip(
                      label: Text(
                        key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: color.withOpacity(0.8),
                      onDeleted: () {
                        notifier.togglePreference(key);
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Si no hay seleccionadas, invitar a elegir abajo
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'No tienes preferencias seleccionadas aún. Elige abajo.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: textColor.withOpacity(0.7),
                      ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Etiqueta "Otras categorías"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Otras categorías',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Grid de preferencias no seleccionadas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: unselectedKeys.length,
                  itemBuilder: (context, index) {
                    final key = unselectedKeys[index];
                    final color = preferencesMap[key]!;
                    // Si el usuario intenta seleccionar más de 10, mostramos un SnackBar
                    final isAtMax = provider.hasReachedMax;
                    return GestureDetector(
                      onTap: () {
                        if (!isAtMax) {
                          notifier.togglePreference(key);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        height: 56.0 * [1, 1.2, 1.5][index % 3],
                        decoration: BoxDecoration(
                          color: color.withOpacity(
                              provider.isSelected(key) ? 0.9 : 0.3),
                          borderRadius: BorderRadius.circular(18),
                          border: provider.isSelected(key)
                              ? Border.all(
                                  color: color.darken(0.3),
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
                                  color: provider.isSelected(key)
                                      ? Colors.white
                                      : textColor,
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Botón de “Actualizar preferencias”
            Padding(
              padding: const EdgeInsets.all(24),
              child: MUILoadingButton(
                text: 'Actualizar preferencias',
                loadingStateText: 'Actualizando...',
                onPressed: provider.selected.isNotEmpty
                    ? () async {
                        final repo = ref.read(preferencesRepositoryProvider);
                        // Sanitizamos como en el onboarding (si fuera necesario)
                        final sanitized = provider.selected.map((tag) {
                          return tag.contains(' ')
                              ? tag.split(' ').sublist(1).join(' ')
                              : tag;
                        }).toList();

                        final response = await repo.updateUserPreferences(
                          preferences: sanitized,
                          userId: user!.uid,
                        );

                        if (context.mounted) {
                          if (response) {
                            context.pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error al actualizar preferencias',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    : () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '¡Debes tener al menos una preferencia seleccionada!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                leadingIcon: Icons.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
