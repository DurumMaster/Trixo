import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            logOut(context);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text('Cerrar sesión'),
        ),
      ),
    );
  }
  
  void logOut(BuildContext context) {
    AuthService authService = AuthService();
    authService.signOut();
    context.go('/login');
  }
}
