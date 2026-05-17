import 'package:flutter/material.dart';

class AppTheme {
  // Escudo Azul — cores extraídas do logo vetorizado
  static const Color primary = Color(0xFF4A6FC7);        // azul vibrante (botões, destaques)
  static const Color primaryDark = Color(0xFF162D5A);     // navy escuro (nav, hero)
  static const Color primaryLight = Color(0xFF94A7DE);    // azul claro
  static const Color accent = Color(0xFF22C55E);          // verde (sucesso, ECA, status ativo)
  static const Color accentLight = Color(0xFFDCFCE7);

  static const Color danger = Color(0xFFDC2626);          // risco alto
  static const Color warning = Color(0xFFEA580C);         // risco médio
  static const Color safe = Color(0xFF16A34A);            // risco baixo

  static const Color surface = Color(0xFFF0F3FA);         // fundo azulado suave
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          surface: Colors.white,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            elevation: 2,
            shadowColor: primary.withValues(alpha: 0.3),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.03),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: primaryDark,
          indicatorColor: primary.withValues(alpha: 0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return IconThemeData(color: Colors.white.withValues(alpha: 0.5));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700);
            }
            return TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11);
          }),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      );

  static Color riskColor(int level) {
    if (level <= 3) return safe;
    if (level <= 6) return warning;
    return danger;
  }

  static String riskLabel(int level) {
    if (level <= 3) return 'Risco Baixo';
    if (level <= 6) return 'Risco Médio';
    return 'Risco Alto';
  }

  static IconData riskIcon(int level) {
    if (level <= 3) return Icons.check_circle;
    if (level <= 6) return Icons.warning_amber_rounded;
    return Icons.dangerous;
  }

  static Color riskBg(int level) {
    if (level <= 3) return const Color(0xFFD1FAE5);
    if (level <= 6) return const Color(0xFFFFEDD5);
    return const Color(0xFFFEE2E2);
  }

  static Color riskFg(int level) {
    if (level <= 3) return const Color(0xFF065F46);
    if (level <= 6) return const Color(0xFF9A3412);
    return const Color(0xFF991B1B);
  }
}
