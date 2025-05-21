import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

final authProvider = FutureProvider<bool>((ref) async {
  final authService = AuthService();
  return await authService.isLoggedIn();
});

final currentUserID = FutureProvider<String?> ((ref) async {
  final authService = AuthService();
  final String? user = await authService.getCurrentUser();
  return user;
});