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

  bool get isRunning => stoppedAt == null;

  // derived: date key for grouping (yyyy-MM-dd)
  @Index()
  String get dayKey {
    final d = startedAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void stop() {
    stoppedAt = DateTime.now();
    durationSeconds = stoppedAt!.difference(startedAt).inSeconds;
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
