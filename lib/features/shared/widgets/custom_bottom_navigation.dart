import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/home');
        break;
      case 2:
        context.go('/home');
        break;
      case 3:
        context.go('/home');
        break;
      case 4:
        context.go('/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.home_filled,
      Icons.search_outlined,
      Icons.add_circle_outline,
      Icons.shopping_bag_outlined,
      Icons.person_outline,
    ];

    final selectedItems = [
      Icons.home,
      Icons.search,
      Icons.add_circle,
      Icons.shopping_bag,
      Icons.person,
    ];

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[600],
      elevation: 8,
      items: List.generate(5, (index) {
        final isSelected = selectedIndex == index;
        return BottomNavigationBarItem(
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Icon(isSelected ? selectedItems[index] : items[index]),
            ),
          ),
          label: '',
        );
      }),
    );
  }
}
