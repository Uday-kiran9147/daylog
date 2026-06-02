// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── categories ───────────────────────────────────────────────────────────────

const kCategories = ['backend', 'mobile', 'content', 'job hunt', 'other'];

const kCategoryColors = <String, Color>{
  'backend': Color(0xFF1D9E75),
  'mobile': Color(0xFF7F77DD),
  'content': Color(0xFFBA7517),
  'job hunt': Color(0xFFD85A30),
  'other': Color(0xFF888780),
};

Color categoryColor(String cat) =>
    kCategoryColors[cat] ?? const Color(0xFF888780);

// ── theme ────────────────────────────────────────────────────────────────────

final kAppTheme = ThemeData(
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
      side: const BorderSide(color: Color(0x22000000), width: 0.5),
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
