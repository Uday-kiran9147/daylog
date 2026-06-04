// lib/services/export_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'db_service.dart';
import '../models/task_entry.dart';
import '../models/journal_entry.dart';
import 'package:isar/isar.dart';

class ExportService {
  static Future<void> exportData() async {
    try {
      final db = await DbService.db;

      // Fetch all tasks
      final tasks = await db.taskEntrys.where().findAll();

      // Fetch all journals
      final journals = await db.journalEntrys.where().findAll();

      // Convert to Map
      final Map<String, dynamic> exportMap = {
        'exported_at': DateTime.now().toIso8601String(),
        'tasks': tasks.map((t) => {
          'id': t.id,
          'title': t.title,
          'category': t.category,
          'started_at': t.startedAt.toIso8601String(),
          'stopped_at': t.stoppedAt?.toIso8601String(),
          'duration_seconds': t.durationSeconds,
          'day_key': t.dayKey,
        }).toList(),
        'journals': journals.map((j) => {
          'id': j.id,
          'day_key': j.dayKey,
          'shipped': j.shipped,
          'blockers': j.blockers,
          'improved': j.improved,
          'tomorrow': j.tomorrow,
          'created_at': j.createdAt.toIso8601String(),
          'total_tracked_seconds': j.totalTrackedSeconds,
        }).toList(),
      };

      // Convert to JSON String
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportMap);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${tempDir.path}/daylog_backup_$dateStr.json');
      await file.writeAsString(jsonString);

      // Share file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'DayLog Data Export',
      );
    } catch (e, stackTrace) {
      debugPrint('Error exporting data: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<({int tasks, int journals})?> importData() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return null;

      final path = result.files.single.path;
      if (path == null) return null;

      final file = File(path);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final List<dynamic>? tasksData = data['tasks'];
      final List<dynamic>? journalsData = data['journals'];

      if (tasksData == null && journalsData == null) {
        throw const FormatException('Invalid backup file: missing tasks and journals.');
      }

      final db = await DbService.db;

      // Parse tasks
      final List<TaskEntry> tasksToPut = [];
      if (tasksData != null) {
        for (final item in tasksData) {
          final tMap = item as Map<String, dynamic>;
          final startedAt = DateTime.parse(tMap['started_at']);
          
          // Check if duplicate
          final isDuplicate = await db.taskEntrys
              .filter()
              .titleEqualTo(tMap['title'])
              .startedAtEqualTo(startedAt)
              .findFirst() != null;
              
          if (!isDuplicate) {
            final task = TaskEntry()
              ..title = tMap['title']
              ..category = tMap['category']
              ..startedAt = startedAt
              ..stoppedAt = tMap['stopped_at'] != null ? DateTime.parse(tMap['stopped_at']) : null
              ..durationSeconds = tMap['duration_seconds'] ?? 0;
            tasksToPut.add(task);
          }
        }
      }

      // Parse journals
      final List<JournalEntry> journalsToPut = [];
      if (journalsData != null) {
        for (final item in journalsData) {
          final jMap = item as Map<String, dynamic>;
          final key = jMap['day_key'];
          
          final existing = await db.journalEntrys.getByDayKey(key);
          final journal = (existing ?? JournalEntry())
            ..dayKey = key
            ..shipped = jMap['shipped'] ?? ''
            ..blockers = jMap['blockers'] ?? ''
            ..improved = jMap['improved'] ?? ''
            ..tomorrow = jMap['tomorrow'] ?? ''
            ..createdAt = DateTime.parse(jMap['created_at'])
            ..totalTrackedSeconds = jMap['total_tracked_seconds'] ?? 0;
            
          journalsToPut.add(journal);
        }
      }

      await db.writeTxn(() async {
        if (tasksToPut.isNotEmpty) {
          await db.taskEntrys.putAll(tasksToPut);
        }
        if (journalsToPut.isNotEmpty) {
          await db.journalEntrys.putAll(journalsToPut);
        }
      });
      return (tasks: tasksToPut.length, journals: journalsToPut.length);
    } catch (e, stackTrace) {
      debugPrint('Error importing data: $e\n$stackTrace');
      rethrow;
    }
  }
}
