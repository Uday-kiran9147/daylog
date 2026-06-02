// lib/providers/task_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/task_entry.dart';
import '../services/db_service.dart';
import '../utils/date_utils.dart';

// ── active running task ──────────────────────────────────────────────────────

class ActiveTaskNotifier extends AsyncNotifier<TaskEntry?> {
  @override
  Future<TaskEntry?> build() async {
    final db = await DbService.db;
    return db.taskEntrys.filter().stoppedAtIsNull().findFirst();
  }

  Future<TaskEntry> startTask(String title, String category) async {
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
  }

  Future<void> stopActive() async {
    final running = state.valueOrNull;
    if (running == null) return;

    final db = await DbService.db;
    running.stop();
    await db.writeTxn(() => db.taskEntrys.put(running));
    state = const AsyncData(null);
  }

  Future<void> pauseActive() async {
    // for simplicity: pause = stop (duration saved), can resume as new entry
    await stopActive();
  }
}

final activeTaskProvider = AsyncNotifierProvider<ActiveTaskNotifier, TaskEntry?>(
  ActiveTaskNotifier.new,
);

// ── today's tasks ────────────────────────────────────────────────────────────

final todayTasksProvider = FutureProvider<List<TaskEntry>>((ref) async {
  ref.watch(activeTaskProvider); // refresh when active task changes
  final db = await DbService.db;
  final key = dayKey(DateTime.now());
  return db.taskEntrys
      .filter()
      .dayKeyEqualTo(key)
      .sortByStartedAtDesc()
      .findAll();
});

// ── today total tracked seconds ──────────────────────────────────────────────

final todayTotalSecondsProvider = FutureProvider<int>((ref) async {
  final tasks = await ref.watch(todayTasksProvider.future);
  return tasks.fold<int>(0, (sum, t) => sum + t.durationSeconds);
});

// ── tasks for a given dayKey ─────────────────────────────────────────────────

final tasksForDayProvider = FutureProvider.family<List<TaskEntry>, String>((ref, key) async {
  final db = await DbService.db;
  return db.taskEntrys.filter().dayKeyEqualTo(key).findAll();
});

// ── recent distinct task titles (for quick-start chips) ─────────────────────

final recentTasksProvider = FutureProvider<List<TaskEntry>>((ref) async {
  final db = await DbService.db;
  return db.taskEntrys
      .filter()
      .stoppedAtIsNotNull()
      .sortByStartedAtDesc()
      .limit(10)
      .findAll();
});
