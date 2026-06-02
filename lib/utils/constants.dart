// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── categories ───────────────────────────────────────────────────────────────

const kCategories = ['backend','dsa', 'study', 'content', 'job hunt', 'other'];

const kCategoryColors = <String, Color>{
  'backend': Color(0xFF1D9E75),
  'dsa': Color(0xFF4A90E2),
  'study': Color(0xFFBD10E0),
  'content': Color(0xFFFFA500),
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
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1D9E75),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  fontFamily: 'SF Pro Text', // falls back to system sans on Android
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1A1A1A),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1A1A1A),
    ),
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F8F6),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0x18000000), width: 0.5),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF1D9E75),
    unselectedItemColor: Color(0xFF888780),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

final kDarkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1D9E75),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  fontFamily: 'SF Pro Text',
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0x22FFFFFF), width: 0.5),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF121212),
    selectedItemColor: Color(0xFF1D9E75),
    unselectedItemColor: Color(0xFF888780),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);
