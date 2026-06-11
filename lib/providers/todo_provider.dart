import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/todo_entry.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';

class TodoNotifier extends AsyncNotifier<List<TodoEntry>> {
  @override
  Future<List<TodoEntry>> build() async {
    try {
      final db = await DbService.db;
      return await db.todoEntrys.where()
          .sortByIsCompleted()
          .thenByIsHighPriorityDesc()
          .thenByCreatedAtDesc()
          .findAll();
    } catch (e, stackTrace) {
      debugPrint('Error loading todos: $e\n$stackTrace');
      return [];
    }
  }

  Future<void> addTodo(String title, bool isHighPriority, DateTime? dueDate) async {
    try {
      final db = await DbService.db;
      final todo = TodoEntry()
        ..title = title
        ..isCompleted = false
        ..isHighPriority = isHighPriority
        ..dueDate = dueDate
        ..createdAt = DateTime.now();

      await db.writeTxn(() => db.todoEntrys.put(todo));
      ref.invalidateSelf();
      await future; // wait for refresh to complete
      await _updateNotifications();
    } catch (e, stackTrace) {
      debugPrint('Error adding todo: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> toggleTodoCompletion(int id) async {
    try {
      final db = await DbService.db;
      final todo = await db.todoEntrys.get(id);
      if (todo == null) return;

      todo.isCompleted = !todo.isCompleted;
      todo.completedAt = todo.isCompleted ? DateTime.now() : null;

      await db.writeTxn(() => db.todoEntrys.put(todo));
      ref.invalidateSelf();
      await future;
      await _updateNotifications();
    } catch (e, stackTrace) {
      debugPrint('Error toggling todo: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final db = await DbService.db;
      await db.writeTxn(() => db.todoEntrys.delete(id));
      ref.invalidateSelf();
      await future;
      await _updateNotifications();
    } catch (e, stackTrace) {
      debugPrint('Error deleting todo: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> updateTodo(TodoEntry todo) async {
    try {
      final db = await DbService.db;
      await db.writeTxn(() => db.todoEntrys.put(todo));
      ref.invalidateSelf();
      await future;
      await _updateNotifications();
    } catch (e, stackTrace) {
      debugPrint('Error updating todo: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _updateNotifications() async {
    try {
      final db = await DbService.db;
      final pendingHighPriority = await db.todoEntrys.filter()
          .isCompletedEqualTo(false)
          .isHighPriorityEqualTo(true)
          .findAll();
      await NotificationService.updateTodoReminders(pendingHighPriority);
    } catch (e, stackTrace) {
      debugPrint('Error updating todo notifications: $e\n$stackTrace');
    }
  }
}

final todoProvider = AsyncNotifierProvider<TodoNotifier, List<TodoEntry>>(
  TodoNotifier.new,
);
