// lib/screens/onboarding/onboarding_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_settings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/daylog_widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 6;

  // Selected categories and goals state for onboarding
  late Set<String> _selectedCategories;
  double _dailyGoalHours = 4.0;
  bool _eveningReminder = true;

  final List<_FeatureSlideData> _slides = const [
    _FeatureSlideData(
      imagePath: 'assets/images/zero-friction-focus-timer-v1.png',
      badge: '⏱️ · FOCUS SESSIONS',
      badgeTag: 'Live Focus',
      badgeIcon: Icons.timer_outlined,
      title: 'Zero-Friction\nFocus Timer',
      description:
          'Enter effortless flow state with 1-tap live timers, smart category detection, and gentle background tracking.',
      highlights: [
        _HighlightItem(icon: Icons.bolt_rounded, label: '1-Tap Quick Start'),
        _HighlightItem(icon: Icons.category_rounded, label: 'Smart Tagging'),
        _HighlightItem(icon: Icons.notifications_active_outlined, label: 'Background Ping'),
      ],
      accentGlow: DaylogColors.accent,
    ),
    _FeatureSlideData(
      imagePath: 'assets/images/action-items-priorities-v1.png',
      badge: '🎯 · TASK MASTERY',
      badgeTag: "Today's Queue",
      badgeIcon: Icons.check_circle_outline_rounded,
      title: 'Action Items\n& Priorities',
      description:
          'Turn ambitious plans into structured daily progress with color-coded priority flags and smart due dates.',
      highlights: [
        _HighlightItem(icon: Icons.flag_rounded, label: 'High / Med / Low Flags'),
        _HighlightItem(icon: Icons.event_note_rounded, label: 'Smart Due Dates'),
        _HighlightItem(icon: Icons.add_task_rounded, label: 'Quick Todo Inbox'),
      ],
      accentGlow: Color(0xFFD48344),
    ),
    _FeatureSlideData(
      imagePath: 'assets/images/deep-work-insights-v1.png',
      badge: '📊 · DEEP ANALYTICS',
      badgeTag: 'Weekly Trends',
      badgeIcon: Icons.bar_chart_rounded,
      title: 'Deep Work\nInsights',
      description:
          'Understand exactly where your focus hours go with weekly category breakdowns, streak metrics, and goal meters.',
      highlights: [
        _HighlightItem(icon: Icons.pie_chart_outline_rounded, label: 'Category Mix'),
        _HighlightItem(icon: Icons.local_fire_department_rounded, label: 'Streak Tracking'),
        _HighlightItem(icon: Icons.track_changes_rounded, label: 'Daily Goal Meters'),
      ],
      accentGlow: Color(0xFF386B8C),
    ),
    _FeatureSlideData(
      imagePath: 'assets/images/daily-evening-reflection-v1.png',
      badge: '🌙 · MINDFUL JOURNAL',
      badgeTag: '9:00 PM Review',
      badgeIcon: Icons.auto_stories_outlined,
      title: 'Daily Evening\nReflection',
      description:
          'Close every day with mental clarity using a guided 4-question review to celebrate wins, learn, and plan tomorrow.',
      highlights: [
        _HighlightItem(icon: Icons.menu_book_rounded, label: '4 Guided Prompts'),
        _HighlightItem(icon: Icons.emoji_events_outlined, label: 'Celebrate Wins'),
        _HighlightItem(icon: Icons.wb_sunny_outlined, label: 'Tomorrow’s Focus'),
      ],
      accentGlow: Color(0xFF4A7C59),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(kDefaultUserCategories);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final list = _selectedCategories.toList();
    await ref.read(userSettingsProvider.notifier).completeOnboarding(
      selectedCategories: list.isNotEmpty ? list : kDefaultUserCategories,
      dailyGoalHours: _dailyGoalHours,
    );
  }

  void _showAddCustomCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Category', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Mobile Apps, Guitar, Research',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(userSettingsProvider.notifier).addCustomCategory(name);
                setState(() => _selectedCategories.add(name));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Color _getActiveAccentGlow() {
    if (_currentPage < _slides.length) {
      return _slides[_currentPage].accentGlow;
    }
    return DaylogColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGlow = _getActiveAccentGlow();
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Ambient Glowing Halos (Liquid Glass Effect) ────────
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeGlow.withValues(alpha: isDark ? 0.22 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                        .withValues(alpha: isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content Area ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Floating Liquid Glass Top Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                  child: _LiquidGlassHeader(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onSkip: _finishOnboarding,
                  ),
                ),

                // 6 Sequential Walkthrough Pages (4 Feature Slides + Categories + Goal Target)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      // Slide 1: Zero-Friction Focus Timer
                      _FeatureSlideView(slide: _slides[0]),
                      // Slide 2: Action Items & Priorities
                      _FeatureSlideView(slide: _slides[1]),
                      // Slide 3: Deep Work Insights
                      _FeatureSlideView(slide: _slides[2]),
                      // Slide 4: Daily Evening Reflection
                      _FeatureSlideView(slide: _slides[3]),
                      // Slide 5: Full Category Selection (as originally implemented)
                      _CategoryPickerPage(
                        selectedCategories: _selectedCategories,
                        onToggleCategory: (cat) {
                          setState(() {
                            if (_selectedCategories.contains(cat)) {
                              if (_selectedCategories.length > 1) {
                                _selectedCategories.remove(cat);
                              }
                            } else {
                              _selectedCategories.add(cat);
                            }
                          });
                        },
                        onApplyPreset: (categories) {
                          setState(() {
                            _selectedCategories = Set.from(categories);
                          });
                        },
                        onAddCustom: _showAddCustomCategoryDialog,
                      ),
                      // Slide 6: Goal Setting & Evening Reminder (as originally implemented)
                      _GoalSettingPage(
                        dailyGoalHours: _dailyGoalHours,
                        onGoalChanged: (val) => setState(() => _dailyGoalHours = val),
                        eveningReminder: _eveningReminder,
                        onReminderChanged: (val) => setState(() => _eveningReminder = val),
                      ),
                    ],
                  ),
                ),

                // Space for floating liquid bottom dock
                const SizedBox(height: 104),
              ],
            ),
          ),

          // ── Floating Liquid Glass Bottom Navigation Dock ──────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _LiquidGlassBottomDock(
              currentPage: _currentPage,
              totalPages: _totalPages,
              accentGlow: activeGlow,
              buttonLabel: isLastPage ? 'Start Tracking' : 'Continue',
              isButtonEnabled: _currentPage != 4 || _selectedCategories.isNotEmpty,
              onPrev: _currentPage > 0 ? _prevPage : null,
              onNext: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Data Model for Feature Slides ───────────────────────────────────────────
class _FeatureSlideData {
  final String imagePath;
  final String badge;
  final String badgeTag;
  final IconData badgeIcon;
  final String title;
  final String description;
  final List<_HighlightItem> highlights;
  final Color accentGlow;

  const _FeatureSlideData({
    required this.imagePath,
    required this.badge,
    required this.badgeTag,
    required this.badgeIcon,
    required this.title,
    required this.description,
    required this.highlights,
    required this.accentGlow,
  });
}

class _HighlightItem {
  final IconData icon;
  final String label;

  const _HighlightItem({required this.icon, required this.label});
}

/// ── Individual Feature Slide Layout ─────────────────────────────────────────
class _FeatureSlideView extends StatelessWidget {
  final _FeatureSlideData slide;

  const _FeatureSlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),

          // ── Hero Liquid Glass Image Card ──────────────────────────────────
          _LiquidGlassImageCard(
            imagePath: slide.imagePath,
            badgeTag: slide.badgeTag,
            badgeIcon: slide.badgeIcon,
            accentGlow: slide.accentGlow,
          ),

          const SizedBox(height: 20),

          // ── Feature Pillar Tag Pill ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF2E2A28) : Colors.white)
                  .withValues(alpha: isDark ? 0.70 : 0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: slide.accentGlow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  slide.badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? DaylogColors.darkText : DaylogColors.lightText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Headline ──────────────────────────────────────────────────────
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.18,
              letterSpacing: -0.6,
            ),
          ),

          const SizedBox(height: 10),

          // ── Body Description ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
                height: 1.42,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Feature Micro-Highlight Glass Chips ───────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: slide.highlights.map((h) {
              return _LiquidHighlightChip(item: h);
            }).toList(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// ── Hero Image with Liquid Glass Aesthetics ─────────────────────────────────
class _LiquidGlassImageCard extends StatelessWidget {
  final String imagePath;
  final String badgeTag;
  final IconData badgeIcon;
  final Color accentGlow;

  const _LiquidGlassImageCard({
    required this.imagePath,
    required this.badgeTag,
    required this.badgeIcon,
    required this.accentGlow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = (screenHeight * 0.38).clamp(240.0, 360.0);

    return Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentGlow.withValues(alpha: isDark ? 0.28 : 0.15),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Glass backdrop background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF221F1D) : const Color(0xFFFFFDFC))
                      .withValues(alpha: isDark ? 0.88 : 0.94),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.92),
                    width: 1.4,
                  ),
                ),
              ),
            ),

            // The Illustration Asset
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          badgeIcon,
                          size: 64,
                          color: accentGlow.withValues(alpha: 0.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Top-right floating liquid glass pill badge
            Positioned(
              top: 14,
              right: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white)
                          .withValues(alpha: isDark ? 0.60 : 0.75),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeIcon,
                          size: 13,
                          color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          badgeTag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Highlight Micro-Chip (Liquid Glass Style) ───────────────────────────────
class _LiquidHighlightChip extends StatelessWidget {
  final _HighlightItem item;

  const _LiquidHighlightChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF262321) : Colors.white)
            .withValues(alpha: isDark ? 0.65 : 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.05),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 13,
            color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Page 5: Category Picker (Preserved exactly as originally designed) ───────
class _CategoryPickerPage extends ConsumerStatefulWidget {
  final Set<String> selectedCategories;
  final ValueChanged<String> onToggleCategory;
  final ValueChanged<List<String>> onApplyPreset;
  final VoidCallback onAddCustom;

  const _CategoryPickerPage({
    required this.selectedCategories,
    required this.onToggleCategory,
    required this.onApplyPreset,
    required this.onAddCustom,
  });

  @override
  ConsumerState<_CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends ConsumerState<_CategoryPickerPage> {
  String _searchQuery = '';
  String _selectedDomain = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allCategories = ref.watch(allAvailableCategoriesProvider);

    final isSearching = _searchQuery.isNotEmpty;
    final filteredCategories = allCategories.where((cat) {
      if (isSearching && !cat.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedDomain != 'All') {
        final domain = kCategoryDomains.firstWhere((d) => d.title == _selectedDomain, orElse: () => kCategoryDomains.first);
        if (!domain.categories.contains(cat)) return false;
      }
      return true;
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Text(
          'What do you track?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose your core productivity categories. You can tap chips to toggle them or pick a quick starter preset.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // ── Quick Starter Presets Bar ─────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _PresetChip(
                label: '💻 Developer',
                onTap: () => widget.onApplyPreset([
                  'Development',
                  'System Design',
                  'DSA & Algorithms',
                  'DevOps & Cloud',
                  'Deep Work',
                  'Code Review & QA',
                ]),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '🎨 Designer',
                onTap: () => widget.onApplyPreset([
                  'UI/UX Design',
                  'Product Planning',
                  'User Research',
                  'Graphic & Brand',
                  'Deep Work',
                  'Client Work',
                ]),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '✍️ Creator / Writer',
                onTap: () => widget.onApplyPreset([
                  'Writing & Docs',
                  'Content Creation',
                  'Video Editing',
                  'Audio & Podcasting',
                  'Deep Work',
                  'Marketing & Growth',
                ]),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '💼 Founder / Ops',
                onTap: () => widget.onApplyPreset([
                  'Side Projects',
                  'Client Work',
                  'Product Planning',
                  'Marketing & Growth',
                  'Sales & Outreach',
                  'Admin & Ops',
                ]),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '📚 Student / Scholar',
                onTap: () => widget.onApplyPreset([
                  'Studying & Courses',
                  'Reading & Books',
                  'Academic Research',
                  'Deep Work',
                  'Language Learning',
                ]),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '🌿 Balanced Flow',
                onTap: () => widget.onApplyPreset([
                  'Deep Work',
                  'Writing & Docs',
                  'Fitness & Workout',
                  'Meditation & Mind',
                  'Reading & Books',
                  'Side Projects',
                ]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Search Field & Custom Category Button ─────────────────────────────
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search categories or keywords...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: widget.onAddCustom,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : theme.colorScheme.outlineVariant,
                ),
                backgroundColor: theme.cardTheme.color,
                foregroundColor: theme.colorScheme.onSurface,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Custom', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Domain Filter Tabs ────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _DomainTab(
                label: 'All Domains',
                isSelected: _selectedDomain == 'All',
                onTap: () => setState(() => _selectedDomain = 'All'),
              ),
              ...kCategoryDomains.map((d) => _DomainTab(
                    label: d.title,
                    icon: d.icon,
                    isSelected: _selectedDomain == d.title,
                    onTap: () => setState(() => _selectedDomain = d.title),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Active Counter & Hint ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.selectedCategories.isNotEmpty
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.selectedCategories.length} categories active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                'Tap chip to toggle',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── CATEGORY CHIPS RENDERING ──────────────────────────────────────────
        if (isSearching || _selectedDomain != 'All') ...[
          if (filteredCategories.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 36, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 10),
                  Text(
                    'No category found matching "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: widget.onAddCustom,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text('Create "$_searchQuery"', style: const TextStyle(fontSize: 12.5)),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: filteredCategories.map((cat) {
                final isSelected = widget.selectedCategories.contains(cat);
                return _SelectableCategoryChip(
                  category: cat,
                  isSelected: isSelected,
                  onTap: () => widget.onToggleCategory(cat),
                );
              }).toList(),
            ),
        ] else ...[
          // Grouped by Domain Sections for effortless discovery
          ...kCategoryDomains.map((domain) {
            final domainCats = domain.categories.where((c) => allCategories.contains(c)).toList();
            if (domainCats.isEmpty) return const SizedBox.shrink();

            final selectedCountInDomain = domainCats.where((c) => widget.selectedCategories.contains(c)).length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain Section Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 2),
                    child: Row(
                      children: [
                        Icon(
                          domain.icon,
                          size: 15,
                          color: theme.colorScheme.primary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          domain.title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (selectedCountInDomain > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$selectedCountInDomain/${domainCats.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Domain Chips Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: domainCats.map((cat) {
                      final isSelected = widget.selectedCategories.contains(cat);
                      return _SelectableCategoryChip(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () => widget.onToggleCategory(cat),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),

          // User-created Custom Categories (if any)
          if (allCategories.any((c) => !kCategories.contains(c))) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.label_outline_rounded,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Custom Categories',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: allCategories.where((c) => !kCategories.contains(c)).map((cat) {
                      final isSelected = widget.selectedCategories.contains(cat);
                      return _SelectableCategoryChip(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () => widget.onToggleCategory(cat),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],

        const SizedBox(height: 20),
      ],
    );
  }
}

/// Frosted Specular Selectable Category Chip
class _SelectableCategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final info = getCategoryInfo(category);

    final selectedBg = isDark ? info.darkBg : info.lightBg;
    final selectedFg = isDark ? info.darkFg : info.lightFg;
    final selectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.28)
        : info.tileColor.withValues(alpha: 0.45);

    final unselectedBg = theme.cardTheme.color ?? (isDark ? DaylogColors.darkCard : DaylogColors.lightCard);
    final unselectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.85);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? selectedBorder : unselectedBorder,
              width: isSelected ? 1.2 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: info.tileColor.withValues(alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Icon
              Icon(
                info.icon,
                size: 15,
                color: isSelected
                    ? selectedFg
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 7),

              // Category Label
              Text(
                capitalizeCategory(category),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? selectedFg : theme.colorScheme.onSurface,
                  letterSpacing: -0.1,
                ),
              ),

              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: selectedFg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2825) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : theme.colorScheme.outlineVariant,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DomainTab extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DomainTab({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? DaylogColors.darkAccent : theme.colorScheme.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Page 6: Goal & Preferences (Preserved exactly as originally designed) ────
class _GoalSettingPage extends StatelessWidget {
  final double dailyGoalHours;
  final ValueChanged<double> onGoalChanged;
  final bool eveningReminder;
  final ValueChanged<bool> onReminderChanged;

  const _GoalSettingPage({
    required this.dailyGoalHours,
    required this.onGoalChanged,
    required this.eveningReminder,
    required this.onReminderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final goals = [2.0, 3.0, 4.0, 6.0, 8.0];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_rounded,
              size: 34,
              color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Daily Focus Target',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'How many hours of focused work do you strive for each day?',
          style: TextStyle(
            fontSize: 13.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 28),

        // Big numeric target indicator
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              '${dailyGoalHours.toStringAsFixed(0)} hours / day',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Goal Selection Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: goals.map((g) {
            final isSelected = dailyGoalHours == g;
            return InkWell(
              onTap: () => onGoalChanged(g),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  '${g.toInt()} hrs${g == 4.0 ? ' · Ideal' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 36),

        // Reflection Reminder Preference Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  size: 20,
                  color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily 9:00 PM Reflection',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gentle reminder to fill out your 4-question evening journal.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              DaylogSwitch(
                value: eveningReminder,
                onChanged: onReminderChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// ── Liquid Glass Top Status Header ──────────────────────────────────────────
class _LiquidGlassHeader extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  const _LiquidGlassHeader({
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = currentPage == totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo Mark Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF24201E) : Colors.white)
                .withValues(alpha: isDark ? 0.70 : 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.85),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                size: 15,
                color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'DayLog',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Slide Step Pill Indicator (e.g. 01 / 06)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            '0${currentPage + 1} / 0$totalPages',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),

        // Skip Button
        AnimatedOpacity(
          opacity: isLastPage ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: isLastPage,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSkip,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ── Floating Liquid Glass Bottom Navigation Dock ────────────────────────────
class _LiquidGlassBottomDock extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color accentGlow;
  final String buttonLabel;
  final bool isButtonEnabled;
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  const _LiquidGlassBottomDock({
    required this.currentPage,
    required this.totalPages,
    required this.accentGlow,
    required this.buttonLabel,
    this.isButtonEnabled = true,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = currentPage == totalPages - 1;

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Atmospheric ambient glow behind the dock
            Positioned(
              bottom: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 220,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: accentGlow.withValues(alpha: isDark ? 0.35 : 0.22),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // Frosted Main Glass Dock Container
            Container(
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E1C1A) : const Color(0xFFFFF9F0))
                    .withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.90),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Progress Worm Dots (6 dots)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(totalPages, (index) {
                            final isActive = index == currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 3.5),
                              width: isActive ? 22 : 7,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : (isDark
                                        ? const Color(0xFF423C38)
                                        : const Color(0xFFD6C8B8)),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.45),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),

                        // Bottom Control Action Row
                        Row(
                          children: [
                            // Back Button (Smoothly animated)
                            AnimatedOpacity(
                              opacity: onPrev != null ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedScale(
                                scale: onPrev != null ? 1.0 : 0.8,
                                duration: const Duration(milliseconds: 200),
                                child: InkWell(
                                  onTap: onPrev != null
                                      ? () {
                                          HapticFeedback.selectionClick();
                                          onPrev!();
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.14)
                                            : Colors.black.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      size: 19,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Main Glowing CTA Button (Liquid Glass Fill)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isButtonEnabled
                                      ? () {
                                          HapticFeedback.mediumImpact();
                                          onNext();
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(999),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isButtonEnabled
                                            ? (isLastPage
                                                ? [
                                                    theme.colorScheme.primary,
                                                    const Color(0xFFD47551),
                                                  ]
                                                : [
                                                    theme.colorScheme.primary,
                                                    theme.colorScheme.primary.withValues(alpha: 0.92),
                                                  ])
                                            : [
                                                Colors.grey.withValues(alpha: 0.4),
                                                Colors.grey.withValues(alpha: 0.4),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: isButtonEnabled
                                          ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.35),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.35),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          buttonLabel,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isLastPage
                                              ? Icons.bolt_rounded
                                              : Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
