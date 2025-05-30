import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/shared/infrastructure/inputs/inputs.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

import '../../../post/presentation/providers/post_providers.dart';

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
