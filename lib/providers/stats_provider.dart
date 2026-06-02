// lib/providers/stats_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/task_entry.dart';
import '../services/db_service.dart';
import '../utils/date_utils.dart';

class DayStats {
  final String dayKey;
  final int totalSeconds;
  final Map<String, int> byCategory;

  DayStats({
    required this.dayKey,
    required this.totalSeconds,
    required this.byCategory,
  });
}

final weekStatsProvider = FutureProvider<List<DayStats>>((ref) async {
  final db = await DbService.db;
  final now = DateTime.now();

  final stats = <DayStats>[];
  for (int i = 6; i >= 0; i--) {
    final d = now.subtract(Duration(days: i));
    final key = dayKey(d);
    final tasks = await db.taskEntrys.filter().dayKeyEqualTo(key).findAll();

    final byCategory = <String, int>{};
    int total = 0;
    for (final t in tasks) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.durationSeconds;
      total += t.durationSeconds;
    }

    stats.add(DayStats(dayKey: key, totalSeconds: total, byCategory: byCategory));
  }
  return stats;
});

final weekTotalSecondsProvider = FutureProvider<int>((ref) async {
  final stats = await ref.watch(weekStatsProvider.future);
  return stats.fold(0, (sum, s) => sum + s.totalSeconds);
});

extension on FutureOr<int> {
  FutureOr<int> operator +(int other) {
    if (this is Future<int>) {
      return (this as Future<int>).then((value) => value + other);
    } else {
      return (this as int) + other;
    }
  }
}
