import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';
import 'package:trixo_frontend/features/post/presentation/providers/post_providers.dart';

class CreatePostView extends ConsumerWidget {
  final List<String> images;
  const CreatePostView({super.key, required this.images});

  static const int _maxChars = 200;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postSubmitProvider(images));
    final notifier = ref.read(postSubmitProvider(images).notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurf = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: onSurf),
        title: Text(
          'Publicar diseño',
          style: TextStyle(color: onSurf, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vista previa de la primera imagen
                      if (images.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(images.first),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Descripción minimalista
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          maxLines: null,
                          maxLength: _maxChars,
                          onChanged: notifier.setDescription,
                          style: TextStyle(color: onSurf),
                          cursorColor: onSurf,
                          decoration: InputDecoration(
                            hintText:
                                'Cuéntale al mundo qué hace especial tu diseño. Una buena descripción ayuda a que más personas conecten con tu estilo.',
                            hintStyle: TextStyle(
                              color: onSurf.withOpacity(0.6),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            counterText:
                                '${state.description.length}/$_maxChars',
                            counterStyle:
                                TextStyle(color: onSurf.withOpacity(0.6)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sección de Tags
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Utiliza etiquetas para que más personas vean tu diseño',
                                style: TextStyle(
                                    color: onSurf, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: TextButton.icon(
                                onPressed: () async {
                                  final result =
                                      await context.push<List<String>>(
                                    '/select-tags',
                                    extra: state.tags,
                                  );
                                  if (result != null) notifier.setTags(result);
                                },
                                icon: Icon(Icons.add, color: onSurf),
                                label: Text(
                                  'Etiquetas',
                                  style: TextStyle(color: onSurf),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // Mostrar tags seleccionados (scroll horizontal sobre dos filas)
                      if (state.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.tags.length,
                              itemBuilder: (_, i) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  state.tags[i],
                                  style: TextStyle(color: onSurf),
                                ),
                              ),
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Botón Share personalizado
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: MUILoadingButton(
                          text: 'Publicar',
                          loadingStateText: 'Publicando...',
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final ok = await notifier.submit();
                                  if (ok && context.mounted) {
                                    context.go('/home');
                                  }
                                },
                          borderRadius: 12,
                          boxShadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
