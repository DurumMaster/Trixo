import 'package:flutter/material.dart';

import 'package:trixo_frontend/features/shared/widgets/widgets.dart';

class Home extends StatelessWidget {
  final Widget childView;

  const Home({super.key, required this.childView});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: childView,
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
