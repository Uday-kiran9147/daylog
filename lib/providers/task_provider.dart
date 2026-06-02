import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/task_entry.dart';
import '../services/db_service.dart';
import '../utils/date_utils.dart';

// ── active running task ──────────────────────────────────────────────────────

class ActiveTaskNotifier extends AsyncNotifier<TaskEntry?> {
  @override
  Future<TaskEntry?> build() async {
    try {
      final db = await DbService.db;
      return await db.taskEntrys.filter().stoppedAtIsNull().findFirst();
    } catch (e) {
      debugPrint('Error fetching active task: $e');
      return null;
    }
  }

  Future<TaskEntry> startTask(String title, String category) async {
    try {
      // stop any running task first
      await stopActive();

      final db = await DbService.db;
      final task = TaskEntry()
        ..title = title
        ..category = category
        ..startedAt = DateTime.now();

      await db.writeTxn(() => db.taskEntrys.put(task));
      state = AsyncData(task);
      return task;
    } catch (e, stackTrace) {
      debugPrint('Error starting task: $e\n$stackTrace');
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> stopActive() async {
    try {
      final running = state.valueOrNull;
      if (running == null) return;

      final db = await DbService.db;
      running.stop();
      await db.writeTxn(() => db.taskEntrys.put(running));
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      debugPrint('Error stopping task: $e\n$stackTrace');
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> pauseActive() async {
    try {
      // for simplicity: pause = stop (duration saved), can resume as new entry
      await stopActive();
    } catch (e) {
      debugPrint('Error pausing task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final db = await DbService.db;
      await db.writeTxn(() => db.taskEntrys.delete(id));
      ref.invalidate(todayTasksProvider);
      ref.invalidate(todayTotalSecondsProvider);
      ref.invalidate(recentTasksProvider);
    } catch (e, stackTrace) {
      debugPrint('Error deleting task: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> updateTask(TaskEntry task) async {
    try {
      final db = await DbService.db;
      await db.writeTxn(() => db.taskEntrys.put(task));
      ref.invalidate(todayTasksProvider);
      ref.invalidate(todayTotalSecondsProvider);
      ref.invalidate(recentTasksProvider);
    } catch (e, stackTrace) {
      debugPrint('Error updating task: $e\n$stackTrace');
      rethrow;
    }
  }
}

final activeTaskProvider = AsyncNotifierProvider<ActiveTaskNotifier, TaskEntry?>(
  ActiveTaskNotifier.new,
);

// ── today's tasks ────────────────────────────────────────────────────────────

final todayTasksProvider = FutureProvider<List<TaskEntry>>((ref) async {
  ref.watch(activeTaskProvider); // refresh when active task changes
  try {
    final db = await DbService.db;
    final key = dayKey(DateTime.now());
    return await db.taskEntrys
        .filter()
        .dayKeyEqualTo(key)
        .sortByStartedAtDesc()
        .findAll();
  } catch (e) {
    debugPrint('Error getting today tasks: $e');
    return [];
  }
});

// ── today total tracked seconds ──────────────────────────────────────────────

final todayTotalSecondsProvider = FutureProvider<int>((ref) async {
  final tasks = await ref.watch(todayTasksProvider.future);
  final active = ref.watch(activeTaskProvider).valueOrNull;

  int elapsed = 0;
  if (active != null) {
    final diff = DateTime.now().difference(active.startedAt).inSeconds;
    elapsed = diff > 0 ? diff : 0;
  }

  return tasks.fold<int>(elapsed, (sum, t) => sum + t.durationSeconds);
});

// ── tasks for a given dayKey ─────────────────────────────────────────────────

final tasksForDayProvider = FutureProvider.family<List<TaskEntry>, String>((ref, key) async {
  try {
    final db = await DbService.db;
    return await db.taskEntrys.filter().dayKeyEqualTo(key).findAll();
  } catch (e) {
    debugPrint('Error getting tasks for day $key: $e');
    return [];
  }
});

// ── recent distinct task titles (for quick-start chips) ─────────────────────

final recentTasksProvider = FutureProvider<List<TaskEntry>>((ref) async {
  try {
    final db = await DbService.db;
    return await db.taskEntrys
        .filter()
        .stoppedAtIsNotNull()
        .sortByStartedAtDesc()
        .limit(10)
        .findAll();
  } catch (e) {
    debugPrint('Error getting recent tasks: $e');
    return [];
  }
});
