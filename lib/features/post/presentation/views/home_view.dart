import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trixo_frontend/config/config.dart';
import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int _selectedTab = 0;
  final List<String> _tabs = ['For you', 'Top', 'Following'];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Paginación futura
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(_tabs.length, (index) {
            final selected = _selectedTab == index;
            return GestureDetector(
              onTap: () => _onTabSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: selected ? 24 : 0,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            onPressed: () {
              // Acción de búsqueda
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              PostCard(
                imageUrls: const [
                  'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
                  'https://images.unsplash.com/photo-1607746882042-944635dfe10e'
                ],
                username: 'streetwave',
                avatarUrl: 'https://i.pravatar.cc/150?img=3',
                description:
                    'Nuevo drop esta semana 🔥 ¿Cuál te gusta más? #trixo #streetwearssssss',
                likeCount: 32854747,
                commentsCount: 21,
                onDoubleTapImage: () {
                  // Lógica de like (simulada)
                  debugPrint('Like por doble tap');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
