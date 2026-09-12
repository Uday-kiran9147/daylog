import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/flavor_config.dart';
import 'models/task_entry.dart';
import 'screens/home/home_screen.dart';
import 'screens/todos/todos_screen.dart';
import 'screens/journal/journal_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/timer/timer_fullscreen_modal.dart';
import 'screens/timer/start_task_sheet.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_settings_provider.dart';
import 'utils/constants.dart';
import 'utils/date_utils.dart';
import 'widgets/daylog_widgets.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);
final showTimerFullProvider = StateProvider<bool>((ref) => false);
final appInitErrorProvider = StateProvider<String?>((ref) => null);

class DayLogApp extends ConsumerWidget {
  const DayLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final initError = ref.watch(appInitErrorProvider);
    final userSettings = ref.watch(userSettingsProvider);
    final appTitle = FlavorConfig.instance.appTitle;

    if (initError != null) {
      return MaterialApp(
        title: '$appTitle - Error',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to initialize $appTitle',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      initError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: appTitle,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: FlavorConfig.instance.isDev,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: isDark ? DaylogColors.darkBg : DaylogColors.lightBg,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: userSettings.hasCompletedOnboarding ? const _Shell() : const OnboardingScreen(),
    );
  }
}

class _Shell extends ConsumerWidget {
  const _Shell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);
    final showTimerFull = ref.watch(showTimerFullProvider);
    final activeTask = ref.watch(activeTaskProvider).valueOrNull;

    // If fullscreen timer is active and there is an active task, display it as an overlay
    if (showTimerFull && activeTask != null) {
      return TimerFullscreenModal(
        task: activeTask,
        onMinimize: () => ref.read(showTimerFullProvider.notifier).state = false,
      );
    }

    final screens = [
      HomeScreen(
        onOpenTimerModal: () => ref.read(showTimerFullProvider.notifier).state = true,
      ),
      const TodosScreen(),
      const JournalScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Screen views
          IndexedStack(index: index, children: screens),
        ],
      ),
      bottomNavigationBar: RepaintBoundary(
        child: _GlassDock(
          selectedIndex: index,
          activeTask: activeTask,
          onTabSelected: (i) => ref.read(navigationIndexProvider.notifier).state = i,
          onActionTap: () {
            if (activeTask != null) {
              ref.read(showTimerFullProvider.notifier).state = true;
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => StartTaskSheet(
                  onTaskStarted: (_) {
                    ref.read(showTimerFullProvider.notifier).state = true;
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

/// Floating Frosted Glass Navigation Dock inspired by the sleek design reference
class _GlassDock extends StatelessWidget {
  final int selectedIndex;
  final TaskEntry? activeTask;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onActionTap;

  const _GlassDock({
    required this.selectedIndex,
    required this.activeTask,
    required this.onTabSelected,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ambient glow color: category color if active task is running, otherwise theme primary
    final glowColor = activeTask != null
        ? getCategoryInfo(activeTask!.category).tileColor
        : (isDark ? DaylogColors.darkAccent : DaylogColors.accent);

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Ambient atmospheric glow behind the dock (matching reference image)
            Positioned(
              bottom: 4,
              child: Container(
                width: 220,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: isDark ? 0.32 : 0.18),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // Main Frosted Glass Dock Container
            Container(
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E1C1A) : const Color(0xFFFFF9F0))
                    .withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 7, 6, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Pill Action Button (matching "Capture" in reference image)
                        _TopActionPill(
                          activeTask: activeTask,
                          onTap: onActionTap,
                        ),

                        const SizedBox(height: 5),

                        // Bottom Navigation Deck with Inset Container
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.28)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              _DockNavItem(
                                index: 0,
                                selectedIndex: selectedIndex,
                                icon: Icons.home_outlined,
                                activeIcon: Icons.home_rounded,
                                label: 'Home',
                                onTap: () => onTabSelected(0),
                              ),
                              _DockNavItem(
                                index: 1,
                                selectedIndex: selectedIndex,
                                icon: Icons.grid_view_outlined,
                                activeIcon: Icons.grid_view_rounded,
                                label: 'Todos',
                                onTap: () => onTabSelected(1),
                              ),
                              _DockNavItem(
                                index: 2,
                                selectedIndex: selectedIndex,
                                icon: Icons.auto_stories_outlined,
                                activeIcon: Icons.auto_stories_rounded,
                                label: 'Journal',
                                onTap: () => onTabSelected(2),
                              ),
                              _DockNavItem(
                                index: 3,
                                selectedIndex: selectedIndex,
                                icon: Icons.bar_chart_outlined,
                                activeIcon: Icons.bar_chart_rounded,
                                label: 'Stats',
                                onTap: () => onTabSelected(3),
                              ),
                              _DockNavItem(
                                index: 4,
                                selectedIndex: selectedIndex,
                                icon: Icons.tune_rounded,
                                activeIcon: Icons.tune_rounded,
                                label: 'Settings',
                                onTap: () => onTabSelected(4),
                              ),
                            ],
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

/// Centered Top Pill Action Button
class _TopActionPill extends StatelessWidget {
  final TaskEntry? activeTask;
  final VoidCallback onTap;

  const _TopActionPill({
    required this.activeTask,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRunning = activeTask != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
          decoration: BoxDecoration(
            color: isRunning
                ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.65)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isRunning
                  ? (isDark
                      ? DaylogColors.darkAccent.withValues(alpha: 0.5)
                      : DaylogColors.accent.withValues(alpha: 0.35))
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : DaylogColors.lightDivider),
              width: 1.0,
            ),
          ),
          child: isRunning
              ? _TickingTopActionContent(task: activeTask!, isDark: isDark)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timelapse_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Capture focus',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Isolated Leaf for Top Pill Timer Display
class _TickingTopActionContent extends ConsumerWidget {
  final TaskEntry task;
  final bool isDark;

  const _TickingTopActionContent({
    required this.task,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!task.isPaused) {
      ref.watch(appTickerProvider);
    }
    final elapsedSec = task.currentElapsedSeconds;
    final timerText = formatTimer(elapsedSec);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingDot(
          color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
          size: 6,
          isPaused: task.isPaused,
        ),
        const SizedBox(width: 6),
        Text(
          '$timerText · ${task.title}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Refined Inset Tab Item with Elevated Specular Pill Indicator
class _DockNavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback onTap;

  const _DockNavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Active tab colors & styling
    final activeBg = isDark ? const Color(0xFF2C2825) : Colors.white;
    final activeBorder = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : DaylogColors.accent.withValues(alpha: 0.25);
    final activeShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            BoxShadow(
              color: DaylogColors.accent.withValues(alpha: 0.14),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final activeIconColor = isDark ? Colors.white : DaylogColors.accent;
    final activeTextColor = isDark ? Colors.white : DaylogColors.lightText;

    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
              .withValues(alpha: 0.12),
          highlightColor: (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
              .withValues(alpha: 0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            decoration: BoxDecoration(
              color: selected ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? activeBorder : Colors.transparent,
                width: 1.0,
              ),
              boxShadow: selected ? activeShadow : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    selected ? (activeIcon ?? icon) : icon,
                    size: 21,
                    color: selected ? activeIconColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? activeTextColor : inactiveColor,
                    letterSpacing: selected ? -0.1 : 0,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
