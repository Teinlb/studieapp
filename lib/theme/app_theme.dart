import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color primaryDark = Color(0xFF0A0F2C);
  static const Color secondaryBlue = Color(0xFF1A1E36);
  static const Color accentOrange =
      Color(0xFFFFA726); //fromARGB(255, 38, 255, 103)
  static const Color errorRed = Color(0xFFEF4444);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Color(0xFFB0B0B0);

  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 16.0;

  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: accentOrange,
      surface: secondaryBlue,
      error: errorRed,
      onPrimary: textPrimary,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      onError: textPrimary,
    ),
    scaffoldBackgroundColor: primaryDark,
    textTheme: TextTheme(
      displayLarge: getOrbitronStyle(size: 28, weight: FontWeight.bold),
      displayMedium: getOrbitronStyle(size: 24, weight: FontWeight.bold),
      titleLarge: getOrbitronStyle(size: 36, weight: FontWeight.bold),
      bodyLarge: getOrbitronStyle(size: 16, color: textSecondary),
      bodyMedium: getOrbitronStyle(size: 14, color: textTertiary),
      labelLarge: getOrbitronStyle(
          size: 18, weight: FontWeight.bold, color: Colors.black),
      labelMedium: getOrbitronStyle(size: 16, color: accentOrange),
      labelSmall: getOrbitronStyle(size: 12, color: textTertiary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: getOrbitronStyle(size: 24, weight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentOrange,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 10,
        shadowColor: accentOrange.withOpacity(0.4),
        textStyle: getOrbitronStyle(
            size: 18, weight: FontWeight.bold, color: Colors.black),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentOrange,
        textStyle:
            getOrbitronStyle(size: 16, decoration: TextDecoration.underline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBlue,
      hintStyle: TextStyle(color: textPrimary.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: accentOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      prefixIconColor: accentOrange,
    ),
    cardTheme: CardTheme(
      color: secondaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(largeBorderRadius),
      ),
      elevation: 8,
    ),
  );

  // Helper method for consistent Orbitron text styles
  static TextStyle getOrbitronStyle({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = textPrimary,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Orbitron',
      fontSize: size,
      fontWeight: weight,
      color: color,
      decoration: decoration,
    );
  }
}
