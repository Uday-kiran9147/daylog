// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── categories ───────────────────────────────────────────────────────────────

const kCategories = ['learning', 'dsa', 'system design', 'content', 'play time', 'job hunt', 'other'];

const kCategoryColors = <String, Color>{
  'learning': Color(0xFF4A90E2),
  'dsa': Color(0xFF00BCD4),
  'system design': Color(0xFFFF5722),
  'content': Color(0xFFFFA500),
  'play time': Color(0xFF8BC34A),
  'job hunt': Color(0xFFE91E63),
};

Color categoryColor(String cat) =>
    kCategoryColors[cat] ?? const Color(0xFF888780);

String capitalizeCategory(String cat) {
  if (cat == 'dsa') return 'DSA';
  return cat.split(' ').map((word) {
    if (word.isEmpty) return '';
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}

// ── theme ────────────────────────────────────────────────────────────────────

final kLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1D9E75),
    primaryContainer: Color(0xFFE6F6F1),
    onPrimaryContainer: Color(0xFF0A3B2A),
    background: Color(0xFFF8F8F6),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF1F1EF),
    outlineVariant: Color(0xFFE2E2DF),
    onSurface: Color(0xFF141412),
    onSurfaceVariant: Color(0xFF62625D),
    outline: Color(0xFF92928B),
    error: Color(0xFFFF5252),
  ),
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xFFF8F8F6),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFFF8F8F6),
    foregroundColor: Color(0xFF141412),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF141412),
      letterSpacing: -0.2,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFE2E2DF), width: 0.5),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF1F1EF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1D9E75), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF8F8F6),
    selectedItemColor: Color(0xFF1D9E75),
    unselectedItemColor: Color(0xFF888780),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

final kDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2EC4B6),
    primaryContainer: Color(0xFF122A26),
    onPrimaryContainer: Color(0xFFA9F3EB),
    background: Color(0xFF0F0F10),
    surface: Color(0xFF161618),
    surfaceContainer: Color(0xFF232326),
    outlineVariant: Color(0xFF2D2D31),
    onSurface: Color(0xFFF4F4F6),
    onSurfaceVariant: Color(0xFF9D9DA3),
    outline: Color(0xFF6B6B71),
    error: Color(0xFFFF5252),
  ),
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xFF0F0F10),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFF0F0F10),
    foregroundColor: Color(0xFFF4F4F6),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF4F4F6),
      letterSpacing: -0.2,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFF161618),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF2D2D31), width: 0.5),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF232326),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2EC4B6), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0F0F10),
    selectedItemColor: Color(0xFF2EC4B6),
    unselectedItemColor: Color(0xFF888780),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);
