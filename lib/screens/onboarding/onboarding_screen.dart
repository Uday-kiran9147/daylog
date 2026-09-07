// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
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

  // Selected categories state for onboarding
  late Set<String> _selectedCategories;
  double _dailyGoalHours = 4.0;
  bool _eveningReminder = true;

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
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      onPressed: _prevPage,
                      tooltip: 'Back',
                    )
                  else
                    const SizedBox(width: 48),

                  // Step Indicator Dots
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                              : (isDark ? const Color(0xFF423C38) : const Color(0xFFD6C8B8)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),

                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(onNext: _nextPage),
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
                  _GoalSettingPage(
                    dailyGoalHours: _dailyGoalHours,
                    onGoalChanged: (val) => setState(() => _dailyGoalHours = val),
                    eveningReminder: _eveningReminder,
                    onReminderChanged: (val) => setState(() => _eveningReminder = val),
                  ),
                ],
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedCategories.isEmpty ? null : _nextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentPage == 2 ? 'Start Tracking' : 'Continue',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

/// ── Page 1: Welcome & Highlights ─────────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        const SizedBox(height: 10),
        // App Logo / Hero Pulsing Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
              shape: BoxShape.circle,
              border: Border.all(
                color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.access_time_filled_rounded,
              size: 40,
              color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Master your focus\nwith Daylog',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'An offline-first, organic workspace for high performers. Track sessions, organize priorities, and reflect daily.',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Feature Pillars
        _FeatureCard(
          icon: Icons.timer_outlined,
          title: 'Zero-Friction Focus Timer',
          description: '1-tap live timers, auto category detection, and background notifications.',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.check_circle_outline_rounded,
          title: 'Action Items & Priorities',
          description: 'High-priority flags, due dates, and quick capture for todos.',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.auto_stories_outlined,
          title: 'Daily Evening Reflection',
          description: 'Structured 4-question journal to review wins, learnings, and tomorrow’s goals.',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.bar_chart_rounded,
          title: 'Deep Work Insights',
          description: 'Weekly focus breakdowns, distribution charts, and goal tracking.',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Page 2: Category Customization ──────────────────────────────────────────
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

    final filteredCategories = allCategories.where((cat) {
      if (_searchQuery.isNotEmpty && !cat.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedDomain != 'All') {
        final domain = kCategoryDomains.firstWhere((d) => d.title == _selectedDomain);
        if (!domain.categories.contains(cat)) return false;
      }
      return true;
    }).toList();

    return ListView(
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
          'Select the work & focus domains you want in your daylog. You can add or change these anytime.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // Quick Presets Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PresetChip(
                label: '💻 Developer',
                onTap: () => widget.onApplyPreset(['Development', 'DSA', 'System Design', 'DevOps', 'Deep Work']),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '🎨 Designer',
                onTap: () => widget.onApplyPreset(['Design', 'Product Planning', 'Research', 'Deep Work', 'Client Work']),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '✍️ Creator / Writer',
                onTap: () => widget.onApplyPreset(['Writing', 'Content', 'Audio & Video', 'Deep Work', 'Marketing']),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: '📚 Student',
                onTap: () => widget.onApplyPreset(['Learning', 'Reading', 'Deep Work', 'Side Projects', 'Health & Fitness']),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Search Bar & Add Custom Button
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
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
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Custom', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Domain Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _DomainTab(
                label: 'All',
                isSelected: _selectedDomain == 'All',
                onTap: () => setState(() => _selectedDomain = 'All'),
              ),
              ...kCategoryDomains.map((d) => _DomainTab(
                    label: d.title,
                    isSelected: _selectedDomain == d.title,
                    onTap: () => setState(() => _selectedDomain = d.title),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Selected count indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.selectedCategories.length} selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Tap to select or deselect',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Category Cards Grid (Vertical layout with childAspectRatio: 1.3)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
          ),
          itemCount: filteredCategories.length,
          itemBuilder: (context, index) {
            final cat = filteredCategories[index];
            final isSelected = widget.selectedCategories.contains(cat);
            final info = getCategoryInfo(cat);

            return InkWell(
              onTap: () => widget.onToggleCategory(cat),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent).withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Category Icon + Check indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? info.darkBg : info.lightBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            info.icon,
                            size: 18,
                            color: isDark ? info.darkFg : info.lightFg,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                                  : theme.colorScheme.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Category Title (100% visible, up to 2 lines)
                    Text(
                      capitalizeCategory(cat),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
      ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outlineVariant),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _DomainTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// ── Page 3: Goal & Preferences ──────────────────────────────────────────────
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
      ],
    );
  }
}
