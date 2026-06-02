// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home/home_screen.dart';
import 'screens/timer/timer_screen.dart';
import 'screens/journal/journal_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'utils/constants.dart';

import 'providers/theme_provider.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class DayLogApp extends ConsumerWidget {
  const DayLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
    JournalScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x18000000), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => ref.read(navigationIndexProvider.notifier).state = i,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), activeIcon: Icon(Icons.timer_rounded), label: 'Timer'),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note_rounded), label: 'Journal'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          ],
        ),
      ),
    );
  }
}
