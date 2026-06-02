import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/journal_entry.dart';
import '../models/task_entry.dart';
import '../services/db_service.dart';
import '../utils/date_utils.dart';

// ── save / update today's journal ────────────────────────────────────────────

final selectedJournalDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class JournalForDateNotifier extends FamilyAsyncNotifier<JournalEntry?, String> {
  @override
  Future<JournalEntry?> build(String arg) async {
    try {
      final db = await DbService.db;
      return await db.journalEntrys.getByDayKey(arg);
    } catch (e) {
      debugPrint('Error building journal for date $arg: $e');
      return null;
    }
  }

  Future<void> save({
    required String shipped,
    required String blockers,
    required String tomorrow,
  }) async {
    try {
      final db = await DbService.db;
      final key = arg;

      // sum up this day's tracked time
      final tasks = await db.taskEntrys
          .filter()
          .dayKeyEqualTo(key)
          .findAll();
      final totalSeconds = tasks.fold<int>(0, (s, t) => s + t.durationSeconds);

      final existing = await db.journalEntrys.getByDayKey(key);
      
      DateTime createdAt;
      if (existing != null) {
        createdAt = existing.createdAt;
      } else {
        try {
          createdAt = DateTime.parse(key);
        } catch (_) {
          createdAt = DateTime.now();
        }
      }

      final entry = (existing ?? JournalEntry()..dayKey = key..createdAt = createdAt)
        ..shipped = shipped
        ..blockers = blockers
        ..tomorrow = tomorrow
        ..totalTrackedSeconds = totalSeconds;

      await db.writeTxn(() => db.journalEntrys.put(entry));
      state = AsyncData(entry);

      ref.invalidate(weekJournalsProvider);
      ref.invalidate(allJournalsProvider);
    } catch (e, stackTrace) {
      debugPrint('Error saving journal entry for date $arg: $e\n$stackTrace');
      rethrow;
    }
  }
}

final journalForDateProvider = AsyncNotifierProviderFamily<JournalForDateNotifier, JournalEntry?, String>(
  JournalForDateNotifier.new,
);

class JournalNotifier extends AsyncNotifier<JournalEntry?> {
  @override
  Future<JournalEntry?> build() async {
    final date = ref.watch(selectedJournalDateProvider);
    return ref.watch(journalForDateProvider(dayKey(date)).future);
  }

  Future<void> save({
    required String shipped,
    required String blockers,
    required String tomorrow,
  }) async {
    final date = ref.read(selectedJournalDateProvider);
    await ref.read(journalForDateProvider(dayKey(date)).notifier).save(
      shipped: shipped,
      blockers: blockers,
      tomorrow: tomorrow,
    );
  }
}

final journalNotifierProvider = AsyncNotifierProvider<JournalNotifier, JournalEntry?>(
  JournalNotifier.new,
);

// ── week entries for stats screen ────────────────────────────────────────────

final weekJournalsProvider = FutureProvider<List<JournalEntry>>((ref) async {
  try {
    final db = await DbService.db;
    final now = DateTime.now();
    final keys = List.generate(7, (i) {
      final d = now.subtract(Duration(days: i));
      return dayKey(d);
    });
    return await db.journalEntrys
        .filter()
        .anyOf(keys, (q, k) => q.dayKeyEqualTo(k))
        .findAll();
  } catch (e) {
    debugPrint('Error getting week journals: $e');
    return [];
  }
});

// ── all journal entries for history screen ───────────────────────────────────

final allJournalsProvider = FutureProvider<List<JournalEntry>>((ref) async {
  try {
    final db = await DbService.db;
    return await db.journalEntrys
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  } catch (e) {
    debugPrint('Error getting all journals: $e');
    return [];
  }
});
