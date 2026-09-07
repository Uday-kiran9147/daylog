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
  'UI/UX Design',
  'Writing & Docs',
  'Studying & Courses',
  'Fitness & Workout',
  'Admin & Ops',
];

const kCategories = [
  // Software & Tech
  'Development',
  'System Design',
  'DSA & Algorithms',
  'DevOps & Cloud',
  'AI & Data Science',
  'Mobile & App Dev',
  'Code Review & QA',
  // Design & Product
  'UI/UX Design',
  'Product Planning',
  'User Research',
  'Graphic & Brand',
  '3D & Animation',
  // Writing & Media
  'Writing & Docs',
  'Content Creation',
  'Video Editing',
  'Audio & Podcasting',
  'Scriptwriting',
  // Business & Career
  'Client Work',
  'Job Hunt & Prep',
  'Marketing & Growth',
  'Sales & Outreach',
  'Admin & Ops',
  'Meetings & Syncs',
  // Focus & Strategy
  'Deep Work',
  'Problem Solving',
  'Planning & Review',
  'Side Projects',
  'Quick Tasks',
  // Learning & Growth
  'Studying & Courses',
  'Reading & Books',
  'Academic Research',
  'Language Learning',
  'Skill Practice',
  // Health & Well-being
  'Fitness & Workout',
  'Meditation & Mind',
  'Health & Recovery',
  'Life Admin & Home',
  'Breaks & Rest',
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
    title: 'Focus & Strategy',
    icon: Icons.bolt_rounded,
    categories: ['Deep Work', 'Problem Solving', 'Planning & Review', 'Side Projects', 'Quick Tasks'],
  ),
  CategoryDomain(
    title: 'Software & Tech',
    icon: Icons.code_rounded,
    categories: [
      'Development',
      'System Design',
      'DSA & Algorithms',
      'DevOps & Cloud',
      'AI & Data Science',
      'Mobile & App Dev',
      'Code Review & QA',
    ],
  ),
  CategoryDomain(
    title: 'Design & Product',
    icon: Icons.palette_outlined,
    categories: ['UI/UX Design', 'Product Planning', 'User Research', 'Graphic & Brand', '3D & Animation'],
  ),
  CategoryDomain(
    title: 'Writing & Media',
    icon: Icons.drive_file_rename_outline_rounded,
    categories: ['Writing & Docs', 'Content Creation', 'Video Editing', 'Audio & Podcasting', 'Scriptwriting'],
  ),
  CategoryDomain(
    title: 'Business & Career',
    icon: Icons.business_center_outlined,
    categories: ['Client Work', 'Job Hunt & Prep', 'Marketing & Growth', 'Sales & Outreach', 'Admin & Ops', 'Meetings & Syncs'],
  ),
  CategoryDomain(
    title: 'Learning & Growth',
    icon: Icons.menu_book_rounded,
    categories: ['Studying & Courses', 'Reading & Books', 'Academic Research', 'Language Learning', 'Skill Practice'],
  ),
  CategoryDomain(
    title: 'Health & Well-being',
    icon: Icons.spa_outlined,
    categories: ['Fitness & Workout', 'Meditation & Mind', 'Health & Recovery', 'Life Admin & Home', 'Breaks & Rest'],
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
  // Software & Tech
  'Development': CategoryInfo(
    name: 'Development',
    keywords: ['code', 'debug', 'api', 'flutter', 'dart', 'react', 'python', 'javascript', 'rust', 'go', 'bug', 'server', 'git', 'frontend', 'backend'],
    icon: Icons.code_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFF8E4DC),
    lightFg: Color(0xFF7A280F),
    darkBg: Color(0xFF5A2210),
    darkFg: Color(0xFFF8E4DC),
  ),
  'System Design': CategoryInfo(
    name: 'System Design',
    keywords: ['architecture', 'scaling', 'redis', 'kafka', 'system design', 'scale', 'microservice', 'database', 'sql', 'nosql', 'caching'],
    icon: Icons.layers_rounded,
    tileColor: Color(0xFF5E5854),
    lightBg: Color(0xFFE5DFD9),
    lightFg: Color(0xFF2C2825),
    darkBg: Color(0xFF3B3632),
    darkFg: Color(0xFFF0EBE6),
  ),
  'DSA & Algorithms': CategoryInfo(
    name: 'DSA & Algorithms',
    keywords: ['dsa', 'algo', 'leetcode', 'tree', 'graph', 'array', 'sort', 'dp', 'algorithm', 'problem', 'dynamic programming', 'binary'],
    icon: Icons.hub_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'DSA': CategoryInfo(
    name: 'DSA & Algorithms',
    keywords: ['dsa', 'algo', 'leetcode', 'tree', 'graph', 'dp'],
    icon: Icons.hub_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'DevOps & Cloud': CategoryInfo(
    name: 'DevOps & Cloud',
    keywords: ['docker', 'kubernetes', 'k8s', 'aws', 'gcp', 'azure', 'ci/cd', 'cloud', 'deploy', 'terraform', 'pipeline', 'devops', 'helm'],
    icon: Icons.cloud_queue_rounded,
    tileColor: Color(0xFF386B8C),
    lightBg: Color(0xFFDFEAF0),
    lightFg: Color(0xFF143B52),
    darkBg: Color(0xFF123447),
    darkFg: Color(0xFFD4E6F0),
  ),
  'DevOps': CategoryInfo(
    name: 'DevOps & Cloud',
    keywords: ['docker', 'kubernetes', 'aws', 'ci/cd', 'cloud', 'deploy'],
    icon: Icons.cloud_queue_rounded,
    tileColor: Color(0xFF386B8C),
    lightBg: Color(0xFFDFEAF0),
    lightFg: Color(0xFF143B52),
    darkBg: Color(0xFF123447),
    darkFg: Color(0xFFD4E6F0),
  ),
  'AI & Data Science': CategoryInfo(
    name: 'AI & Data Science',
    keywords: ['ai', 'ml', 'data', 'prompt', 'llm', 'model', 'python', 'pytorch', 'machine learning', 'analytics', 'dataset', 'rag', 'openai'],
    icon: Icons.auto_awesome_rounded,
    tileColor: Color(0xFF7A4E8C),
    lightBg: Color(0xFFEFE4F5),
    lightFg: Color(0xFF482057),
    darkBg: Color(0xFF3D164D),
    darkFg: Color(0xFFEADBFA),
  ),
  'AI & Data': CategoryInfo(
    name: 'AI & Data Science',
    keywords: ['ai', 'ml', 'data', 'prompt', 'llm', 'model'],
    icon: Icons.auto_awesome_rounded,
    tileColor: Color(0xFF7A4E8C),
    lightBg: Color(0xFFEFE4F5),
    lightFg: Color(0xFF482057),
    darkBg: Color(0xFF3D164D),
    darkFg: Color(0xFFEADBFA),
  ),
  'Mobile & App Dev': CategoryInfo(
    name: 'Mobile & App Dev',
    keywords: ['ios', 'android', 'mobile', 'swift', 'swiftui', 'kotlin', 'compose', 'flutter', 'react native', 'app store'],
    icon: Icons.smartphone_rounded,
    tileColor: Color(0xFFB55D3A),
    lightBg: Color(0xFFF9EAE4),
    lightFg: Color(0xFF6B2B14),
    darkBg: Color(0xFF4A1806),
    darkFg: Color(0xFFF5D6CB),
  ),
  'Code Review & QA': CategoryInfo(
    name: 'Code Review & QA',
    keywords: ['review', 'pr', 'pull request', 'test', 'qa', 'testing', 'unit test', 'integration test', 'bugfix', 'audit'],
    icon: Icons.fact_check_outlined,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),

  // Design & Product
  'UI/UX Design': CategoryInfo(
    name: 'UI/UX Design',
    keywords: ['figma', 'ui/ux', 'ui', 'ux', 'wireframe', 'mockup', 'design', 'style', 'typography', 'prototype', 'interface', 'component'],
    icon: Icons.palette_outlined,
    tileColor: Color(0xFFE07A5F),
    lightBg: Color(0xFFFCEBE6),
    lightFg: Color(0xFFA83B19),
    darkBg: Color(0xFF4D1707),
    darkFg: Color(0xFFEDBFA8),
  ),
  'Design': CategoryInfo(
    name: 'UI/UX Design',
    keywords: ['figma', 'ui', 'ux', 'wireframe', 'design'],
    icon: Icons.palette_outlined,
    tileColor: Color(0xFFE07A5F),
    lightBg: Color(0xFFFCEBE6),
    lightFg: Color(0xFFA83B19),
    darkBg: Color(0xFF4D1707),
    darkFg: Color(0xFFEDBFA8),
  ),
  'Product Planning': CategoryInfo(
    name: 'Product Planning',
    keywords: ['roadmap', 'spec', 'prd', 'scrum', 'sprint', 'feature', 'planning', 'product', 'backlog', 'epic', 'user story'],
    icon: Icons.alt_route_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'User Research': CategoryInfo(
    name: 'User Research',
    keywords: ['research', 'benchmark', 'survey', 'user test', 'interview', 'whitepaper', 'competitor', 'usability', 'feedback', 'persona'],
    icon: Icons.travel_explore_rounded,
    tileColor: Color(0xFF5E5854),
    lightBg: Color(0xFFE5DFD9),
    lightFg: Color(0xFF2C2825),
    darkBg: Color(0xFF3B3632),
    darkFg: Color(0xFFF0EBE6),
  ),
  'Research': CategoryInfo(
    name: 'User Research',
    keywords: ['research', 'benchmark', 'survey'],
    icon: Icons.travel_explore_rounded,
    tileColor: Color(0xFF5E5854),
    lightBg: Color(0xFFE5DFD9),
    lightFg: Color(0xFF2C2825),
    darkBg: Color(0xFF3B3632),
    darkFg: Color(0xFFF0EBE6),
  ),
  'Graphic & Brand': CategoryInfo(
    name: 'Graphic & Brand',
    keywords: ['logo', 'brand', 'vector', 'illustration', 'poster', 'banner', 'typography', 'visual', 'graphic'],
    icon: Icons.brush_outlined,
    tileColor: Color(0xFF9E654A),
    lightBg: Color(0xFFF5EAE4),
    lightFg: Color(0xFF542C18),
    darkBg: Color(0xFF3D1B0B),
    darkFg: Color(0xFFFAEEE8),
  ),
  'Creative': CategoryInfo(
    name: 'Graphic & Brand',
    keywords: ['art', 'draw', 'illustration'],
    icon: Icons.brush_outlined,
    tileColor: Color(0xFF9E654A),
    lightBg: Color(0xFFF5EAE4),
    lightFg: Color(0xFF542C18),
    darkBg: Color(0xFF3D1B0B),
    darkFg: Color(0xFFFAEEE8),
  ),
  '3D & Animation': CategoryInfo(
    name: '3D & Animation',
    keywords: ['3d', 'blender', 'render', 'animation', 'motion', 'cinema4d', 'maya', 'rigging', 'modeling'],
    icon: Icons.view_in_ar_rounded,
    tileColor: Color(0xFF7D5A8C),
    lightBg: Color(0xFFF2EAF7),
    lightFg: Color(0xFF452254),
    darkBg: Color(0xFF351242),
    darkFg: Color(0xFFEADBFA),
  ),

  // Writing & Media
  'Writing & Docs': CategoryInfo(
    name: 'Writing & Docs',
    keywords: ['write', 'draft', 'article', 'essay', 'documentation', 'copy', 'journal', 'doc', 'readme', 'blog', 'notion'],
    icon: Icons.drive_file_rename_outline_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Writing': CategoryInfo(
    name: 'Writing & Docs',
    keywords: ['write', 'draft', 'article', 'essay', 'documentation'],
    icon: Icons.drive_file_rename_outline_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Content Creation': CategoryInfo(
    name: 'Content Creation',
    keywords: ['blog', 'video', 'content', 'post', 'script', 'youtube', 'podcast', 'social', 'x', 'tweet', 'linkedin', 'newsletter', 'threads'],
    icon: Icons.edit_note_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Content': CategoryInfo(
    name: 'Content Creation',
    keywords: ['blog', 'content', 'post', 'tweet'],
    icon: Icons.edit_note_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Video Editing': CategoryInfo(
    name: 'Video Editing',
    keywords: ['video', 'edit', 'record', 'camera', 'premiere', 'youtube', 'davinci', 'capcut', 'footage', 'reels', 'tiktok'],
    icon: Icons.movie_outlined,
    tileColor: Color(0xFF944B36),
    lightBg: Color(0xFFF5E4E0),
    lightFg: Color(0xFF5E1E10),
    darkBg: Color(0xFF471308),
    darkFg: Color(0xFFFCEBE8),
  ),
  'Audio & Video': CategoryInfo(
    name: 'Video Editing',
    keywords: ['audio', 'video', 'edit'],
    icon: Icons.movie_outlined,
    tileColor: Color(0xFF944B36),
    lightBg: Color(0xFFF5E4E0),
    lightFg: Color(0xFF5E1E10),
    darkBg: Color(0xFF471308),
    darkFg: Color(0xFFFCEBE8),
  ),
  'Audio & Podcasting': CategoryInfo(
    name: 'Audio & Podcasting',
    keywords: ['audio', 'podcast', 'mic', 'record', 'music', 'sound', 'mix', 'master', 'audition', 'voiceover'],
    icon: Icons.mic_none_rounded,
    tileColor: Color(0xFF8C5338),
    lightBg: Color(0xFFF5E8E2),
    lightFg: Color(0xFF4F2310),
    darkBg: Color(0xFF3D1606),
    darkFg: Color(0xFFF2DDD4),
  ),
  'Scriptwriting': CategoryInfo(
    name: 'Scriptwriting',
    keywords: ['script', 'storyboard', 'screenplay', 'scene', 'dialogue', 'story', 'narrative', 'outline'],
    icon: Icons.history_edu_rounded,
    tileColor: Color(0xFF6B584E),
    lightBg: Color(0xFFEBE6E2),
    lightFg: Color(0xFF382C24),
    darkBg: Color(0xFF2B2019),
    darkFg: Color(0xFFE6DED8),
  ),

  // Business & Career
  'Client Work': CategoryInfo(
    name: 'Client Work',
    keywords: ['client', 'freelance', 'proposal', 'consulting', 'contract', 'customer', 'deliverable', 'invoice', 'scope'],
    icon: Icons.handshake_outlined,
    tileColor: Color(0xFF3B6748),
    lightBg: Color(0xFFDFF0E4),
    lightFg: Color(0xFF143D1F),
    darkBg: Color(0xFF103319),
    darkFg: Color(0xFFDCF2E2),
  ),
  'Job Hunt & Prep': CategoryInfo(
    name: 'Job Hunt & Prep',
    keywords: ['interview', 'resume', 'application', 'job', 'career', 'hr', 'recruiter', 'linkedin', 'cv', 'offer'],
    icon: Icons.work_outline_rounded,
    tileColor: Color(0xFF7D7570),
    lightBg: Color(0xFFEDE8E3),
    lightFg: Color(0xFF3D3734),
    darkBg: Color(0xFF332D2A),
    darkFg: Color(0xFFE5DFD9),
  ),
  'Job Hunt': CategoryInfo(
    name: 'Job Hunt & Prep',
    keywords: ['interview', 'resume', 'application', 'job'],
    icon: Icons.work_outline_rounded,
    tileColor: Color(0xFF7D7570),
    lightBg: Color(0xFFEDE8E3),
    lightFg: Color(0xFF3D3734),
    darkBg: Color(0xFF332D2A),
    darkFg: Color(0xFFE5DFD9),
  ),
  'Marketing & Growth': CategoryInfo(
    name: 'Marketing & Growth',
    keywords: ['growth', 'marketing', 'seo', 'ads', 'launch', 'traffic', 'conversion', 'campaign', 'funnel', 'analytics'],
    icon: Icons.trending_up_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFF8E4DC),
    lightFg: Color(0xFF7A280F),
    darkBg: Color(0xFF5A2210),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Marketing': CategoryInfo(
    name: 'Marketing & Growth',
    keywords: ['growth', 'marketing', 'seo', 'ads'],
    icon: Icons.trending_up_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFF8E4DC),
    lightFg: Color(0xFF7A280F),
    darkBg: Color(0xFF5A2210),
    darkFg: Color(0xFFF8E4DC),
  ),
  'Sales & Outreach': CategoryInfo(
    name: 'Sales & Outreach',
    keywords: ['sales', 'outreach', 'cold email', 'pitch', 'lead', 'prospect', 'demo', 'closing', 'deal', 'crm'],
    icon: Icons.connect_without_contact_rounded,
    tileColor: Color(0xFF8F583B),
    lightBg: Color(0xFFF5EAE4),
    lightFg: Color(0xFF542914),
    darkBg: Color(0xFF421B08),
    darkFg: Color(0xFFF5D6C6),
  ),
  'Admin & Ops': CategoryInfo(
    name: 'Admin & Ops',
    keywords: ['email', 'admin', 'invoice', 'paperwork', 'taxes', 'sync', 'bills', 'organize', 'operations', 'receipts'],
    icon: Icons.mail_outline_rounded,
    tileColor: Color(0xFF3D8B6E),
    lightBg: Color(0xFFE0F0E9),
    lightFg: Color(0xFF134833),
    darkBg: Color(0xFF0F3B29),
    darkFg: Color(0xFFD4EFE3),
  ),
  'Admin': CategoryInfo(
    name: 'Admin & Ops',
    keywords: ['email', 'admin', 'invoice', 'taxes'],
    icon: Icons.mail_outline_rounded,
    tileColor: Color(0xFF3D8B6E),
    lightBg: Color(0xFFE0F0E9),
    lightFg: Color(0xFF134833),
    darkBg: Color(0xFF0F3B29),
    darkFg: Color(0xFFD4EFE3),
  ),
  'Meetings & Syncs': CategoryInfo(
    name: 'Meetings & Syncs',
    keywords: ['meeting', 'sync', '1on1', 'call', 'zoom', 'standup', 'huddle', 'catchup', 'discussion'],
    icon: Icons.groups_outlined,
    tileColor: Color(0xFF5C6878),
    lightBg: Color(0xFFE4E9F0),
    lightFg: Color(0xFF223042),
    darkBg: Color(0xFF172433),
    darkFg: Color(0xFFD2DCE8),
  ),

  // Focus & Strategy
  'Deep Work': CategoryInfo(
    name: 'Deep Work',
    keywords: ['focus', 'deep work', 'flow', 'core', 'priority', 'strategy', 'thinking', 'session', 'zone'],
    icon: Icons.bolt_rounded,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFFBE8E0),
    lightFg: Color(0xFF8A3015),
    darkBg: Color(0xFF5E200E),
    darkFg: Color(0xFFFDECE5),
  ),
  'Problem Solving': CategoryInfo(
    name: 'Problem Solving',
    keywords: ['problem', 'logic', 'puzzle', 'debug', 'root cause', 'analysis', 'troubleshoot', 'solve'],
    icon: Icons.psychology_rounded,
    tileColor: Color(0xFF6E5280),
    lightBg: Color(0xFFEEE7F2),
    lightFg: Color(0xFF3F2552),
    darkBg: Color(0xFF2F1640),
    darkFg: Color(0xFFE3D4EB),
  ),
  'Planning & Review': CategoryInfo(
    name: 'Planning & Review',
    keywords: ['plan', 'review', 'schedule', 'weekly review', 'daily plan', 'organize', 'goals', 'target', 'reflection'],
    icon: Icons.event_note_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Side Projects': CategoryInfo(
    name: 'Side Projects',
    keywords: ['indie', 'startup', 'build', 'mvp', 'hackathon', 'side project', 'experiment', 'passion project'],
    icon: Icons.rocket_launch_outlined,
    tileColor: Color(0xFFC85A32),
    lightBg: Color(0xFFFBE8E0),
    lightFg: Color(0xFF8A3015),
    darkBg: Color(0xFF5E200E),
    darkFg: Color(0xFFFDECE5),
  ),
  'Quick Tasks': CategoryInfo(
    name: 'Quick Tasks',
    keywords: ['quick', 'chore', 'errand', 'small', 'fast', 'inbox zero', 'cleanup', 'task'],
    icon: Icons.flash_on_rounded,
    tileColor: Color(0xFFD48344),
    lightBg: Color(0xFFFBEAD8),
    lightFg: Color(0xFF6B3308),
    darkBg: Color(0xFF4A2003),
    darkFg: Color(0xFFF8E4DC),
  ),

  // Learning & Growth
  'Studying & Courses': CategoryInfo(
    name: 'Studying & Courses',
    keywords: ['study', 'course', 'lecture', 'tutorial', 'exam', 'homework', 'mooc', 'cert', 'revision', 'flashcards'],
    icon: Icons.menu_book_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Learning': CategoryInfo(
    name: 'Studying & Courses',
    keywords: ['study', 'course', 'learn', 'tutorial'],
    icon: Icons.menu_book_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Reading & Books': CategoryInfo(
    name: 'Reading & Books',
    keywords: ['reading', 'book', 'kindle', 'novel', 'audiobook', 'read', 'literature', 'nonfiction', 'summary'],
    icon: Icons.auto_stories_outlined,
    tileColor: Color(0xFF6B9E7C),
    lightBg: Color(0xFFEAF3ED),
    lightFg: Color(0xFF2E593B),
    darkBg: Color(0xFF183D24),
    darkFg: Color(0xFFC2D9C8),
  ),
  'Reading': CategoryInfo(
    name: 'Reading & Books',
    keywords: ['reading', 'kindle', 'novel', 'audiobook', 'read'],
    icon: Icons.auto_stories_outlined,
    tileColor: Color(0xFF6B9E7C),
    lightBg: Color(0xFFEAF3ED),
    lightFg: Color(0xFF2E593B),
    darkBg: Color(0xFF183D24),
    darkFg: Color(0xFFC2D9C8),
  ),
  'Academic Research': CategoryInfo(
    name: 'Academic Research',
    keywords: ['paper', 'thesis', 'citations', 'experiment', 'academic', 'journal', 'arxiv', 'hypothesis', 'dissertation'],
    icon: Icons.science_outlined,
    tileColor: Color(0xFF476985),
    lightBg: Color(0xFFE3EDF5),
    lightFg: Color(0xFF183852),
    darkBg: Color(0xFF12283B),
    darkFg: Color(0xFFD2E3F0),
  ),
  'Language Learning': CategoryInfo(
    name: 'Language Learning',
    keywords: ['language', 'duolingo', 'vocab', 'grammar', 'anki', 'speaking', 'japanese', 'spanish', 'french', 'german'],
    icon: Icons.translate_rounded,
    tileColor: Color(0xFF8A624A),
    lightBg: Color(0xFFF2EAE4),
    lightFg: Color(0xFF4F2C17),
    darkBg: Color(0xFF381B09),
    darkFg: Color(0xFFEBD8CE),
  ),
  'Skill Practice': CategoryInfo(
    name: 'Skill Practice',
    keywords: ['practice', 'drill', 'instrument', 'guitar', 'piano', 'chess', 'typing', 'speed', 'technique'],
    icon: Icons.sports_esports_outlined,
    tileColor: Color(0xFF7A685A),
    lightBg: Color(0xFFEFECE8),
    lightFg: Color(0xFF3E3025),
    darkBg: Color(0xFF2B2017),
    darkFg: Color(0xFFE3DDD6),
  ),

  // Health & Well-being
  'Fitness & Workout': CategoryInfo(
    name: 'Fitness & Workout',
    keywords: ['gym', 'workout', 'run', 'lifting', 'cardio', 'yoga', 'stretch', 'fitness', 'exercise', 'cycling', 'swimming'],
    icon: Icons.fitness_center_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Health & Fitness': CategoryInfo(
    name: 'Fitness & Workout',
    keywords: ['gym', 'workout', 'run', 'walk', 'yoga', 'fitness'],
    icon: Icons.fitness_center_rounded,
    tileColor: Color(0xFF4A7C59),
    lightBg: Color(0xFFE2ECE5),
    lightFg: Color(0xFF1E3D27),
    darkBg: Color(0xFF1D4528),
    darkFg: Color(0xFFE2ECE5),
  ),
  'Meditation & Mind': CategoryInfo(
    name: 'Meditation & Mind',
    keywords: ['meditate', 'mindfulness', 'breathwork', 'reflection', 'journal', 'calm', 'zen', 'mental health'],
    icon: Icons.spa_outlined,
    tileColor: Color(0xFF5E8270),
    lightBg: Color(0xFFE8F2EC),
    lightFg: Color(0xFF214533),
    darkBg: Color(0xFF163325),
    darkFg: Color(0xFFD1E8DC),
  ),
  'Health & Recovery': CategoryInfo(
    name: 'Health & Recovery',
    keywords: ['health', 'nutrition', 'sleep', 'walk', 'recovery', 'doctor', 'therapy', 'hydration', 'vitamins'],
    icon: Icons.favorite_outline_rounded,
    tileColor: Color(0xFF9E4E42),
    lightBg: Color(0xFFF7E6E4),
    lightFg: Color(0xFF611C12),
    darkBg: Color(0xFF4A1008),
    darkFg: Color(0xFFF7D5D0),
  ),
  'Life Admin & Home': CategoryInfo(
    name: 'Life Admin & Home',
    keywords: ['errand', 'groceries', 'cleaning', 'cooking', 'household', 'organize', 'chores', 'bills', 'maintenance'],
    icon: Icons.check_box_outlined,
    tileColor: Color(0xFF706760),
    lightBg: Color(0xFFEDE9E5),
    lightFg: Color(0xFF38312B),
    darkBg: Color(0xFF29231E),
    darkFg: Color(0xFFE5DFD9),
  ),
  'Breaks & Rest': CategoryInfo(
    name: 'Breaks & Rest',
    keywords: ['break', 'relax', 'netflix', 'chill', 'coffee', 'tea', 'rest', 'play', 'recharge', 'nap', 'pause'],
    icon: Icons.coffee_rounded,
    tileColor: Color(0xFF423C38),
    lightBg: Color(0xFFE3DDD7),
    lightFg: Color(0xFF24201D),
    darkBg: Color(0xFF2A2522),
    darkFg: Color(0xFFEAE5E0),
  ),
  'Breaks': CategoryInfo(
    name: 'Breaks & Rest',
    keywords: ['break', 'relax', 'coffee', 'rest'],
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
  final l = cat.toLowerCase().trim();
  if (l == 'dsa' || l == 'dsa & algorithms') return 'DSA & Algorithms';
  if (l == 'ui/ux' || l == 'ui/ux design') return 'UI/UX Design';
  if (l == 'ai & data' || l == 'ai & data science') return 'AI & Data Science';
  if (l == 'code review & qa') return 'Code Review & QA';
  if (l == '3d & animation') return '3D & Animation';
  return cat.split(' ').map((word) {
    if (word.isEmpty) return '';
    if (word.contains('&')) {
      return word.split('&').map((sub) => sub.isEmpty ? '' : '${sub[0].toUpperCase()}${sub.substring(1)}').join('&');
    }
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
