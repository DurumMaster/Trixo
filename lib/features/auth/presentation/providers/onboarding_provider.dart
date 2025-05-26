import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

class PreferencesProvider extends ChangeNotifier {


  final Set<String> _selectedPreferences = {};

  List<String> get selectedPreferences => _selectedPreferences.toList();

  bool isSelected(String preference) {
    final cleanPreference = preference.contains(' ')
        ? preference.split(' ').sublist(1).join(' ')
        : preference;
    return _selectedPreferences.contains(cleanPreference);
  }

  void togglePreference(String preference) {
    final cleanPreference = preference.contains(' ')
        ? preference.split(' ').sublist(1).join(' ')
        : preference;

    if (_selectedPreferences.contains(cleanPreference)) {
      _selectedPreferences.remove(cleanPreference);
    } else {
      _selectedPreferences.add(cleanPreference);
    }
    notifyListeners();
  }

  bool get canSubmit => _selectedPreferences.isNotEmpty;
}

final preferencesProvider = ChangeNotifierProvider<PreferencesProvider>((ref) {
  return PreferencesProvider();
});

final hasPreferencesProvider = FutureProvider<bool>((ref) async {
  final AuthRepository repository = ref.read(preferencesRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return false;
  }
  return repository.hasPreferences(userId: user.uid);
});
