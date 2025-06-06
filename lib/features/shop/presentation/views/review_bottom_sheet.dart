import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/shop/domain/shop_domain.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart'
    as post;

class ReviewBottomSheet extends ConsumerStatefulWidget {
  final int productId;
  final String userId;

  const ReviewBottomSheet({
    super.key,
    required this.productId,
    required this.userId,
  });

  @override
  ConsumerState<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<ReviewBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  double _selectedRating = 5.0; // por defecto 5 estrellas

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider(widget.productId).notifier).loadReviews();
    });
  }

  void _submitReview() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newReview = Review(
      id: 0,
      userID: widget.userId,
      message: text,
      rating: _selectedRating,
      fechaCreacion: DateTime.now(),
    );

    ref
        .read(reviewProvider(widget.productId).notifier)
        .sendReview(widget.productId, newReview);
    _controller.clear();
    setState(() => _selectedRating = 5.0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider(widget.productId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(102),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                  : state.reviews.isEmpty
                      ? Center(
                          child: Text(
                            'Sé el primero en dar una valoración',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.reviews.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) {
                            final review = state.reviews[i];
                            final userAsync = ref
                                .watch(post.cachedUserProvider(review.userID));

                            return userAsync.when(
                              data: (user) =>
                                  ReviewItem(review: review, user: user),
                              loading: () => null,
                              error: (error, _) =>
                                  _ErrorReviewItem(error: error),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // ---------------------------------------------------
            // Zona para escribir nueva reseña + selector de estrellas
            // ---------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de estrellas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedRating = starIndex.toDouble();
                          });
                        },
                        iconSize: 28,
                        icon: Icon(
                          _selectedRating >= starIndex
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            hintText: 'Escribe tu opinión...',
                            hintStyle: TextStyle(color: theme.hintColor),
                            filled: true,
                            fillColor: Colors.grey.withAlpha(26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, size: 24),
                        onPressed: _submitReview,
                        color: isDark ? Colors.white : Colors.black,
                        tooltip: 'Enviar reseña',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Estado de error de un ReviewItem
class _ErrorReviewItem extends StatelessWidget {
  final dynamic error;

  const _ErrorReviewItem({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Error: ${error.toString()}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review review;
  final User user;

  const ReviewItem({
    super.key,
    required this.review,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar del usuario
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.avatarImg),
          backgroundColor: isDark ? Colors.black : Colors.white,
        ),
        const SizedBox(width: 12),
        // Contenido de la reseña
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre y fecha
              Row(
                children: [
                  Text(
                    user.username,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    HumanFormats.timeAgo(review.fechaCreacion),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Fila de estrellas (valoración)
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return Icon(
                    review.rating >= starIndex ? Icons.star : Icons.star_border,
                    size: 18,
                    color: Colors.amber,
                  );
                }),
              ),
              const SizedBox(height: 6),
              // Mensaje de la reseña
              Text(
                review.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
