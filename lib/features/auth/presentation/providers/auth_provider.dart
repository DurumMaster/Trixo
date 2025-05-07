import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_service.dart';

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = AuthService(); // Replace with your actual AuthService
  return await authService.isLoggedIn();
});