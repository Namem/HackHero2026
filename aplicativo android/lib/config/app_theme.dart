import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF06D6A0);
  static const Color danger = Color(0xFFEF476F);
  static const Color warning = Color(0xFFFFD166);
  static const Color safe = Color(0xFF06D6A0);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
      );

  static Color riskColor(int level) {
    if (level <= 3) return safe;
    if (level <= 6) return warning;
    return danger;
  }

  static String riskLabel(int level) {
    if (level <= 3) return 'Seguro';
    if (level <= 6) return 'Atenção';
    return 'Risco Alto';
  }

  static IconData riskIcon(int level) {
    if (level <= 3) return Icons.check_circle;
    if (level <= 6) return Icons.warning;
    return Icons.dangerous;
  }
}
