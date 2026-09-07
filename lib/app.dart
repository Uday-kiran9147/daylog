// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    if (initError != null) {
      return MaterialApp(
        title: 'DayLog - Error',
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
                    const Text(
                      'Failed to initialize DayLog',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      title: 'DayLog',
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
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
    final theme = Theme.of(context);

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
      body: Stack(
        children: [
          // Screen views
          IndexedStack(index: index, children: screens),

          // Pulsing Ring FAB (Displayed on Today screen when no active session is running)
          if (index == 0 && activeTask == null)
            Positioned(
              right: 20,
              bottom: 86,
              child: PulsingRingFab(
                onPressed: () {
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
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                index: 0,
                selectedIndex: index,
                icon: Icons.home_rounded,
                label: 'Today',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
              ),
              _BottomNavItem(
                index: 1,
                selectedIndex: index,
                icon: Icons.grid_view_rounded,
                label: 'Todos',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
              ),
              _BottomNavItem(
                index: 2,
                selectedIndex: index,
                icon: Icons.auto_stories_rounded,
                label: 'Journal',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
              ),
              _BottomNavItem(
                index: 3,
                selectedIndex: index,
                icon: Icons.bar_chart_rounded,
                label: 'Insights',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
              ),
              _BottomNavItem(
                index: 4,
                selectedIndex: index,
                icon: Icons.tune_rounded,
                label: 'Settings',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurface;
    final opacity = selected ? 1.0 : 0.55;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: color.withValues(alpha: opacity),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: color.withValues(alpha: opacity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
