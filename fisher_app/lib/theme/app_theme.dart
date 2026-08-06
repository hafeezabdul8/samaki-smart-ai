import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBg = Color(0xFF0a0f1e);
  static const Color cardBg = Color(0xFF111827);
  static const Color cardBorder = Color(0x14FFFFFF);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color violetAccent = Color(0xFF7C3AED);

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: primaryBg,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: blueAccent,
        secondary: cyanAccent,
        surface: cardBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static BoxDecoration glassDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: cardBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration glowGradient(double opacity) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          blueAccent.withValues(alpha: opacity),
          cyanAccent.withValues(alpha: opacity * 0.5),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }
}