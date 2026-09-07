// lib/screens/timer/timer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';
import 'start_task_sheet.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeTaskProvider);
    final recentAsync = ref.watch(recentTasksProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final active = activeAsync.valueOrNull;
    if (active != null && !active.isPaused) {
      ref.watch(appTickerProvider);
    }

    final elapsed = active != null ? active.currentElapsedSeconds : 0;

    return activeAsync.when(
      data: (active) {
        return Scaffold(
          body: SafeArea(
            top: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DaylogPageHeader(
                  title: 'Focus Timer',
                  subtitle: 'Track active focus session and launch quick focus blocks.',
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                active.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              CategoryTag(category: active.category, isDark: isDark),
                              const SizedBox(height: 20),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatTimer(elapsed),
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 1.0,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PulsingDot(
                                    color: theme.colorScheme.primary,
                                    size: 7,
                                    isPaused: active.isPaused,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    active.isPaused ? 'Paused' : 'Focusing',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  if (active.isPaused) {
                                    ref.read(activeTaskProvider.notifier).resumeActive();
                                  } else {
                                    ref.read(activeTaskProvider.notifier).pauseActive();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                                  backgroundColor: theme.cardTheme.color,
                                  foregroundColor: theme.colorScheme.onSurface,
                                ),
                                icon: Icon(
                                  active.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  active.isPaused ? 'Resume' : 'Pause',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => ref.read(activeTaskProvider.notifier).stopActive(),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: isDark ? DaylogColors.darkAccent700 : DaylogColors.accent700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                ),
                                icon: const Icon(Icons.stop_rounded, size: 18),
                                label: const Text('Stop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        DashedStartSessionCard(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const StartTaskSheet(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Quick start recent tasks',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 10),

                      recentAsync.when(
                        data: (tasks) {
                          final unique = <String, TaskEntry>{};
                          for (final t in tasks) {
                            unique.putIfAbsent(t.title, () => t);
                          }
                          if (unique.isEmpty) {
                            return Text(
                              'No recent tasks found.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: unique.values.take(6).map((t) {
                              return InkWell(
                                onTap: () => ref.read(activeTaskProvider.notifier).startTask(t.title, t.category),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
                                  ),
                                  child: Text(
                                    t.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}
