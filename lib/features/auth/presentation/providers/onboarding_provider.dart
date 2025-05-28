import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

class PreferencesProvider extends ChangeNotifier {
  static const int maxSelections = 10;
  static const int minSelections = 1;

  final Set<String> _selected = {};
  List<String> get selected => _selected.toList();

  bool isSelected(String key) => _selected.contains(key);
  bool get canSubmit => _selected.length >= minSelections;
  bool get hasReachedMax => _selected.length >= maxSelections;

  void togglePreference(String key) {
    if (_selected.contains(key)) {
      _selected.remove(key);
    } else if (_selected.length < maxSelections) {
      _selected.add(key);
    }
    notifyListeners();
  }

  void clearAll() {
    _selected.clear();
    notifyListeners();
  }

  void selectRandom(List<String> allKeys, {int count = 5}) {
    clearAll();
    final keys = List<String>.from(allKeys)..shuffle();
    final picks = keys.take(count);
    _selected.addAll(picks);
    notifyListeners();
  }
}

final preferencesProvider = ChangeNotifierProvider((ref) => PreferencesProvider());

final hasPreferencesProvider = FutureProvider<bool>((ref) async {
  final AuthRepository repository = ref.read(preferencesRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return false;
  }
  return repository.hasPreferences(userId: user.uid);
});
