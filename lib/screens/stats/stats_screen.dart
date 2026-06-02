import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(weekStatsProvider);
    final totalAsync = ref.watch(weekTotalSecondsProvider);
    final journalsAsync = ref.watch(weekJournalsProvider);
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final activeTaskAsync = ref.watch(activeTaskProvider);

    final activeTask = activeTaskAsync.valueOrNull;
    if (activeTask != null && !activeTask.isPaused) {
      ref.watch(appTickerProvider);
    }

    // ── TODAY STATS CALCULATIONS ─────────────────────────────────────────────
    final todayTasks = todayTasksAsync.valueOrNull ?? [];
    final todayCategoryTotals = <String, int>{};
    int todayTotalSeconds = 0;
    int todayTasksLoggedCount = 0;

    for (final t in todayTasks) {
      final duration = t.isRunning ? t.currentElapsedSeconds : t.durationSeconds;
      todayCategoryTotals[t.category] = (todayCategoryTotals[t.category] ?? 0) + duration;
      todayTotalSeconds += duration;
      if (!t.isRunning) {
        todayTasksLoggedCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: statsAsync.when(
        data: (stats) {
          // Adjust weekly stats in real-time to include active task ticks
          final todayKeyStr = dayKey(DateTime.now());
          final processedStats = stats.map((s) {
            if (s.dayKey == todayKeyStr && activeTask != null && !activeTask.isPaused) {
              final activeSeconds = activeTask.currentElapsedSeconds;
              final newByCategory = Map<String, int>.from(s.byCategory);
              newByCategory[activeTask.category] = (newByCategory[activeTask.category] ?? 0) + activeSeconds;
              return DayStats(
                dayKey: s.dayKey,
                totalSeconds: s.totalSeconds + activeSeconds,
                byCategory: newByCategory,
              );
            }
            return s;
          }).toList();

          final maxSeconds = processedStats.fold<int>(1, (m, s) => s.totalSeconds > m ? s.totalSeconds : m);

          // aggregate category totals
          final categoryTotals = <String, int>{};
          for (final s in processedStats) {
            for (final e in s.byCategory.entries) {
              categoryTotals[e.key] = (categoryTotals[e.key] ?? 0) + e.value;
            }
          }
          final topCategory = categoryTotals.isEmpty ? null
              : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

          final totalWeekSeconds = processedStats.fold<int>(0, (sum, s) => sum + s.totalSeconds);
          final percentage = totalWeekSeconds > 0 && topCategory != null
              ? ((categoryTotals[topCategory]! / totalWeekSeconds) * 100).round()
              : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── TODAY SECTION ────────────────────────────────────────────────
              Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Tracked Today',
                      value: formatDuration(todayTotalSeconds),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'Tasks Logged',
                      value: todayTasksLoggedCount.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (todayCategoryTotals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No tasks logged today yet.',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                  ),
                )
              else
                ...todayCategoryTotals.entries.map((e) => CategoryProgressBar(
                      category: e.key,
                      seconds: e.value,
                      totalSeconds: todayTotalSeconds,
                    )),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // ── THIS WEEK SECTION ────────────────────────────────────────────
              Text(
                'THIS WEEK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Total Tracked',
                      value: formatDuration(totalWeekSeconds),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'Days Journaled',
                      value: journalsAsync.when(
                        data: (journals) => '${journals.length} / 7',
                        loading: () => '--',
                        error: (_, __) => '--',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // bar chart
              Text('Daily Hours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.outline)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: processedStats.map((s) {
                    final ratio = maxSeconds > 0 ? s.totalSeconds / maxSeconds : 0.0;
                    final dayLabel = s.dayKey.split('-').last;
                    final isToday = s.dayKey == dayKey(DateTime.now());
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (s.totalSeconds > 0)
                              Text(
                                formatDuration(s.totalSeconds),
                                style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            const SizedBox(height: 3),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: ratio == 0 ? 4 : 80 * ratio,
                              decoration: BoxDecoration(
                                color: ratio == 0
                                    ? theme.colorScheme.outlineVariant
                                    : theme.colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.w500 : FontWeight.w400,
                                color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),
              Text('Weekly Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.outline)),
              const SizedBox(height: 12),
              if (categoryTotals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No tasks tracked this week.',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                  ),
                )
              else
                ...categoryTotals.entries.map((e) => CategoryProgressBar(
                      category: e.key,
                      seconds: e.value,
                      totalSeconds: totalWeekSeconds,
                    )),

              if (topCategory != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
                  ),
                  child: Text(
                    totalWeekSeconds == 0
                        ? 'Start tracking to see insights'
                        : '${capitalizeCategory(topCategory)} work takes up $percentage% of your week.',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSecondaryContainer, height: 1.5),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load stats',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryProgressBar extends StatelessWidget {
  final String category;
  final int seconds;
  final int totalSeconds;

  const CategoryProgressBar({
    super.key,
    required this.category,
    required this.seconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = totalSeconds > 0 ? seconds / totalSeconds : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: categoryColor(category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    capitalizeCategory(category),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '${formatDuration(seconds)} (${(percent * 100).round()}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor(category)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}


class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
