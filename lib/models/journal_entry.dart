// lib/models/journal_entry.dart
import 'package:isar/isar.dart';

part 'journal_entry.g.dart';

@Collection()
class JournalEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String dayKey; // yyyy-MM-dd — one entry per day

  late String shipped;    // Q1: what did you do today?
  late String blockers;   // Q2: what slowed you down?
  late String tomorrow;   // Q3: what's the priority tomorrow?

  late DateTime createdAt;

  // total tracked seconds for the day (denormalized from tasks for quick reads)
  int totalTrackedSeconds = 0;
}
