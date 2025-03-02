import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      primary: Color(0xFF1E3A8A), // Deep Blue - Security
      secondary: Color(0xFF0D9488), // Teal - AI Intelligence
      surface: Colors.white, // Light Gray
      error: Color(0xFFF97316), // Orange - Alerts
      onPrimary: Colors.white, // White text on primary color
      onSecondary: Colors.white, // White text on secondary color
      onSurface: Colors.black, // Black text on background
      onError: Colors.white, // White text on error
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A), // Deep Blue
        foregroundColor: Colors.white, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      primary: Color(0xFF1E3A8A), // Deep Blue - Security
      secondary: Color(0xFF0D9488), // Teal - AI Intelligence
      surface: Color(0xFF111827), // Slightly lighter dark gray
      error: Color(0xFFF97316), // Orange - Alerts
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A), // Deep Blue
        foregroundColor: Colors.white, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
