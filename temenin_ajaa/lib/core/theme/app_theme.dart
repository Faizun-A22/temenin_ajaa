// Path: theme\app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFFB0D0);
  static const Color darkPink = Color(0xFF90015A);
  static const Color deepRed = Color(0xFF63003D);
  static const Color darkBg = Color(0xFF141313);
  static const Color cardBg = Color(0xFF201F1F);
  static const Color inputBg = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFFE5E2E1);
  static const Color textMuted = Color(0xFFC4C7C7);
  static const Color textMutedLight = Color(0x66C4C7C7);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryPink,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryPink,
        secondary: primaryPink,
        surface: cardBg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPink),
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: deepRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: deepRed,
          letterSpacing: -0.9,
          fontFamily: 'PlusJakartaSans',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryPink,
          letterSpacing: -0.7,
          fontFamily: 'PlusJakartaSans',
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: deepRed,
          fontFamily: 'PlusJakartaSans',
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'BeVietnamPro',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textMuted,
          fontFamily: 'BeVietnamPro',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMuted,
          fontFamily: 'BeVietnamPro',
        ),
      ),
    );
  }
}