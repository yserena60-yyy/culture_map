import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Solitude Explorer Theme - "百年孤独" Vintage Manuscript Aesthetic
class SolitudeExplorerTheme {
  // === Core Parchment Colors ===
  static const Color agedYellow = Color(0xFFFAF8F4); // Very light beige background
  static const Color stainedPaper = Color(0xFFF5F0E6); // Light beige for cards
  static const Color weatheredTan = Color(0xFFEDE8DC); // Slightly darker beige

  // === Ink & Text Colors ===
  static const Color inkBlack = Color(0xFF2C2416); // Deep brown-black for primary text
  static const Color inkBlackLight = Color(0xFF4A3B2C); // Lighter ink for hover states
  static const Color fadedInk = Color(0xFF6B5E4F); // Faded brown for secondary text

  // === Accent Colors - Burgundy Red (replaces ugly yellow) ===
  static const Color burgundyRed = Color(0xFF6B3636); // Main accent color
  static const Color burgundyRedLight = Color(0xFF8B4545);
  static const Color burgundyRedDark = Color(0xFF4A2424);
  static const Color burgundyRedSurface = Color(0xFFFAF0F0);

  // === Gold Accent (subtle, for special highlights) ===
  static const Color compassGold = Color(0xFFB8860B); // Dark goldenrod
  static const Color compassGoldDark = Color(0xFF8B6508);
  static const Color compassGoldSurface = Color(0xFFFFF8DC);

  // === Edge & Border Colors ===
  static const Color stainedPaperEdge = Color(0xFFD4C9B5); // Border color
  static const Color stainedPaperDark = Color(0xFFC4B5A0);
  static const Color stainedPaperVariant = Color(0xFFE8DCC8);

  // === Gradient Definitions ===
  static const List<Color> heroGradient = [
    Color(0xFFEDE8DC),
    Color(0xFFF5EFE6),
  ];

  static const List<Color> burgundyRedGradient = [
    Color(0xFF6B3636),
    Color(0xFF4A2424),
  ];

  static const List<Color> compassGoldGradient = [
    Color(0xFFB8860B),
    Color(0xFF8B6508),
  ];

  // Helper to convert gradient lists to LinearGradient
  static LinearGradient get heroLinearGradient => const LinearGradient(
        colors: heroGradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get burgundyRedLinearGradient => const LinearGradient(
        colors: burgundyRedGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

extension SolitudeExplorerThemeData on SolitudeExplorerTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.crimsonTextTextTheme(), // 全局使用 Crimson Text 复古字体
      colorScheme: ColorScheme.light(
        primary: SolitudeExplorerTheme.burgundyRed,
        secondary: SolitudeExplorerTheme.compassGold,
        surface: SolitudeExplorerTheme.agedYellow,
        error: SolitudeExplorerTheme.burgundyRed,
      ),
      scaffoldBackgroundColor: SolitudeExplorerTheme.agedYellow,
      appBarTheme: AppBarTheme(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        foregroundColor: SolitudeExplorerTheme.inkBlack,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
          color: SolitudeExplorerTheme.inkBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.crimsonText(),
        hintStyle: GoogleFonts.crimsonText(color: SolitudeExplorerTheme.fadedInk),
        helperStyle: GoogleFonts.crimsonText(),
        errorStyle: GoogleFonts.crimsonText(),
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.crimsonText(),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.crimsonText(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.crimsonText(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
