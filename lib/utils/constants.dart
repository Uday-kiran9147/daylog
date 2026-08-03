// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── categories ───────────────────────────────────────────────────────────────

const kCategories = ['learning', 'dsa', 'system design', 'content', 'play time', 'job hunt', 'other'];

const kCategoryColors = <String, Color>{
  'learning': Color(0xFF2383E2),
  'dsa': Color(0xFF00A3A6),
  'system design': Color(0xFFD9534F),
  'content': Color(0xFFD97706),
  'play time': Color(0xFF0F7B6C),
  'job hunt': Color(0xFFC026D3),
  'other': Color(0xFF6B7280),
};

// Notion Pastel Tag Color Tokens (Background & Text)
class NotionCategoryStyle {
  final Color bgLight;
  final Color textLight;
  final Color bgDark;
  final Color textDark;

  const NotionCategoryStyle({
    required this.bgLight,
    required this.textLight,
    required this.bgDark,
    required this.textDark,
  });
}

const kNotionCategoryStyles = <String, NotionCategoryStyle>{
  'learning': NotionCategoryStyle(
    bgLight: Color(0xFFE8F0FE), textLight: Color(0xFF1D4ED8),
    bgDark: Color(0xFF1E293B), textDark: Color(0xFF93C5FD),
  ),
  'dsa': NotionCategoryStyle(
    bgLight: Color(0xFFE0F2FE), textLight: Color(0xFF0369A1),
    bgDark: Color(0xFF132E35), textDark: Color(0xFF7DD3FC),
  ),
  'system design': NotionCategoryStyle(
    bgLight: Color(0xFFFFEDD5), textLight: Color(0xFFC2410C),
    bgDark: Color(0xFF3C2415), textDark: Color(0xFFFDBA74),
  ),
  'content': NotionCategoryStyle(
    bgLight: Color(0xFFFEF3C7), textLight: Color(0xFFB45309),
    bgDark: Color(0xFF382B14), textDark: Color(0xFFFDE68A),
  ),
  'play time': NotionCategoryStyle(
    bgLight: Color(0xFFEDF3EC), textLight: Color(0xFF15803D),
    bgDark: Color(0xFF143823), textDark: Color(0xFF86EFAC),
  ),
  'job hunt': NotionCategoryStyle(
    bgLight: Color(0xFFFCE7F3), textLight: Color(0xFFBE185D),
    bgDark: Color(0xFF381928), textDark: Color(0xFFF472B6),
  ),
  'other': NotionCategoryStyle(
    bgLight: Color(0xFFF1F1EF), textLight: Color(0xFF5A5A5A),
    bgDark: Color(0xFF2C2C2C), textDark: Color(0xFFA0A0A0),
  ),
};

Color categoryColor(String cat) =>
    kCategoryColors[cat] ?? const Color(0xFF6B7280);

NotionCategoryStyle getNotionCategoryStyle(String cat) =>
    kNotionCategoryStyles[cat] ?? kNotionCategoryStyles['other']!;

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
    primary: Color(0xFF0F7B6C), // Notion Teal / Forest
    primaryContainer: Color(0xFFEDF3EC),
    onPrimaryContainer: Color(0xFF15803D),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF7F6F3),
    outlineVariant: Color(0xFFE9E9E7), // Notion hairline border
    onSurface: Color(0xFF37352F), // Notion Primary Dark Text
    onSurfaceVariant: Color(0xFF787774), // Notion Muted Text
    outline: Color(0xFF9B9A97),
    error: Color(0xFFEB5757),
  ),
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xFFFBFBFA),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFFFBFBFA),
    foregroundColor: Color(0xFF37352F),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF37352F),
      letterSpacing: -0.2,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFE9E9E7), width: 1.0),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF7F6F3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFE9E9E7), width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFE9E9E7), width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF0F7B6C), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFFBFBFA),
    selectedItemColor: Color(0xFF0F7B6C),
    unselectedItemColor: Color(0xFF787774),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

final kDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2EAADC), // Notion Blue Accent in Dark Mode
    primaryContainer: Color(0xFF1E293B),
    onPrimaryContainer: Color(0xFF93C5FD),
    surface: Color(0xFF202020), // Notion Card Surface Dark
    surfaceContainer: Color(0xFF282828),
    outlineVariant: Color(0xFF2F2F2F), // Notion Hairline Border Dark
    onSurface: Color(0xFFD4D4D4), // Notion Primary Light Text
    onSurfaceVariant: Color(0xFF9B9B9B), // Notion Muted Text
    outline: Color(0xFF6B6B71),
    error: Color(0xFFEB5757),
  ),
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xFF191919),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFF191919),
    foregroundColor: Color(0xFFD4D4D4),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFD4D4D4),
      letterSpacing: -0.2,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFF202020),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFF2F2F2F), width: 1.0),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF282828),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF2F2F2F), width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF2F2F2F), width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF2EAADC), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF191919),
    selectedItemColor: Color(0xFF2EAADC),
    unselectedItemColor: Color(0xFF9B9B9B),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);
