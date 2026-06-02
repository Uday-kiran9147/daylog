import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/models/task_entry.dart';

void main() {
  group('TaskEntry Model Tests', () {
    test('initial task state is running', () {
      final task = TaskEntry()
        ..title = 'Write tests'
        ..category = 'study'
        ..startedAt = DateTime.now();

      expect(task.isRunning, isTrue);
      expect(task.stoppedAt, isNull);
      expect(task.durationSeconds, 0);
    });

    test('stopping task updates duration and state', () {
      final started = DateTime.now().subtract(const Duration(minutes: 5));
      final task = TaskEntry()
        ..title = 'Write tests'
        ..category = 'study'
        ..startedAt = started;

      task.stop();

      expect(task.isRunning, isFalse);
      expect(task.stoppedAt, isNotNull);
      expect(task.durationSeconds, greaterThanOrEqualTo(300));
    });

    test('negative duration is guarded and set to 0', () {
      final startedInFuture = DateTime.now().add(const Duration(minutes: 5));
      final task = TaskEntry()
        ..title = 'Time travel'
        ..category = 'other'
        ..startedAt = startedInFuture;

      task.stop();

      expect(task.durationSeconds, 0);
    });

    test('formattedDuration handles various values correctly', () {
      final task = TaskEntry()
        ..title = 'Formatting'
        ..category = 'backend'
        ..startedAt = DateTime.now();

      task.durationSeconds = 45;
      expect(task.formattedDuration, '45s');

      task.durationSeconds = 125;
      expect(task.formattedDuration, '2m 5s');

      task.durationSeconds = 3665;
      expect(task.formattedDuration, '1h 1m');
    });

    test('dayKey returns correct yyyy-MM-dd string', () {
      final date = DateTime(2026, 6, 2, 14, 30);
      final task = TaskEntry()
        ..title = 'DayKey check'
        ..category = 'backend'
        ..startedAt = date;

      expect(task.dayKey, '2026-06-02');
    });
  });
}
