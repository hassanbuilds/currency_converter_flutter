import 'package:flutter/material.dart';

class AppTheme {
  // A helper function for responsive font scaling
  static double _scaleFont(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.9; // small devices
    if (width > 600) return baseSize * 1.2; // tablets
    return baseSize; // normal devices
  }

  // LIGHT THEME - CREAM/BEIGE WITH BROWN ELEMENTS
  static ThemeData lightTheme(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    // Color Scheme - Cream with Brown
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8B4513), // Rich Brown
      secondary: Color(0xFFA0522D), // Sienna (lighter brown)
      surface: Color(0xFFFFF8E1), // Beige Background
      onPrimary: Colors.white,
      onSecondary: Colors.white, // Dark Brown text
      onSurface: Color(0xFF5D4037), // Dark Brown text on surfaces
    ),

    // App Bar - Rich Brown
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8B4513),
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
    ),

    // Cards - Cream with Brown shadow
    cardTheme: CardTheme(
      color: Color(0xFFFFF8E1),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Color(0xFF8B4513).withOpacity(0.2),
    ),

    // Buttons - Brown with white text
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8B4513), // Brown
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: _scaleFont(context, 16),
        ),
        textStyle: TextStyle(
          fontSize: _scaleFont(context, 16),
          fontWeight: FontWeight.w600,
        ),
        shadowColor: Color(0xFF8B4513).withOpacity(0.3),
      ),
    ),

    // Input Fields - Cream with Brown borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFF8E1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF8B4513).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFF8B4513).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: _scaleFont(context, 16),
      ),
      hintStyle: TextStyle(color: Color(0xFF8B4513).withOpacity(0.5)),
    ),

    // Text Styles - Brown themed
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: _scaleFont(context, 32),
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B4513), // Brown
      ),
      displayMedium: TextStyle(
        fontSize: _scaleFont(context, 24),
        fontWeight: FontWeight.w600,
        color: Color(0xFF8B4513), // Brown
      ),
      bodyLarge: TextStyle(
        fontSize: _scaleFont(context, 16),
        color: Color(0xFF5D4037), // Dark Brown
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontSize: _scaleFont(context, 14),
        color: Color(0xFF795548), // Medium Brown
      ),
      labelLarge: TextStyle(
        fontSize: _scaleFont(context, 16),
        fontWeight: FontWeight.w600,
        color: Colors.white, // White on brown buttons
      ),
    ),

    // Floating Action Button - Brown
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF8B4513), // Brown
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Color(0xFF8B4513).withOpacity(0.2),
      thickness: 1,
      space: 20,
    ),
  );

  // DARK THEME - SLEEK GRAY THEME
  static ThemeData darkTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    // Color Scheme - Sleek Gray
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF64B5F6), // Light Blue accent
      secondary: Color(0xFF90CAF9), // Lighter Blue
      tertiary: Color(0xFF42A5F5), // Blue
      surface: Color(0xFF2D2D2D), // Dark Gray background
      onPrimary: Color(0xFF1E1E1E), // Dark text on light blue
      onSecondary: Color(0xFF1E1E1E), // Dark text on lighter blue
    ),

    // App Bar - Dark Gray with Blue accent
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D2D2D),
      foregroundColor: Color(0xFF64B5F6), // Light Blue text
      elevation: 4,
      centerTitle: true,
    ),

    // Cards - Dark Gray with subtle shadows
    cardTheme: CardTheme(
      color: Color(0xFF2D2D2D),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Color(0xFF424242).withOpacity(0.3), width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
    ),

    // Buttons - Blue with dark text
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF64B5F6), // Light Blue
        foregroundColor: Color(0xFF1E1E1E), // Dark text
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: _scaleFont(context, 14),
        ),
        textStyle: TextStyle(
          fontSize: _scaleFont(context, 16),
          fontWeight: FontWeight.w600,
        ),
        shadowColor: Color(0xFF64B5F6).withOpacity(0.3),
      ),
    ),

    // Input Fields - Dark Gray with Blue borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF424242).withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF424242).withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: _scaleFont(context, 14),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),

    // Text Styles - Light Gray with Blue accents
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: _scaleFont(context, 32),
        fontWeight: FontWeight.bold,
        color: Color(0xFF64B5F6), // Light Blue
      ),
      displayMedium: TextStyle(
        fontSize: _scaleFont(context, 24),
        fontWeight: FontWeight.w600,
        color: Color(0xFF90CAF9), // Lighter Blue
      ),
      bodyLarge: TextStyle(
        fontSize: _scaleFont(context, 16),
        color: Color(0xFFE0E0E0), // Light Gray
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontSize: _scaleFont(context, 14),
        color: Color(0xFFB0BEC5), // Blue Gray
      ),
      labelLarge: TextStyle(
        fontSize: _scaleFont(context, 16),
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E1E1E), // Dark text on blue buttons
      ),
    ),

    // Floating Action Button - Blue
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF64B5F6), // Light Blue
      foregroundColor: Color(0xFF1E1E1E), // Dark text
      elevation: 4,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
      space: 20,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: Color(0xFF1E1E1E),
  );

  // Helper method to create gradient backgrounds
  static LinearGradient primaryGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Helper method for card gradients
  static LinearGradient cardGradient(BuildContext context) {
    return LinearGradient(
      colors: [
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.surface.withOpacity(0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
