import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import '../../providers/journal_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('this week'),
        // actions: [
          // IconButton(
          //   icon: const Icon(Icons.share_rounded),
          //   tooltip: 'export data',
          //   onPressed: () async {
          //     try {
          //       await ExportService.exportData();
          //     } catch (e) {
          //       if (context.mounted) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text('failed to export data: $e'),
          //             backgroundColor: Colors.redAccent,
          //           ),
          //         );
          //       }
          //     }
          //   },
          // ),
        // ],
      ),
      body: statsAsync.when(
        data: (stats) {
          final maxSeconds = stats.fold<int>(1, (m, s) => s.totalSeconds > m ? s.totalSeconds : m);

          // aggregate category totals
          final categoryTotals = <String, int>{};
          for (final s in stats) {
            for (final e in s.byCategory.entries) {
              categoryTotals[e.key] = (categoryTotals[e.key] ?? 0) + e.value;
            }
          }
          final topCategory = categoryTotals.isEmpty ? null
              : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

          final totalWeekSeconds = totalAsync.valueOrNull ?? 0;
          final percentage = totalWeekSeconds > 0 && topCategory != null
              ? ((categoryTotals[topCategory]! / totalWeekSeconds) * 100).round()
              : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // stat row
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'total tracked',
                      value: totalAsync.when(
                        data: (s) => formatDuration(s),
                        loading: () => '--',
                        error: (_, __) => '--',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'days journaled',
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
              Text('daily hours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.outline)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: stats.map((s) {
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

              const SizedBox(height: 20),

              // legend
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: categoryTotals.keys.map((cat) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: categoryColor(cat), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$cat  ${formatDuration(categoryTotals[cat]!)}',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                )).toList(),
              ),

              if (topCategory != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalWeekSeconds == 0
                        ? 'start tracking to see insights'
                        : '$topCategory work takes up $percentage% of your week.',
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
