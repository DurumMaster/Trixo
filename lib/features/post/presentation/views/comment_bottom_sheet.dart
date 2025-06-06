import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/post/domain/post_domain.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final String postId;
  final String userId;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.userId,
  });

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentProvider(widget.postId).notifier).loadComments();
    });
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      id: '',
      postId: widget.postId,
      userId: widget.userId,
      text: text,
      createdAt: DateTime.now(),
    );

    ref.read(commentProvider(widget.postId).notifier).sendComment(newComment);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentProvider(widget.postId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 420,
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
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : Colors.black)))
                  : state.comments.isEmpty
                      ? Center(
                          child: Text(
                            'Sé el primero en comentar',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) {
                            final comment = state.comments[i];
                            final userAsync =
                                ref.watch(cachedUserProvider(comment.userId));

                            return userAsync.when(
                              data: (user) =>
                                  _CommentItem(comment: comment, user: user),
                              loading: () => null,
                              error: (error, stack) =>
                                  _ErrorCommentItem(error: error),
                            );
                          }),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        hintText: 'Añadir comentario...',
                        hintStyle:
                            TextStyle(color: Theme.of(context).hintColor),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            150), // Limitar a 200 caracteres
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, size: 20),
                    onPressed: _submitComment,
                    color: isDark ? Colors.white : Colors.black,
                    tooltip: 'Enviar',
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

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final User user;

  const _CommentItem({required this.comment, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.avatarImg),
          backgroundColor: isDark ? Colors.black : Colors.white,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    HumanFormats.timeAgo(comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
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

class _ErrorCommentItem extends StatelessWidget {
  final dynamic error;

  const _ErrorCommentItem({required this.error});

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
