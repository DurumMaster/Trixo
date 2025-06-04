import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';

// Estado que mantiene la lista de reseñas y loading
class ReviewState {
  final List<Review> reviews;
  final bool isLoading;

  ReviewState({
    this.reviews = const [],
    this.isLoading = false,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    bool? isLoading,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Provider parametrizado por productId (o prendaId)
final reviewProvider =
    StateNotifierProvider.family<ReviewNotifier, ReviewState, int>(
  (ref, productId) {
    final repo = ref.watch(shopRepositoryProvider);
    return ReviewNotifier(productId, repo);
  },
);

// Notifier que carga y envía reseñas
class ReviewNotifier extends StateNotifier<ReviewState> {
  final int productId;
  final ShopRepository repository;

  ReviewNotifier(this.productId, this.repository) : super(ReviewState());

  Future<void> loadReviews() async {
    try {
      state = state.copyWith(isLoading: true);
      final reviews = await repository.getReviews(productId);
      state = state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Podrías capturar/loggear el error aquí
    }
  }

  Future<void> sendReview(int productId, Review review) async {
    try {
      await repository.sendReview(productId, review);
      // Agrega la nueva reseña al inicio de la lista
      state = state.copyWith(
        reviews: [review, ...state.reviews],
      );
    } catch (e) {
      // Manejo de errores opcional
    }
  }
}

// Provider para cachear usuarios y no pedirlos repetidos
final _userCacheProvider = Provider<Map<String, User>>((ref) => {});

final cachedUserProvider = FutureProvider.family<User, String>(
  (ref, userId) async {
    final cache = ref.read(_userCacheProvider);
    if (cache.containsKey(userId)) return cache[userId]!;

    final user =
        await ref.read(authRepositoryProvider).getUserById(userId: userId);
    cache[userId] = user;
    return user;
  },
);
