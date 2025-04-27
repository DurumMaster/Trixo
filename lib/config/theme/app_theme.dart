import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.primary,
        onSurface:
            isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        onError: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? AppColors.surfaceLight : AppColors.backgroundDark,
        foregroundColor: isLight ? AppColors.primary : AppColors.accent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isLight ? AppColors.primary : AppColors.accent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: _textTheme(isLight),
      dividerColor: isLight ? AppColors.borderLight : AppColors.borderDark,
      cardColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
    );
  }

  static TextTheme _textTheme(bool isLight) {
    final primary =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final secondary =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge:
          TextStyle(color: primary, fontSize: 48, fontWeight: FontWeight.bold),
      headlineLarge:
          TextStyle(color: primary, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge:
          TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: primary, fontSize: 16),
      bodyMedium: TextStyle(color: secondary, fontSize: 14),
      labelLarge:
          TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
