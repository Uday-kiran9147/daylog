// lib/models/task_entry.dart
import 'package:isar/isar.dart';

part 'task_entry.g.dart';

@Collection()
class TaskEntry {
  Id id = Isar.autoIncrement;

  late String title;

  @Index()
  late String category; // backend, mobile, content, other

  late DateTime startedAt;
  DateTime? stoppedAt;

  // duration in seconds, set when stopped
  int durationSeconds = 0;

  DateTime? pausedAt;
  int pauseDurationSeconds = 0;

  bool get isRunning => stoppedAt == null;
  bool get isPaused => pausedAt != null;

  int get currentElapsedSeconds {
    if (stoppedAt != null) {
      return durationSeconds;
    }
    if (pausedAt != null) {
      final diff = pausedAt!.difference(startedAt).inSeconds - pauseDurationSeconds;
      return diff < 0 ? 0 : diff;
    }
    final diff = DateTime.now().difference(startedAt).inSeconds - pauseDurationSeconds;
    return diff < 0 ? 0 : diff;
  }

  // derived: date key for grouping (yyyy-MM-dd)
  @Index()
  String get dayKey {
    final d = startedAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void stop() {
    final now = DateTime.now();
    stoppedAt = now;
    if (pausedAt != null) {
      final diff = now.difference(pausedAt!).inSeconds;
      pauseDurationSeconds += diff > 0 ? diff : 0;
      pausedAt = null;
    }
    final totalDiff = stoppedAt!.difference(startedAt).inSeconds;
    final finalDuration = totalDiff - pauseDurationSeconds;
    durationSeconds = finalDuration < 0 ? 0 : finalDuration;
  }

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
