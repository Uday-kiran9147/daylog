// lib/screens/stats/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weekStatsProvider);
    final totalAsync = ref.watch(weekTotalSecondsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('this week')),
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
                      value: totalAsync.when(
                        data: (_) => '${stats.where((s) => s.totalSeconds > 0).length} / 7',
                        loading: () => '--',
                        error: (_, __) => '--',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // bar chart
              const Text('daily hours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
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
                                style: const TextStyle(fontSize: 9, color: Color(0xFF888780)),
                              ),
                            const SizedBox(height: 3),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: ratio == 0 ? 4 : 80 * ratio,
                              decoration: BoxDecoration(
                                color: ratio == 0
                                    ? const Color(0xFFD3D1C7)
                                    : const Color(0xFF1D9E75),
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
                                color: isToday ? const Color(0xFF1D9E75) : const Color(0xFF888780),
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
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5F5E5A)),
                    ),
                  ],
                )).toList(),
              ),

              if (topCategory != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topCategory == null
                        ? 'start tracking to see insights'
                        : '$topCategory work takes up ${((categoryTotals[topCategory]! / (totalAsync.valueOrNull ?? 1)) * 100).round()}% of your week.',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3C3489), height: 1.5),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
        ],
      ),
    );
  }
}
