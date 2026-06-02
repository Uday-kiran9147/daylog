import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/task_entry.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';
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
      NotificationService.updateTaskReminders(task);
      NotificationService.showTestNotification();
      ref.invalidate(todayTasksProvider);
      ref.invalidate(todayTotalSecondsProvider);
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
      NotificationService.updateTaskReminders(null);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(todayTotalSecondsProvider);
    } catch (e, stackTrace) {
      debugPrint('Error stopping task: $e\n$stackTrace');
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> pauseActive() async {
    try {
      final running = state.valueOrNull;
      if (running == null || running.isPaused) return;

      final db = await DbService.db;
      running.pausedAt = DateTime.now();
      await db.writeTxn(() => db.taskEntrys.put(running));
      state = AsyncData(running);
      NotificationService.updateTaskReminders(running);
    } catch (e, stackTrace) {
      debugPrint('Error pausing task: $e\n$stackTrace');
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> resumeActive() async {
    try {
      final running = state.valueOrNull;
      if (running == null || !running.isPaused) return;

      final db = await DbService.db;
      final now = DateTime.now();
      final diff = now.difference(running.pausedAt!).inSeconds;
      running.pauseDurationSeconds += diff > 0 ? diff : 0;
      running.pausedAt = null;
      await db.writeTxn(() => db.taskEntrys.put(running));
      state = AsyncData(running);
      NotificationService.updateTaskReminders(running);
    } catch (e, stackTrace) {
      debugPrint('Error resuming task: $e\n$stackTrace');
      state = AsyncError(e, stackTrace);
      rethrow;
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
  return tasks.fold<int>(0, (sum, t) => sum + t.durationSeconds);
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

// ── centralized battery-saving ticker ───────────────────────────────────────

class AppTickerNotifier extends StateNotifier<DateTime> with WidgetsBindingObserver {
  AppTickerNotifier(this._ref) : super(DateTime.now()) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  final Ref _ref;
  Timer? _timer;
  bool _isBackground = false;

  void _startTimer() {
    _timer?.cancel();
    final active = _ref.read(activeTaskProvider).valueOrNull;
    if (active != null && !active.isPaused && !_isBackground) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        state = DateTime.now();
      });
    } else {
      _timer = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final isBg = lifecycleState != AppLifecycleState.resumed;
    if (isBg != _isBackground) {
      _isBackground = isBg;
      _startTimer();
      if (lifecycleState == AppLifecycleState.resumed) {
        state = DateTime.now();
      }
    }
  }

  void updateTimerState() {
    _startTimer();
    state = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}

final appTickerProvider = StateNotifierProvider<AppTickerNotifier, DateTime>((ref) {
  final notifier = AppTickerNotifier(ref);
  ref.listen(activeTaskProvider, (_, __) {
    notifier.updateTimerState();
  });
  return notifier;
});
