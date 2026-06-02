// lib/providers/journal_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/journal_entry.dart';
import '../models/task_entry.dart';
import '../services/db_service.dart';
import '../utils/date_utils.dart';

// ── today's journal entry (null if not yet written) ──────────────────────────

final todayJournalProvider = FutureProvider<JournalEntry?>((ref) async {
  final db = await DbService.db;
  return db.journalEntrys.getByDayKey(dayKey(DateTime.now()));
});

// ── save / update today's journal ────────────────────────────────────────────

class JournalNotifier extends AsyncNotifier<JournalEntry?> {
  @override
  Future<JournalEntry?> build() async {
    final db = await DbService.db;
    return db.journalEntrys.getByDayKey(dayKey(DateTime.now()));
  }

  Future<void> save({
    required String shipped,
    required String blockers,
    required String tomorrow,
  }) async {
    final db = await DbService.db;
    final key = dayKey(DateTime.now());

    // sum up today's tracked time
    final tasks = await db.taskEntrys
        .filter()
        .dayKeyEqualTo(key)
        .findAll();
    final totalSeconds = tasks.fold<int>(0, (s, t) => s + t.durationSeconds);

    final existing = await db.journalEntrys.getByDayKey(key);
    final entry = (existing ?? JournalEntry()..dayKey = key..createdAt = DateTime.now())
      ..shipped = shipped
      ..blockers = blockers
      ..tomorrow = tomorrow
      ..totalTrackedSeconds = totalSeconds;

    await db.writeTxn(() => db.journalEntrys.put(entry));
    state = AsyncData(entry);
  }
}

final journalNotifierProvider = AsyncNotifierProvider<JournalNotifier, JournalEntry?>(
  JournalNotifier.new,
);

// ── week entries for stats screen ────────────────────────────────────────────

final weekJournalsProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final db = await DbService.db;
  final now = DateTime.now();
  final keys = List.generate(7, (i) {
    final d = now.subtract(Duration(days: i));
    return dayKey(d);
  });
  return db.journalEntrys
      .filter()
      .anyOf(keys, (q, k) => q.dayKeyEqualTo(k))
      .findAll();
});
