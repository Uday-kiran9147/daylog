// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home/home_screen.dart';
import 'screens/timer/timer_screen.dart';
import 'screens/todos/todos_screen.dart';
import 'screens/journal/journal_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'utils/constants.dart';

import 'providers/theme_provider.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

final appInitErrorProvider = StateProvider<String?>((ref) => null);

class DayLogApp extends ConsumerWidget {
  const DayLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final initError = ref.watch(appInitErrorProvider);

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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      initError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
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
      home: const _Shell(),
    );
  }
}

class _Shell extends ConsumerWidget {
  const _Shell();

  static const _screens = [
    HomeScreen(),
    TimerScreen(),
    TodosScreen(),
    JournalScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: _screens)),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NotionNavItem(
                index: 0,
                selectedIndex: index,
                icon: Icons.bolt_rounded,
                label: 'Today',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
              ),
              _NotionNavItem(
                index: 1,
                selectedIndex: index,
                icon: Icons.timer_outlined,
                label: 'Timer',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
              ),
              _NotionNavItem(
                index: 2,
                selectedIndex: index,
                icon: Icons.task_alt_rounded,
                label: 'Todos',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
              ),
              _NotionNavItem(
                index: 3,
                selectedIndex: index,
                icon: Icons.auto_stories_rounded,
                label: 'Journal',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
              ),
              _NotionNavItem(
                index: 4,
                selectedIndex: index,
                icon: Icons.insights_rounded,
                label: 'Stats',
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotionNavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NotionNavItem({
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

    return Flexible(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.surfaceContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? Border.all(color: theme.colorScheme.outlineVariant, width: 0.5)
                : Border.all(color: Colors.transparent, width: 0.5),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
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


