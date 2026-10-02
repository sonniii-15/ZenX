import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'zenx_colors.dart';

class ZenXTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ZenXColors.background,
      primaryColor: ZenXColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: ZenXColors.primary,
        secondary: ZenXColors.accent,
        surface: ZenXColors.surface,
        error: ZenXColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: ZenXColors.textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: ZenXColors.textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.outfit(color: ZenXColors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: ZenXColors.textPrimary),
        bodyMedium: const TextStyle(color: ZenXColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: ZenXColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ZenXColors.surfaceHighlight, width: 1), // Metallic/Charcoal border
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZenXColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: ZenXColors.primaryDark, width: 1),
          ),
          elevation: 4,
          shadowColor: ZenXColors.accent.withValues(alpha: 0.3), // Glow effect
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZenXColors.metallic,
          side: const BorderSide(color: ZenXColors.steel),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ZenXColors.surface,
        selectedItemColor: ZenXColors.accent,
        unselectedItemColor: ZenXColors.steel,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ZenXColors.metallic),
        titleTextStyle: TextStyle(color: ZenXColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
