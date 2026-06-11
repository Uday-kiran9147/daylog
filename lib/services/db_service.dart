import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_entry.dart';
import '../models/journal_entry.dart';
import '../models/todo_entry.dart';

class DbService {
  static Isar? _isar;
  static Future<Isar>? _openFuture;
  static bool _isClosing = false;

  static const _schemas = [TaskEntrySchema, JournalEntrySchema, TodoEntrySchema];
  static const _dbName = 'default';

  static Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    if (_isClosing) {
      // Wait for close to finish, then open fresh
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return _isClosing;
      });
    }
    _openFuture ??= _open();
    try {
      return await _openFuture!;
    } catch (e, st) {
      _isar = null;
      _openFuture = null;
      debugPrint('Failed to open database: $e\n$st');
      rethrow;
    }
  }

  static Future<Isar> _open() async {
    final dir = await getApplicationDocumentsDirectory();

    // ── Step 1: Return existing native instance if still open (hot restart) ───
    final existing = Isar.getInstance(_dbName);
    if (existing != null && existing.isOpen) {
      debugPrint('Reusing existing native instance: $_dbName');
      _isar = existing;
      return existing;
    }

    // ── Step 2: Close any stale named instances from old code ─────────────────
    for (final staleName in ['todos', _dbName]) {
      try {
        final stale = Isar.getInstance(staleName);
        if (stale != null && stale.isOpen) {
          await stale.close(deleteFromDisk: false);
          debugPrint('Closed stale instance: $staleName');
        }
      } catch (e) {
        debugPrint('Could not close stale instance "$staleName": $e');
      }
    }

    // ── Step 3: Delete legacy todos.isar files (never held user data) ─────────
    for (final fileName in ['todos.isar', 'todos.isar.lock']) {
      try {
        final f = File('${dir.path}/$fileName');
        if (await f.exists()) {
          await f.delete();
          debugPrint('Deleted legacy file: $fileName');
        }
      } catch (e) {
        debugPrint('Could not delete legacy file "$fileName": $e');
      }
    }

    // ── Step 4: Open the single unified database ───────────────────────────────
    try {
      _isar = await Isar.open(_schemas, directory: dir.path, name: _dbName);
      debugPrint('Database opened successfully.');
      return _isar!;
    } catch (e) {
      debugPrint('Database open failed, attempting recovery: $e');
    }

    // ── Step 5: Recovery — close any partial registration, then retry ─────────
    try {
      final partial = Isar.getInstance(_dbName);
      if (partial != null) {
        await partial.close(deleteFromDisk: false);
        debugPrint('Closed partially-registered instance.');
      }
    } catch (e) {
      debugPrint('Could not close partial instance: $e');
    }

    // Only delete default.isar as a last resort — this risks data loss.
    // In production, consider reporting this to your crash analytics instead.
    debugPrint('WARNING: Deleting default.isar as last resort — potential data loss.');
    for (final fileName in ['default.isar', 'default.isar.lock']) {
      try {
        final f = File('${dir.path}/$fileName');
        if (await f.exists()) {
          await f.delete();
          debugPrint('Deleted stale file: $fileName');
        }
      } catch (e) {
        debugPrint('Could not delete stale file "$fileName": $e');
      }
    }

    _isar = await Isar.open(_schemas, directory: dir.path, name: _dbName);
    debugPrint('Database recreated fresh successfully.');
    return _isar!;
  }

  static Future<void> close() async {
    if (_isClosing) return;
    _isClosing = true;
    try {
      if (_isar != null && _isar!.isOpen) {
        await _isar!.close();
        debugPrint('Database closed.');
      }
    } catch (e) {
      debugPrint('Failed to close database: $e');
    } finally {
      _isar = null;
      _openFuture = null;
      _isClosing = false;
    }
  }
}