import 'package:flutter/material.dart';

// Legacy theme file - kept for backward compatibility
// New code should use solitude_explorer_theme.dart

class AppColors {
  static const Color background = Color(0xFFFAF8F4);
  static const Color surface = Color(0xFFF5F0E6);
  static const Color primary = Color(0xFF2C2416);
  static const Color secondary = Color(0xFF6B5E4F);
  static const Color accent = Color(0xFF6B3636);

  static const Color textPrimary = Color(0xFF2C2416);
  static const Color textSecondary = Color(0xFF6B5E4F);
  static const Color textTertiary = Color(0xFF8B7E6F);

  static const Color divider = Color(0xFFD4C9B5);
  static const Color error = Color(0xFF6B3636);
  static const Color warning = Color(0xFFB8860B);
  static const Color success = Color(0xFF6B8B23);

  static const Color parchment = Color(0xFFF5F0E6);
  static const Color parchmentEdge = Color(0xFFD4C9B5);
}

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
    );
  }
}
