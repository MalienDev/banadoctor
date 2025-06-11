import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor
  AppTheme._();

  // Light Theme Colors
  static const Color _primaryColor = Color(0xFF2E7D32);
  static const Color _primaryLightColor = Color(0xFF60AD5E);
  static const Color _primaryDarkColor = Color(0xFF005005);
  static const Color _secondaryColor = Color(0xFF1E88E5;
  static const Color _secondaryLightColor = Color(0xFF6AB7FF;
  static const Color _secondaryDarkColor = Color(0xFF005CB2;
  static const Color _errorColor = Color(0xFFC62828);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _onPrimary = Colors.white;
  static const Color _onSecondary = Colors.black;
  static const Color _onBackground = Color(0xFF1A1A1A);
  static const Color _onSurface = Color(0xFF1A1A1A);
  static const Color _onError = Colors.white;

  // Text Theme
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: _onBackground, letterSpacing: -1.5),
    displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300, color: _onBackground, letterSpacing: -0.5),
    displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: _onBackground),
    headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.25),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: _onBackground),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: _onBackground, letterSpacing: 0.15),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _onBackground, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _onBackground, letterSpacing: 1.25),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.4),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: _onBackground, letterSpacing: 0.5),
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      primaryContainer: _primaryDarkColor,
      secondary: _secondaryColor,
      secondaryContainer: _secondaryDarkColor,
      surface: _surfaceColor,
      background: _backgroundColor,
      error: _errorColor,
      onPrimary: _onPrimary,
      onSecondary: _onSecondary,
      onSurface: _onSurface,
      onBackground: _onBackground,
      onError: _onError,
      brightness: Brightness.light,
    ),
    textTheme: _lightTextTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: const TextStyle(color: _primaryColor),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark Theme (optional, can be implemented similarly)
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: _primaryLightColor,
      secondary: _secondaryLightColor,
    ),
  );
}
