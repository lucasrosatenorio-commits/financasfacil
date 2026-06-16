import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFF7C3AED);
  static const Color secondary  = Color(0xFF4F46E5);
  static const Color bg         = Color(0xFF0F0F1A);
  static const Color surface    = Color(0xFF1A1A2E);
  static const Color surface2   = Color(0xFF252540);
  static const Color border     = Color(0xFF1E1E3A);
  static const Color textMain   = Color(0xFFE8E8F0);
  static const Color textSub    = Color(0xFF9CA3AF);
  static const Color textMuted  = Color(0xFF6B7280);
  static const Color income     = Color(0xFF10B981);
  static const Color expense    = Color(0xFFF87171);
  static const Color warning    = Color(0xFFEF4444);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textMain,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: Color(0xFFA78BFA),
      unselectedItemColor: textMuted,
    ),
  );
}

// Gradient shortcuts
const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kIncomeGradient = LinearGradient(
  colors: [Color(0xFF10B981), Color(0xFF059669)],
);
