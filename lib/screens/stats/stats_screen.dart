import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/notion_widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(weekStatsProvider);
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
      body: SafeArea(
        top: false,
        child: statsAsync.when(
          data: (stats) {
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

            final categoryTotals = <String, int>{};
            for (final s in processedStats) {
              for (final e in s.byCategory.entries) {
                categoryTotals[e.key] = (categoryTotals[e.key] ?? 0) + e.value;
              }
            }
            final topCategory = categoryTotals.isEmpty
                ? null
                : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

            final totalWeekSeconds = processedStats.fold<int>(0, (sum, s) => sum + s.totalSeconds);
            final percentage = totalWeekSeconds > 0 && topCategory != null
                ? ((categoryTotals[topCategory]! / totalWeekSeconds) * 100).round()
                : 0;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Compact Header
                const NotionPageHeader(
                  icon: Icons.insights_rounded,
                  title: 'Focus Analytics',
                  subtitle: 'Focus time, category distribution, and weekly habit consistency.',
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TODAY SECTION ────────────────────────────────────────────────
                      Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Tracked Today',
                              value: formatDuration(todayTotalSeconds),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Tasks Logged',
                              value: todayTasksLoggedCount.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (todayCategoryTotals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No tasks logged today yet.',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      else
                        ...todayCategoryTotals.entries.map((e) => CategoryProgressBar(
                              category: e.key,
                              seconds: e.value,
                              totalSeconds: todayTotalSeconds,
                            )),

                      const SizedBox(height: 18),
                      Divider(color: theme.colorScheme.outlineVariant, thickness: 0.5),
                      const SizedBox(height: 14),

                      // ── THIS WEEK SECTION ────────────────────────────────────────────
                      Text(
                        'THIS WEEK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Total Tracked',
                              value: formatDuration(totalWeekSeconds),
                            ),
                          ),
                          const SizedBox(width: 12),
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

                      const SizedBox(height: 18),

                      // Bar Chart Box with Non-Clipping FittedBox Duration Labels
                      Text('Daily Hours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
                        ),
                        child: SizedBox(
                          height: 150,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: processedStats.map((s) {
                              final ratio = maxSeconds > 0 ? (s.totalSeconds / maxSeconds) : 0.0;
                              final dayLabel = s.dayKey.split('-').last;
                              final isToday = s.dayKey == dayKey(DateTime.now());
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        child: s.totalSeconds > 0
                                            ? FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.bottomCenter,
                                                child: Text(
                                                  formatDuration(s.totalSeconds),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 400),
                                            height: ratio == 0 ? 4.0 : (80.0 * ratio),
                                            decoration: BoxDecoration(
                                              color: ratio == 0
                                                  ? theme.colorScheme.outlineVariant
                                                  : theme.colorScheme.primary,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(3),
                                                topRight: Radius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        dayLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
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
                      ),

                      const SizedBox(height: 20),
                      Text('Weekly Category Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 10),
                      if (categoryTotals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No tasks tracked this week.',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      else
                        ...categoryTotals.entries.map((e) => CategoryProgressBar(
                              category: e.key,
                              seconds: e.value,
                              totalSeconds: totalWeekSeconds,
                            )),

                      if (topCategory != null) ...[
                        const SizedBox(height: 16),
                        NotionCallout(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'Weekly Insight',
                          subtitle: totalWeekSeconds == 0
                              ? 'Start tracking to see insights'
                              : '${capitalizeCategory(topCategory)} work takes up $percentage% of your tracked focus this week.',
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Failed to load stats: $e', style: TextStyle(color: theme.colorScheme.error)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
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
