import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // DEALIX AI COLORS
  // ============================================================

  /// Primary Green
  /// Primary buttons, active controls, best-price states
  static const Color primaryGreen = Color(0xFF16A34A);

  /// Secondary Teal
  /// Secondary actions and brand accents
  static const Color secondaryTeal = Color(0xFF0F766E);

  /// Soft Mint
  /// Cover and marketing/background areas
  static const Color softMint = Color(0xFFECFDF5);

  /// Main App Background
  static const Color appBackground = Color(0xFFF8FAFC);

  /// Light Mint
  /// Search/input and soft highlight areas
  static const Color lightMint = Color(0xFFF0FDFA);

  /// White
  /// Cards and clean content areas
  static const Color white = Color(0xFFFFFFFF);

  /// Main Text
  static const Color textPrimary = Color(0xFF172033);

  /// Secondary Text
  static const Color textSecondary = Color(0xFF64748B);

  /// Border
  static const Color border = Color(0xFFD1FAE5);

  /// Accent
  /// Deals and attention highlights
  static const Color accent = Color(0xFFF59E0B);

  /// Error
  static const Color error = Color(0xFFDC2626);

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,

    fontFamily: 'Inter',

    scaffoldBackgroundColor: appBackground,

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryTeal,
      surface: white,
      error: error,
    ),

    // ----------------------------------------------------------
    // App Bar
    // ----------------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),

    // ----------------------------------------------------------
    // Text Theme
    // ----------------------------------------------------------
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),

      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),

      headlineSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),

      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),

      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),

      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),

      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      ),
    ),

    // ----------------------------------------------------------
    // Primary Buttons
    // ----------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: white,

        minimumSize: const Size(double.infinity, 50),

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),

        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ----------------------------------------------------------
    // Secondary / Outline Buttons
    // ----------------------------------------------------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryTeal,

        minimumSize: const Size(double.infinity, 50),

        side: const BorderSide(color: secondaryTeal, width: 1.2),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),

        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ----------------------------------------------------------
    // Input Fields / Search Bar
    // ----------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: lightMint,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: textSecondary,
      ),

      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(mediumRadius),
        borderSide: const BorderSide(color: border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(mediumRadius),
        borderSide: const BorderSide(color: border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(mediumRadius),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(mediumRadius),
        borderSide: const BorderSide(color: error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(mediumRadius),
        borderSide: const BorderSide(color: error, width: 2),
      ),
    ),

    // ----------------------------------------------------------
    // Cards
    // ----------------------------------------------------------
    cardTheme: CardThemeData(
      color: white,

      elevation: 1,

      surfaceTintColor: Colors.transparent,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(largeRadius),
        side: const BorderSide(color: border, width: 1),
      ),

      margin: EdgeInsets.zero,
    ),

    // ----------------------------------------------------------
    // Bottom Navigation
    // ----------------------------------------------------------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,

      selectedItemColor: primaryGreen,

      unselectedItemColor: textSecondary,

      type: BottomNavigationBarType.fixed,

      elevation: 8,
    ),

    // ----------------------------------------------------------
    // Progress Indicator
    // ----------------------------------------------------------
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreen,
    ),

    // ----------------------------------------------------------
    // Divider
    // ----------------------------------------------------------
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
  );
}
