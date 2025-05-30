import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/screens.dart';

import '../../../post/presentation/providers/post_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.of(context).platformBrightness;

    final isDarkMode = themeMode == ThemeMode.system
        ? platformBrightness == Brightness.dark
        : themeMode == ThemeMode.dark;

    final backgroundColor =
        isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final sectionTitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Ajustes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textColor,
          ),
        ),
        leading: BackButton(
          color: iconColor,
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle('General', color: sectionTitleColor),
          _buildThemeSliderSelector(context, ref),
          const SizedBox(height: 16),
          SectionTitle('Cuenta', color: sectionTitleColor),
          ListTile(
            leading: Icon(Icons.edit, color: iconColor),
            title: Text('Editar perfil', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: iconColor),
            onTap: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final postRepository = ref.read(profileRepositoryProvider);
              final user = await postRepository.getUser(uid);

              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => EditProfileBottomSheet(user: user),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.local_offer_outlined, color: iconColor),
            title: Text('Actualizar preferencias',
                style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: iconColor),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          SectionTitle('Soporte', color: sectionTitleColor),
          ListTile(
            leading:
                Icon(Icons.report_gmailerrorred_outlined, color: iconColor),
            title: Text('Reportar un problema',
                style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: iconColor),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: iconColor),
            title: Text('FAQ', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: iconColor),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.chat_bubble_outline, color: iconColor),
            title: Text('Contactanos', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: iconColor),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          SectionTitle('Acceso', color: sectionTitleColor),
          ListTile(
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const SectionTitle(this.title, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

Widget _buildThemeSliderSelector(BuildContext context, WidgetRef ref) {
  final themeMode = ref.watch(themeModeProvider);

  final colors = [
    Colors.blueGrey.shade900,
    Colors.orange.shade600,
    Colors.green.shade600,
  ];

  final icons = [
    Icons.nightlight_round,
    Icons.wb_sunny_rounded,
    Icons.brightness_auto,
  ];

  final labels = ["Oscuro", "Claro", "Sistema"];

  return _ThemeSliderSelectorInternal(
    initialIndex: ThemeMode.values.indexOf(themeMode),
    colors: colors,
    icons: icons,
    labels: labels,
    onChanged: (index) {
      ref
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.values[index]);
    },
  );
}

class _ThemeSliderSelectorInternal extends StatefulWidget {
  final int initialIndex;
  final List<Color> colors;
  final List<IconData> icons;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _ThemeSliderSelectorInternal({
    required this.initialIndex,
    required this.colors,
    required this.icons,
    required this.labels,
    required this.onChanged,
  });

  @override
  State<_ThemeSliderSelectorInternal> createState() =>
      _ThemeSliderSelectorInternalState();
}

class _ThemeSliderSelectorInternalState
    extends State<_ThemeSliderSelectorInternal> {
  late double _dragPosition;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _dragPosition = _selectedIndex.toDouble();
  }

  void _updateIndexFromDrag(double globalDx, double width, double margin) {
    final localDx = (globalDx - margin).clamp(0, width);
    final percent = localDx / width;
    final pos = percent * 2;
    setState(() {
      _dragPosition = pos;
      _selectedIndex = pos.round().clamp(0, 2);
    });
  }

  void _commitSelection() {
    widget.onChanged(_selectedIndex);
    // Ajusta _dragPosition para que coincida con índice seleccionado
    setState(() {
      _dragPosition = _selectedIndex.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    const marginHorizontal = 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Iconos + labels arriba
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: marginHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final isSelected = index == _selectedIndex;
              return Column(
                children: [
                  Icon(
                    widget.icons[index],
                    size: isSelected ? 30 : 24,
                    color: isSelected
                        ? widget.colors[index]
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.labels[index],
                    style: TextStyle(
                      fontSize: isSelected ? 14 : 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? widget.colors[index]
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),

        const SizedBox(height: 12),

        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final width = box.size.width - marginHorizontal * 2;
            _updateIndexFromDrag(
                details.globalPosition.dx, width, marginHorizontal);
          },
          onHorizontalDragEnd: (_) => _commitSelection(),
          onTapUp: (details) {
            final box = context.findRenderObject() as RenderBox;
            final width = box.size.width - marginHorizontal * 2;
            _updateIndexFromDrag(
                details.globalPosition.dx, width, marginHorizontal);
            _commitSelection();
          },
          child: SizedBox(
            height: 40,
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth - marginHorizontal * 2;

              final selectorPos = width * (_dragPosition / 2);

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(
                        horizontal: marginHorizontal),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        final isSelected = index == _selectedIndex;
                        return Container(
                          width: isSelected ? 16 : 12,
                          height: isSelected ? 16 : 12,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.colors[index]
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    left: selectorPos + marginHorizontal - 14,
                    top: 6,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.colors[_selectedIndex],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                widget.colors[_selectedIndex].withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
