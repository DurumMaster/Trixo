import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerProvider = StateNotifierProvider<ImagePickerNotifier, ImagePickerState>((ref) {
  return ImagePickerNotifier();
});

class ImagePickerNotifier extends StateNotifier<ImagePickerState> {
  ImagePickerNotifier() : super(ImagePickerState());

  Future<void> pickImages() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final picker = ImagePicker();
      final result = await picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      final newPaths = result.map((xfile) => xfile.path).toList();
      state = state.copyWith(
        images: [...state.images, ...newPaths],
        isLoading: false,
      );
        } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void removeImage(String path) {
    state = state.copyWith(
      images: state.images.where((image) => image != path).toList()
    );
  }

  void clearSelection() {
    state = state.copyWith(images: []);
  }
}

class ImagePickerState {
  final List<String> images;
  final bool isLoading;

  ImagePickerState({
    this.images = const [],
    this.isLoading = false,
  });

  ImagePickerState copyWith({
    List<String>? images,
    bool? isLoading,
  }) {
    return ImagePickerState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasImages => images.isNotEmpty;

}
