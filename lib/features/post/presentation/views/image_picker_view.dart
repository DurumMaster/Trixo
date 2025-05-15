import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

class ImagePickerView extends ConsumerWidget {
  const ImagePickerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imagePickerProvider);
    final notifier = ref.read(imagePickerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar imágenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: notifier.clearSelection,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: state.images.length,
                    itemBuilder: (context, index) {
                      final path = state.images[index];
                      return _ImageThumbnail(
                        path: path,
                        onRemove: () => notifier.removeImage(path),
                      );
                    },
                  ),
          ),
          _ContinueButton(hasImages: state.hasImages),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: notifier.pickImages,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _ImageThumbnail({
    required this.path,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends ConsumerWidget {
  final bool hasImages;

  const _ContinueButton({required this.hasImages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasImages
              ? () => Navigator.pushNamed(context, '/create-post-details')
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor:
                hasImages ? Theme.of(context).primaryColor : Colors.grey[400],
          ),
          child: Text(
            'Continuar',
            style: TextStyle(
              fontSize: 16,
              color: hasImages ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
