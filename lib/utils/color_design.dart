import 'package:flutter/material.dart';

class AppColors {
  // --- Light Theme Palette (Sage / Rice-White) ---
  static const Color lightScaffold = Color(0xFFF7F7F2);
  static const Color lightSurface = Color(0xFFEBEBE5);
  static const Color lightTextPrimary = Color(0xFF2C3E2D);
  static const Color lightTextSecondary = Color(0xFF556B56);
  static const Color lightSuccess = Color(0xFF1B5E20);
  static const Color lightBorder = Color(0xFFD3D3CD);

  // --- Dark Theme Palette (Charcoal / Neon Accent) ---
  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF111111);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkSuccess = Colors.greenAccent;
  static const Color darkBorder = Colors.white12;
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightScaffold,
    primaryColor: Colors.blueAccent,
    colorScheme: const ColorScheme.light(
      primary: Colors.blueAccent,
      surface: AppColors.lightSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.lightTextPrimary,
    ),
    cardColor: AppColors.lightSurface,
    dividerColor: AppColors.lightBorder,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkScaffold,
    primaryColor: Colors.blueAccent,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueAccent,
      surface: AppColors.darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.darkTextPrimary,
    ),
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,
  );
}
