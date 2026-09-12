import 'dart:async';

import 'package:flutter/foundation.dart';
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
  try {
    final db = await DbService.db;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    final keys = List.generate(7, (i) {
      final d = startOfWeek.add(Duration(days: i));
      return dayKey(d);
    });

    final tasks = await db.taskEntrys
        .filter()
        .anyOf(keys, (q, k) => q.dayKeyEqualTo(k))
        .findAll();

    final tasksByDay = <String, List<TaskEntry>>{};
    for (final t in tasks) {
      tasksByDay.putIfAbsent(t.dayKey, () => []).add(t);
    }

    final stats = <DayStats>[];
    for (final key in keys) {
      final dayTasks = tasksByDay[key] ?? [];
      final byCategory = <String, int>{};
      int total = 0;
      for (final t in dayTasks) {
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.durationSeconds;
        total += t.durationSeconds;
      }
      stats.add(DayStats(dayKey: key, totalSeconds: total, byCategory: byCategory));
    }
    return stats;
  } catch (e, stackTrace) {
    debugPrint('Error getting week stats: $e\n$stackTrace');
    return [];
  }
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
