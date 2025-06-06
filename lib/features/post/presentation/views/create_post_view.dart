import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:trixo_frontend/config/config.dart';
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
      resizeToAvoidBottomInset: true,
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
                          height: 300,
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
                          color: onSurf.withAlpha(153),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        counterText: '${state.description.length}/$_maxChars',
                        counterStyle: TextStyle(color: onSurf.withAlpha(153)),
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
                            color: Colors.grey.withAlpha(38)
,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: TextButton.icon(
                            onPressed: () async {
                              final result = await context.push<List<String>>(
                                '/select-tags',
                                extra: {
                                  'initialTags': state.tags,
                                },
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
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mostrar tags seleccionados (scroll horizontal sobre dos filas)
                  if (state.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.tags.length,
                          itemBuilder: (_, i) {
                            return CustomTagButton(
                              text: state.tags[i],
                              color: AppConstants()
                                      .allPreferences[state.tags[i]] ??
                                  Colors.grey,
                              selected: true,
                              onTap: () {
                                null;
                              },
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(
                    height: 100,
                  ),

                  // Botón Share personalizado
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: MUILoadingButton(
                      text: 'Publicar',
                      loadingStateText: 'Publicando...',
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              final ok = await notifier.submit();
                              if (ok && context.mounted) {
                                ref
                                    .read(imagePickerProvider.notifier)
                                    .clearSelection();
                                context.go('/home');
                              }
                            },
                      borderRadius: 12,
                      boxShadows: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
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
    );
  }
}

//* PANTALLA SELECCIÓN DE TAGS

class CreatePostSelectTagsView extends ConsumerStatefulWidget {
  final Map<String, Color> availableTags;
  final List<String> initialTags;

  const CreatePostSelectTagsView({
    super.key,
    required this.availableTags,
    this.initialTags = const [],
  });

  @override
  ConsumerState<CreatePostSelectTagsView> createState() =>
      _CreatePostSelectTagsViewState();
}

class _CreatePostSelectTagsViewState
    extends ConsumerState<CreatePostSelectTagsView> {
  late Set<String> selectedTags;
  static const int maxTags = 10;

  @override
  void initState() {
    super.initState();
    selectedTags = widget.initialTags.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.availableTags;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurfaceColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurfaceColor),
          onPressed: () {
            Navigator.of(context).pop(selectedTags.toList());
          },
        ),
        title: Text(
          'Selecciona etiquetas',
          style: TextStyle(color: onSurfaceColor),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${selectedTags.length} / $maxTags',
                style: TextStyle(
                  color: onSurfaceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AlignedGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final entry = tags.entries.elementAt(index);
            final tag = entry.key;
            final color = entry.value;
            final isSelected = selectedTags.contains(tag);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTags.remove(tag);
                  } else {
                    // Solo añadir si no se ha llegado al límite
                    if (selectedTags.length < maxTags) {
                      selectedTags.add(tag);
                    }
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(204)
                      : color.withAlpha(102),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: color.withAlpha(230)
, width: 2)
                      : null,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
