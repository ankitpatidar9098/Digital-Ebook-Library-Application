// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color background       = Color(0xFF0D0F14);   // Deep navy-black
  static const Color surface          = Color(0xFF161B27);   // Dark blue-grey
  static const Color surfaceVariant   = Color(0xFF1E2535);   // Lighter card
  static const Color primary          = Color(0xFFE8A24A);   // Warm amber (shelf)
  static const Color primaryVariant   = Color(0xFFD4891F);   // Darker amber
  static const Color secondary        = Color(0xFF6C8EBF);   // Cool blue accent
  static const Color onBackground     = Color(0xFFF2EFE4);   // Warm white text
  static const Color onSurface        = Color(0xFFCBC8BB);   // Muted text
  static const Color shelfWood        = Color(0xFF8B5E3C);   // Bookshelf brown
  static const Color shelfEdge        = Color(0xFF6B4423);   // Shelf shadow
  static const Color error            = Color(0xFFE25656);   // Error red
  static const Color success          = Color(0xFF52C78C);   // Success green

  // Book spine gradient colors (varied per book index)
  static const List<List<Color>> bookSpineGradients = [
    [Color(0xFF2C5F8A), Color(0xFF1A3D5C)],  // Steel blue
    [Color(0xFF8B2635), Color(0xFF5C1520)],  // Deep red
    [Color(0xFF2C7A4B), Color(0xFF1A4D30)],  // Forest green
    [Color(0xFF7B4F9A), Color(0xFF4D2F6B)],  // Royal purple
    [Color(0xFF8A6C2C), Color(0xFF5C4618)],  // Golden brown
    [Color(0xFF2C6B7A), Color(0xFF1A4250)],  // Teal
    [Color(0xFF8A3B2C), Color(0xFF5C2318)],  // Burnt sienna
    [Color(0xFF3B6B2C), Color(0xFF244318)],  // Olive green
  ];

  // ── Typography ─────────────────────────────────────────────────────────────
  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(fontFamily: 'Georgia', fontSize: 32, fontWeight: FontWeight.bold,   color: onBackground, letterSpacing: -0.5),
    displayMedium: TextStyle(fontFamily: 'Georgia', fontSize: 24, fontWeight: FontWeight.bold,   color: onBackground),
    displaySmall:  TextStyle(fontFamily: 'Georgia', fontSize: 20, fontWeight: FontWeight.w600,   color: onBackground),
    headlineMedium: TextStyle(fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.w600,  color: onBackground),
    titleLarge:    TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.w600,   color: onBackground),
    titleMedium:   TextStyle(fontFamily: 'Georgia', fontSize: 14, fontWeight: FontWeight.w500,   color: onBackground),
    bodyLarge:     TextStyle(fontFamily: 'Georgia', fontSize: 15, fontWeight: FontWeight.normal, color: onBackground, height: 1.6),
    bodyMedium:    TextStyle(fontFamily: 'Georgia', fontSize: 13, fontWeight: FontWeight.normal, color: onSurface),
    labelLarge:    TextStyle(fontFamily: 'Georgia', fontSize: 13, fontWeight: FontWeight.w600,   color: onBackground, letterSpacing: 0.5),
    labelSmall:    TextStyle(fontFamily: 'Georgia', fontSize: 11, fontWeight: FontWeight.normal, color: onSurface,     letterSpacing: 0.3),
  );

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3:  true,
    brightness:    Brightness.dark,
    colorScheme:   const ColorScheme.dark(
      primary:        primary,
      secondary:      secondary,
      surface:        surface,
      error:          error,
      onPrimary:      Colors.black,
      onSecondary:    Colors.white,
      onSurface:      onBackground,
    ),
    scaffoldBackgroundColor: background,
    textTheme:     _textTheme,
    appBarTheme:   const AppBarTheme(
      backgroundColor:    surface,
      foregroundColor:    onBackground,
      elevation:          0,
      centerTitle:        false,
      titleTextStyle:     TextStyle(
        fontFamily: 'Georgia',
        fontSize:   20,
        fontWeight: FontWeight.bold,
        color:      onBackground,
      ),
    ),
    cardTheme:     CardTheme(
      color:       surfaceVariant,
      elevation:   4,
      shadowColor: Colors.black54,
      shape:       RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black87,
        textStyle:       const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold, fontSize: 14),
        padding:         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:           true,
      fillColor:        surfaceVariant,
      border:           OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
      hintStyle:        const TextStyle(color: onSurface, fontFamily: 'Georgia'),
      labelStyle:       const TextStyle(color: primary,   fontFamily: 'Georgia'),
      prefixIconColor:  onSurface,
    ),
    dividerTheme:  const DividerThemeData(color: surfaceVariant, thickness: 1),
    iconTheme:     const IconThemeData(color: onSurface),
  );

  // ── Helper ─────────────────────────────────────────────────────────────────
  static List<Color> bookColors(int index) {
    return bookSpineGradients[index % bookSpineGradients.length];
  }
}
