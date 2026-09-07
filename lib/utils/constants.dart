// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Organic Warm Color Tokens ────────────────────────────────────────────────

class DaylogColors {
  // Light Mode Canvas & Surfaces
  static const lightBg = Color(0xFFF5EAD8); // Warm cream canvas
  static const lightSurface = Color(0xFFEBDDC5); // Warm parchment surface
  static const lightCard = Color(0xFFFFF9F0); // Card container
  static const lightText = Color(0xFF201E1D); // Warm espresso text
  static const lightDivider = Color(0x29201E1D); // ~16% opacity divider

  // Accent Terracotta (Primary)
  static const accent = Color(0xFFC85A32); // Vibrant terracotta
  static const accent100 = Color(0xFFF8E4DC); // Soft peach wash
  static const accent200 = Color(0xFFEDBFA8);
  static const accent300 = Color(0xFFE09A7A);
  static const accent400 = Color(0xFFD47551);
  static const accent500 = Color(0xFFC85A32);
  static const accent600 = Color(0xFFB04823);
  static const accent700 = Color(0xFFA83B19); // Deep terracotta
  static const accent800 = Color(0xFF7A280F); // Very deep rust
  static const accent900 = Color(0xFF4D1707);

  // Accent Sage Green (Secondary / Accent-2)
  static const sage = Color(0xFF4A7C59);
  static const sage100 = Color(0xFFE2ECE5);
  static const sage200 = Color(0xFFC2D9C8);
  static const sage300 = Color(0xFFA2C6AC);
  static const sage400 = Color(0xFF82B38F);
  static const sage500 = Color(0xFF4A7C59);
  static const sage600 = Color(0xFF3B6748);
  static const sage700 = Color(0xFF2E593B);
  static const sage800 = Color(0xFF1E3D27);
  static const sage900 = Color(0xFF102618);

  // Dark Mode Canvas & Surfaces
  static const darkBg = Color(0xFF181615); // Deep charcoal
  static const darkSurface = Color(0xFF252220); // Warm dark surface
  static const darkCard = Color(0xFF2E2A28); // Dark card container
  static const darkText = Color(0xFFF5EAD8); // Warm light text
  static const darkDivider = Color(0x2EF5EAD8); // ~18% opacity divider
  static const darkAccent = Color(0xFFE07A5F); // Warm terracotta in dark mode
  static const darkAccent100 = Color(0xFF3D251C);
  static const darkAccent700 = Color(0xFFC85A32);
  static const darkAccent800 = Color(0xFFEDBFA8);
}

// ── Categories & Metadata ────────────────────────────────────────────────────

const kDefaultUserCategories = [
  'Development',
  'Deep Work',
  'Design',
  'Writing',
  'Learning',
  'Admin',
];

const kCategories = [
  'Development',
  'DSA',
  'System Design',
  'DevOps',
  'AI & Data',
  'Deep Work',
  'Design',
  'Product Planning',
  'Research',
  'Writing',
  'Content',
  'Audio & Video',
  'Creative',
  'Job Hunt',
  'Client Work',
  'Marketing',
  'Admin',
  'Learning',
  'Reading',
  'Health & Fitness',
  'Side Projects',
  'Breaks',
];

class CategoryDomain {
  final String title;
  final IconData icon;
  final List<String> categories;

  const CategoryDomain({
    required this.title,
    required this.icon,
    required this.categories,
  });
}

const kCategoryDomains = [
  CategoryDomain(
    title: 'Software & Tech',
    icon: Icons.code_rounded,
    categories: ['Development', 'DSA', 'System Design', 'DevOps', 'AI & Data'],
  ),
  CategoryDomain(
    title: 'Design & Product',
    icon: Icons.palette_outlined,
    categories: ['Design', 'Product Planning', 'Research'],
  ),
  CategoryDomain(
    title: 'Writing & Media',
    icon: Icons.edit_note_rounded,
    categories: ['Writing', 'Content', 'Audio & Video', 'Creative'],
  ),
  CategoryDomain(
    title: 'Business & Ops',
    icon: Icons.business_center_outlined,
    categories: ['Job Hunt', 'Client Work', 'Marketing', 'Admin'],
  ),
  CategoryDomain(
    title: 'Focus & Growth',
    icon: Icons.spa_outlined,
    categories: ['Deep Work', 'Learning', 'Reading', 'Health & Fitness', 'Side Projects', 'Breaks'],
  ),
];

class CategoryInfo {
  final String name;
  final List<String> keywords;
  final IconData icon;
  final Color tileColor;
  final Color lightBg;
  final Color lightFg;
  final Color darkBg;
  final Color darkFg;

  const CategoryInfo({
    required this.name,
    required this.keywords,
    required this.icon,
    required this.tileColor,
    required this.lightBg,
    required this.lightFg,
    required this.darkBg,
    required this.darkFg,
  });
}

const kCategoryData = <String, CategoryInfo>{
  'Development': CategoryInfo(
    name: 'Development',
    keywords: ['code', 'debug', 'api', 'flutter', 'sql', 'react', 'bug', 'app', 'server', 'git', 'frontend', 'backend'],
    icon: Icons.code_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFF8E4DC),
    lightFg: Color(0xFF7A280F),
    darkBg: Color(0xFF5A2210),
    darkFg: Color(0xFFF8E4DC),
  ),
  'DSA': CategoryInfo(
    name: 'DSA',
    keywords: ['dsa', 'algo', 'leetcode', 'tree', 'graph', 'array', 'sort', 'dp', 'algorithm', 'problem'],
    icon: Icons.hub_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'System Design': CategoryInfo(
    name: 'System Design',
    keywords: ['architecture', 'scaling', 'redis', 'kafka', 'system design', 'scale', 'microservice', 'database'],
    icon: Icons.layers_rounded,
    tileColor: Color(0xFF5E5854),
    lightBg: Color(0xFFE5DFD9),
    lightFg: Color(0xFF2C2825),
    darkBg: Color(0xFF3B3632),
    darkFg: Color(0xFFF0EBE6),
  ),
  'DevOps': CategoryInfo(
    name: 'DevOps',
    keywords: ['docker', 'kubernetes', 'aws', 'ci/cd', 'cloud', 'deploy', 'terraform', 'pipeline', 'devops'],
    icon: Icons.cloud_queue_rounded,
    tileColor: Color(0xFF386B8C),
    lightBg: Color(0xFFDFEAF0),
    lightFg: Color(0xFF143B52),
    darkBg: Color(0xFF123447),
    darkFg: Color(0xFFD4E6F0),
  ),
  'AI & Data': CategoryInfo(
    name: 'AI & Data',
    keywords: ['ai', 'ml', 'data', 'prompt', 'llm', 'model', 'python', 'pytorch', 'machine learning', 'analytics'],
    icon: Icons.auto_awesome_rounded,
    tileColor: Color(0xFF7A4E8C),
    lightBg: Color(0xFFEFE4F5),
    lightFg: Color(0xFF482057),
    darkBg: Color(0xFF3D164D),
    darkFg: Color(0xFFEADBFA),
  ),
  'Deep Work': CategoryInfo(
    name: 'Deep Work',
    keywords: ['focus', 'deep work', 'flow', 'core', 'priority', 'strategy', 'thinking', 'session'],
    icon: Icons.bolt_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFFBE8E0),
    lightFg: Color(0xFF8A3015),
    darkBg: Color(0xFF5E200E),
    darkFg: Color(0xFFFDECE5),
  ),
  'Design': CategoryInfo(
    name: 'Design',
    keywords: ['figma', 'ui/ux', 'ui', 'ux', 'wireframe', 'mockup', 'design', 'style', 'typography', 'prototype'],
    icon: Icons.palette_outlined,
    tileColor: Color(0xFFE07A5F),
    lightBg: Color(0xFFFCEBE6),
    lightFg: Color(0xFFA83B19),
    darkBg: Color(0xFF4D1707),
    darkFg: Color(0xFFEDBFA8),
  ),
  'Product Planning': CategoryInfo(
    name: 'Product Planning',
    keywords: ['roadmap', 'spec', 'prd', 'scrum', 'sprint', 'feature', 'planning', 'product'],
    icon: Icons.alt_route_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Research': CategoryInfo(
    name: 'Research',
    keywords: ['research', 'benchmark', 'survey', 'user test', 'interview', 'whitepaper', 'competitor'],
    icon: Icons.travel_explore_rounded,
    tileColor: Color(0xFF5E5854),
    lightBg: Color(0xFFE5DFD9),
    lightFg: Color(0xFF2C2825),
    darkBg: Color(0xFF3B3632),
    darkFg: Color(0xFFF0EBE6),
  ),
  'Writing': CategoryInfo(
    name: 'Writing',
    keywords: ['write', 'draft', 'article', 'essay', 'documentation', 'copy', 'journal', 'doc', 'readme'],
    icon: Icons.drive_file_rename_outline_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Content': CategoryInfo(
    name: 'Content',
    keywords: ['blog', 'video', 'content', 'post', 'script', 'youtube', 'podcast', 'social', 'x', 'tweet'],
    icon: Icons.edit_note_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Audio & Video': CategoryInfo(
    name: 'Audio & Video',
    keywords: ['audio', 'video', 'edit', 'record', 'mic', 'camera', 'premiere', 'youtube', 'record'],
    icon: Icons.movie_outlined,
    tileColor: Color(0xFF944B36),
    lightBg: Color(0xFFF5E4E0),
    lightFg: Color(0xFF5E1E10),
    darkBg: Color(0xFF471308),
    darkFg: Color(0xFFFCEBE8),
  ),
  'Creative': CategoryInfo(
    name: 'Creative',
    keywords: ['art', 'draw', 'illustration', '3d', 'blender', 'photo', 'creative', 'music'],
    icon: Icons.brush_outlined,
    tileColor: Color(0xFF9E654A),
    lightBg: Color(0xFFF5EAE4),
    lightFg: Color(0xFF542C18),
    darkBg: Color(0xFF3D1B0B),
    darkFg: Color(0xFFFAEEE8),
  ),
  'Job Hunt': CategoryInfo(
    name: 'Job Hunt',
    keywords: ['interview', 'resume', 'application', 'job', 'career', 'hr', 'recruiter', 'linkedin'],
    icon: Icons.work_outline_rounded,
    tileColor: Color(0xFF7D7570),
    lightBg: Color(0xFFEDE8E3),
    lightFg: Color(0xFF3D3734),
    darkBg: Color(0xFF332D2A),
    darkFg: Color(0xFFE5DFD9),
  ),
  'Client Work': CategoryInfo(
    name: 'Client Work',
    keywords: ['client', 'freelance', 'proposal', 'consulting', 'contract', 'customer', 'deliverable'],
    icon: Icons.handshake_outlined,
    tileColor: Color(0xFF3B6748),
    lightBg: Color(0xFFDFF0E4),
    lightFg: Color(0xFF143D1F),
    darkBg: Color(0xFF103319),
    darkFg: Color(0xFFDCF2E2),
  ),
  'Marketing': CategoryInfo(
    name: 'Marketing',
    keywords: ['growth', 'marketing', 'seo', 'ads', 'launch', 'traffic', 'conversion', 'campaign'],
    icon: Icons.trending_up_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFF8E4DC),
    lightFg: Color(0xFF7A280F),
    darkBg: Color(0xFF5A2210),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Admin': CategoryInfo(
    name: 'Admin',
    keywords: ['email', 'admin', 'meeting', 'invoice', 'paperwork', 'taxes', 'sync', 'bills', 'organize'],
    icon: Icons.mail_outline_rounded,
    tileColor: Color(0xFF3D8B6E),
    lightBg: Color(0xFFE0F0E9),
    lightFg: Color(0xFF134833),
    darkBg: Color(0xFF0F3B29),
    darkFg: Color(0xFFD4EFE3),
  ),
  'Learning': CategoryInfo(
    name: 'Learning',
    keywords: ['study', 'course', 'research', 'learn', 'tutorial', 'book', 'paper', 'lecture'],
    icon: Icons.menu_book_rounded,
    tileColor: Color(0xFF6B9E7C),
    lightBg: Color(0xFFEAF3ED),
    lightFg: Color(0xFF2E593B),
    darkBg: Color(0xFF183D24),
    darkFg: Color(0xFFC2D9C8),
  ),
  'Reading': CategoryInfo(
    name: 'Reading',
    keywords: ['reading', 'kindle', 'novel', 'newsletter', 'audiobook', 'read'],
    icon: Icons.auto_stories_outlined,
    tileColor: Color(0xFF6B9E7C),
    lightBg: Color(0xFFEAF3ED),
    lightFg: Color(0xFF2E593B),
    darkBg: Color(0xFF183D24),
    darkFg: Color(0xFFC2D9C8),
  ),
  'Health & Fitness': CategoryInfo(
    name: 'Health & Fitness',
    keywords: ['gym', 'workout', 'run', 'walk', 'yoga', 'meditate', 'stretch', 'fitness', 'exercise'],
    icon: Icons.fitness_center_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Side Projects': CategoryInfo(
    name: 'Side Projects',
    keywords: ['indie', 'startup', 'build', 'mvp', 'hackathon', 'side project', 'experiment'],
    icon: Icons.rocket_launch_outlined,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFFBE8E0),
    lightFg: Color(0xFF8A3015),
    darkBg: Color(0xFF5E200E),
    darkFg: Color(0xFFFDECE5),
  ),
  'Breaks': CategoryInfo(
    name: 'Breaks',
    keywords: ['break', 'relax', 'netflix', 'chill', 'coffee', 'tea', 'rest', 'play'],
    icon: Icons.coffee_rounded,
    tileColor: Color(0xFF423C38),
    lightBg: Color(0xFFE3DDD7),
    lightFg: Color(0xFF24201D),
    darkBg: Color(0xFF2A2522),
    darkFg: Color(0xFFEAE5E0),
  ),
};

const _defaultCategory = CategoryInfo(
  name: 'General',
  keywords: [],
  icon: Icons.circle_outlined,
  tileColor: Color(0xFF5E5854),
  lightBg: Color(0xFFE5DFD9),
  lightFg: Color(0xFF2C2825),
  darkBg: Color(0xFF3B3632),
  darkFg: Color(0xFFF0EBE6),
);

CategoryInfo getCategoryInfo(String? cat) {
  if (cat == null || cat.isEmpty) return _defaultCategory;
  final normalized = cat.toLowerCase().trim();
  for (final entry in kCategoryData.entries) {
    if (entry.key.toLowerCase() == normalized) return entry.value;
  }
  // Dynamic info for custom categories
  return CategoryInfo(
    name: cat,
    keywords: [],
    icon: Icons.label_outline_rounded,
    tileColor: DaylogColors.accent,
    lightBg: DaylogColors.accent100,
    lightFg: DaylogColors.accent800,
    darkBg: DaylogColors.darkAccent100,
    darkFg: DaylogColors.darkAccent800,
  );
}

Color categoryColor(String cat) => getCategoryInfo(cat).tileColor;

String capitalizeCategory(String cat) {
  if (cat.toLowerCase() == 'dsa') return 'DSA';
  if (cat.toLowerCase() == 'ai & data') return 'AI & Data';
  return cat.split(' ').map((word) {
    if (word.isEmpty) return '';
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}

// ── Theme Definitions ────────────────────────────────────────────────────────

final kLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: DaylogColors.accent,
    onPrimary: Colors.white,
    primaryContainer: DaylogColors.accent100,
    onPrimaryContainer: DaylogColors.accent800,
    secondary: DaylogColors.sage,
    onSecondary: Colors.white,
    secondaryContainer: DaylogColors.sage100,
    onSecondaryContainer: DaylogColors.sage800,
    surface: DaylogColors.lightSurface,
    surfaceContainer: DaylogColors.lightCard,
    outlineVariant: DaylogColors.lightDivider,
    onSurface: DaylogColors.lightText,
    onSurfaceVariant: Color(0xFF6B6560),
    outline: Color(0xFF9E958E),
    error: Color(0xFFC0392B),
  ),
  scaffoldBackgroundColor: DaylogColors.lightBg,
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: DaylogColors.lightBg,
    foregroundColor: DaylogColors.lightText,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: DaylogColors.lightBg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.bold,
      color: DaylogColors.lightText,
      letterSpacing: -0.3,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: DaylogColors.lightCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: DaylogColors.lightDivider, width: 1.0),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DaylogColors.lightSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DaylogColors.lightDivider, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DaylogColors.lightDivider, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DaylogColors.accent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
);

final kDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: DaylogColors.darkAccent,
    onPrimary: Colors.black,
    primaryContainer: DaylogColors.darkAccent100,
    onPrimaryContainer: DaylogColors.darkAccent800,
    secondary: DaylogColors.sage,
    onSecondary: Colors.white,
    secondaryContainer: DaylogColors.sage900,
    onSecondaryContainer: DaylogColors.sage200,
    surface: DaylogColors.darkSurface,
    surfaceContainer: DaylogColors.darkCard,
    outlineVariant: DaylogColors.darkDivider,
    onSurface: DaylogColors.darkText,
    onSurfaceVariant: Color(0xFFB0A8A0),
    outline: Color(0xFF6B6560),
    error: Color(0xFFE74C3C),
  ),
  scaffoldBackgroundColor: DaylogColors.darkBg,
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: DaylogColors.darkBg,
    foregroundColor: DaylogColors.darkText,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: DaylogColors.darkBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.bold,
      color: DaylogColors.darkText,
      letterSpacing: -0.3,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: DaylogColors.darkCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: DaylogColors.darkDivider, width: 1.0),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DaylogColors.darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DaylogColors.darkDivider, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DaylogColors.darkDivider, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: DaylogColors.darkAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
);
