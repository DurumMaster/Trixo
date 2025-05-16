import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/post/presentation/providers/image_picker_provider.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

class ImagePickerView extends ConsumerStatefulWidget {
  const ImagePickerView({super.key});

  @override
  ConsumerState<ImagePickerView> createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends ConsumerState<ImagePickerView> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _openedGallery = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_openedGallery) {
        ref.read(imagePickerProvider.notifier).pickImages();
        _openedGallery = true;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imagePickerProvider);
    final notifier = ref.read(imagePickerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: iconColor),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('¿Estás seguro?'),
                content: const Text('Se perderán las imágenes seleccionadas.'),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: iconColor,
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: iconColor,
                    ),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Salir'),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              notifier.clearSelection();
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Seleccionar imágenes',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: iconColor),
        ),
        actions: state.hasImages
            ? [
                IconButton(
                  icon: Icon(Icons.add_photo_alternate, color: iconColor),
                  onPressed: notifier.pickImages,
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    final clear = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Borrar todas las imágenes'),
                        content: const Text(
                            '¿Estás seguro que quieres borrar todas las imágenes seleccionadas?'),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: iconColor,
                            ),
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: iconColor,
                            ),
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Borrar'),
                          ),
                        ],
                      ),
                    );
                    if (clear == true) {
                      notifier.clearSelection();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.hasImages
                ? _buildCarousel(context, state, notifier, isDark, iconColor)
                : _buildPlaceholder(context, notifier, iconColor),
      ),
      bottomNavigationBar: state.hasImages
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: MUILoadingButton(
                text: 'Continuar',
                onPressed: state.hasImages
                    ? () => context.push('/create-post', extra: state.images)
                    : null,
                borderRadius: 12,
                leadingIcon: Icons.arrow_right_alt_rounded,
                boxShadows: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildPlaceholder(
      BuildContext context, ImagePickerNotifier notifier, Color iconColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 60,
            icon: Icon(Icons.add_photo_alternate, color: iconColor),
            onPressed: notifier.pickImages,
          ),
          const SizedBox(height: 16),
          Text(
            'No has subido imágenes aún\nToca el botón para agregar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!,
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(
    BuildContext context,
    ImagePickerState state,
    ImagePickerNotifier notifier,
    bool isDark,
    Color iconColor,
  ) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final path = state.images[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.black.withOpacity(0.1),
                          child: Icon(Icons.broken_image,
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => notifier.removeImage(path),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 20, color: iconColor),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (state.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(state.images.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? iconColor : iconColor.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
