// lib/services/export_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
}
