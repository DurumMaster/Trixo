import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackArrow extends StatelessWidget {
  final String route;

  const CustomBackArrow({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (context.mounted) {
          context.go(route);
        }
      },
      icon: Icon(
        Icons.arrow_back_rounded,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        size: 32,
      ),
    );
  }
}
