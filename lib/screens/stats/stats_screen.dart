// lib/screens/stats/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(weekStatsProvider);
    final journalsAsync = ref.watch(weekJournalsProvider);
    final activeTaskAsync = ref.watch(activeTaskProvider);

    final activeTask = activeTaskAsync.valueOrNull;

    // Compute date subtitle for the current week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final weekSubtitle = 'Week of ${startOfWeek.day}–${endOfWeek.day} ${friendlyDate(startOfWeek).split(', ').last.split(' ').last}';

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            final todayKeyStr = dayKey(now);
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

            // Weekly category totals
            final categoryTotals = <String, int>{};
            for (final s in processedStats) {
              for (final e in s.byCategory.entries) {
                categoryTotals[e.key] = (categoryTotals[e.key] ?? 0) + e.value;
              }
            }

            final totalWeekSeconds = processedStats.fold<int>(0, (sum, s) => sum + s.totalSeconds);
            final totalWeekHours = (totalWeekSeconds / 3600.0).toStringAsFixed(1);

            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final topCategory = sortedCategories.isNotEmpty ? sortedCategories.first : null;
            final topCategoryHours = topCategory != null
                ? (topCategory.value / 3600.0).toStringAsFixed(1)
                : '0.0';
            final topCategoryPct = (totalWeekSeconds > 0 && topCategory != null)
                ? ((topCategory.value / totalWeekSeconds) * 100).round()
                : 0;

            final insightText = topCategory != null && totalWeekSeconds > 0
                ? '${capitalizeCategory(topCategory.key)} took up the biggest share of your week — ${topCategoryHours}h of ${totalWeekHours}h ($topCategoryPct%).'
                : 'Start tracking tasks this week to unlock personalized focus insights.';

            final weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(weekStatsProvider);
                ref.invalidate(weekJournalsProvider);
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Page Header
                  DaylogPageHeader(
                    title: 'Insights',
                    subtitle: weekSubtitle,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat Cards: This Week (Hours) + Days Journaled
                        Row(
                          children: [
                            Expanded(
                              child: DaylogStatCard(
                                kicker: 'This week',
                                value: '${totalWeekHours}h',
                                isAccent: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DaylogStatCard(
                                kicker: 'Days journaled',
                                value: journalsAsync.when(
                                  data: (j) => '${j.where((e) => e.shipped.isNotEmpty).length}/7',
                                  loading: () => '--/7',
                                  error: (_, __) => '--/7',
                                ),
                                isAccent: false,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Focus Hours by Day Section
                        Text(
                          'Focus hours by day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Vertical Bar Chart
                        Container(
                          height: 160,
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(processedStats.length, (i) {
                              final s = processedStats[i];
                              final isToday = s.dayKey == todayKeyStr;
                              final ratio = maxSeconds > 0 ? (s.totalSeconds / maxSeconds) : 0.0;
                              final hours = (s.totalSeconds / 3600.0).toStringAsFixed(1);
                              final dayName = i < weekDayLabels.length ? weekDayLabels[i] : '';

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${hours}h',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 400),
                                            height: ratio == 0 ? 4.0 : (85.0 * ratio),
                                            decoration: BoxDecoration(
                                              color: isToday
                                                  ? theme.colorScheme.primary
                                                  : (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent200),
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(3)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        dayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                          color: isToday
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Category Distribution Progress Bars
                        Text(
                          'By category this week',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (sortedCategories.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No focus logs tracked this week.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        else
                          ...sortedCategories.take(5).map((e) {
                            final hoursStr = (e.value / 3600.0).toStringAsFixed(1);
                            final pct = totalWeekSeconds > 0
                                ? ((e.value / totalWeekSeconds) * 100).round()
                                : 0;
                            final ratio = totalWeekSeconds > 0 ? (e.value / totalWeekSeconds) : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CategoryTag(category: e.key, isDark: isDark),
                                      Text(
                                        '${hoursStr}h · $pct%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: ratio.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 16),

                        // Insight Callout Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? DaylogColors.darkAccent.withValues(alpha: 0.45)
                                  : DaylogColors.accent.withValues(alpha: 0.35),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                                    .withValues(alpha: isDark ? 0.20 : 0.10),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Insight',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                insightText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
