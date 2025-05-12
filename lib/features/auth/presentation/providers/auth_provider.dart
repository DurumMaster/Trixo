import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

final authProvider = FutureProvider<bool>((ref) async {
  final authService = AuthService(); // Replace with your actual AuthService
  return await authService.isLoggedIn();
});
