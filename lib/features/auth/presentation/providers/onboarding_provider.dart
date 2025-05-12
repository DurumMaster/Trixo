import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixo_frontend/features/auth/domain/auth_domain.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';

class PreferencesProvider extends ChangeNotifier {
  final Map<String, Color> allPreferences = {
    '🛹 Streetwear': const Color(0xFFFF4081),
    '🎩 Clásico': const Color(0xFF546E7A),
    '👗 Elegante': const Color(0xFFAB47BC),
    '🧥 Oversized': const Color(0xFF29B6F6),
    '🎨 Experimental': const Color(0xFFFF7043),
    '🌿 Eco': const Color(0xFF66BB6A),
    '👾 Techwear': const Color(0xFF7E57C2),
    '🕶️ Minimalista': const Color(0xFF90A4AE),
    '🔥 Urbano': const Color(0xFFFF5252),
    '💀 Darkwear': const Color(0xFF504F4F),
    '🌈 Colorido': const Color(0xFFFFC107),
    '🧵 Artesanal': const Color(0xFF8D6E63),
    '👑 Lujo': const Color(0xFFD32F2F),
    '🏴‍☠️ Grunge': const Color(0xFF616161),
    '🌆 Metropolitano': const Color(0xFF37474F),
    '🌊 Surf': const Color(0xFF0288D1),
    '🌴 Bohemio': const Color(0xFF4CAF50),
    '🌟 Futurista': const Color(0xFF00BCD4),
    '🏙️ Chic': const Color(0xFF607D8B),
    '👚 Casual': const Color(0xFF9E9E9E),
    '🦇 Gothic': const Color(0xFF555151),
    '🌙 Nocturno': const Color(0xFF303F9F),
    '✨ Místico': const Color(0xFF9C27B0),
    '🦁 Animal Print': const Color(0xFFEF6C00),
    '💖 Soft girl': const Color(0xFFF06292),
    '🤖 Cyberpunk': const Color(0xFF7B1FA2),
    '🏞️ Outdoor': const Color(0xFF388E3C),
    '🥾 Gorp Core': const Color(0xFF795548),
    '🏕️ Adventure': const Color(0xFF8BC34A),
    '🌍 Travel': const Color(0xFF9E9D24),
    '💨 Athleisure': const Color(0xFF4CAF50),
    '🌾 Cottagecore': const Color(0xFF8E24AA),
    '🏋️‍♀️ Gymwear': const Color(0xFF0288D1),
    '💀 Horrorcore': const Color(0xFF8B0000),
    '🧥 Puffer': const Color(0xFFB0BEC5),
    '🚴‍♀️ Urban Cycling': const Color(0xFF0288D1),
    '🌞 Tropical': const Color(0xFFFFEB3B),
    '🍂 Fall Vibes': const Color(0xFF795548),
    '🖋️ Art Hoe': const Color(0xFF6A1B9A),
    '🍓 Y2K': const Color(0xFFFF4081),
    '🎀 Romántico': const Color(0xFFF48FB1),
    '💎 Glam': const Color(0xFF8E24AA),
    '💼 Profesional': const Color(0xFF8E8E8E),
    '🧩 Creativo': const Color(0xFF9C27B0),
    '🎤 Musical': const Color(0xFFFF4081),
    '🌇 City Vibes': const Color(0xFF9E9E9E),
    '🏝️ Verano': const Color(0xFFFFC107),
    '🌃 Nocturna': const Color(0xFF263238),
    '🏄‍♂️ Playero': const Color(0xFF0288D1),
    '🧘‍♂️ Relajado': const Color(0xFF81C784),
    '🌌 Espacial': const Color(0xFF3F51B5),
    '🌿 Natural': const Color(0xFF4CAF50),
    '🧡 Cálido': const Color(0xFFEF6C00),
    '💚 Fresh': const Color(0xFF66BB6A),
    '🌍 Global': const Color(0xFF9E9D24),
    '🍃 Fresh': const Color(0xFF81C784),
    '🧸 Dulce': const Color(0xFFF8BBD0),
    '🌺 Floral': const Color(0xFFEC407A),
    '⚡ Energético': const Color(0xFFFFEB3B),
  };

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
