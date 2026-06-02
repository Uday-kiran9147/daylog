import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_entry.dart';
import '../models/journal_entry.dart';

class DbService {
  static Isar? _isar;

  static Future<Isar> get db async {
    try {
      if (_isar != null && _isar!.isOpen) return _isar!;
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [TaskEntrySchema, JournalEntrySchema],
        directory: dir.path,
      );
      return _isar!;
    } catch (e, stackTrace) {
      debugPrint('Failed to open database: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<void> close() async {
    try {
      if (_isar != null && _isar!.isOpen) {
        await _isar!.close();
      }
    } catch (e) {
      debugPrint('Failed to close database: $e');
    }
  }
}
