import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core colors
  static const Color primaryDark = Color(0xFF0A0F2C);
  static const Color secondaryBlue = Color(0xFF1A1E36);
  static const Color tertiaryBlue = Color.fromARGB(255, 11, 20, 83);
  static const Color accentOrange = Color(0xFFFFA726);
  static const Color errorRed = Color(0xFFEF4444);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Color(0xFFB0B0B0);

  static const double borderRadius = 16.0;
  static const double largeBorderRadius = 20.0;

  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.roboto().fontFamily, // Roboto als standaard font
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
      displayLarge: _getRobotoStyle(size: 32, weight: FontWeight.bold),
      displayMedium: _getRobotoStyle(size: 28, weight: FontWeight.bold),
      titleLarge: _getRobotoStyle(size: 40, weight: FontWeight.w400),
      bodyLarge: _getRobotoStyle(size: 16, color: textSecondary),
      bodyMedium: _getRobotoStyle(size: 14, color: textTertiary),
      labelLarge: _getRobotoStyle(
          size: 20, weight: FontWeight.bold, color: primaryDark),
      labelMedium: _getRobotoStyle(size: 18, color: accentOrange),
      labelSmall: _getRobotoStyle(size: 12, color: textTertiary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: _getRobotoStyle(size: 24, weight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentOrange,
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 6,
        shadowColor: accentOrange.withOpacity(0.5),
        textStyle: _getRobotoStyle(
            size: 18, weight: FontWeight.bold, color: primaryDark),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentOrange,
        textStyle:
            _getRobotoStyle(size: 16, decoration: TextDecoration.underline),
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

  static TextStyle _getRobotoStyle({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = textPrimary,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        decoration: decoration,
        letterSpacing: 0.5,
      ),
    );
  }

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
      letterSpacing: 0.5,
    );
  }
}
