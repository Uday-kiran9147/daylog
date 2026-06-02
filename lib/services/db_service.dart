// lib/services/db_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_entry.dart';
import '../models/journal_entry.dart';

class DbService {
  static Isar? _isar;

  static Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TaskEntrySchema, JournalEntrySchema],
      directory: dir.path,
    );
    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
  }
}
