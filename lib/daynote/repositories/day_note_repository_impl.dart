import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/day_entry.dart';
import '../models/todo_item.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import 'day_note_repository.dart';

class DayNoteRepositoryImpl implements DayNoteRepository {
  final LocalStorageService _storageService;
  final FirestoreService? firestoreService;
  String? userId;

  DayNoteRepositoryImpl({
    LocalStorageService? storageService,
    this.firestoreService,
    this.userId,
  }) : _storageService = storageService ?? LocalStorageService();

  @override
  void setUserId(String? newUserId) {
    userId = newUserId;
  }

  @override
  Future<void> initialize() async {
    await _storageService.initSeedIfFirstRun();
  }

  @override
  Future<DayEntry> getDayEntry(DateTime date) async {
    final dateKey = DayEntry.formatDateKey(date);

    // 1. If user is authenticated and Firestore is available, attempt remote fetch
    if (userId != null && firestoreService != null) {
      try {
        final remoteEntry = await firestoreService!.getEntry(userId!, dateKey);
        if (remoteEntry != null) {
          // Cache locally
          await _storageService.saveEntry(remoteEntry);
          return remoteEntry;
        }
      } catch (e) {
        debugPrint('Firestore read error (falling back to local cache): $e');
      }
    }

    // 2. Fallback to local storage
    final localEntry = await _storageService.getEntry(dateKey);
    return localEntry ?? DayEntry.empty(date);
  }

  @override
  Future<void> saveDayEntry(DayEntry entry) async {
    // 1. Save locally for instant offline availability
    await _storageService.saveEntry(entry);

    // 2. Sync to Firestore remote DB if authenticated
    if (userId != null && firestoreService != null) {
      try {
        await firestoreService!.saveEntry(userId!, entry);
      } catch (e) {
        debugPrint('Firestore save error: $e');
      }
    }
  }

  @override
  Future<Set<String>> getDatesWithContent() async {
    // 1. If authenticated, fetch from Firestore and merge with local index
    if (userId != null && firestoreService != null) {
      try {
        final remoteDates = await firestoreService!.getDatesWithContent(userId!);
        if (remoteDates.isNotEmpty) {
          return remoteDates;
        }
      } catch (e) {
        debugPrint('Firestore getDates error (falling back to local): $e');
      }
    }

    return _storageService.getDatesWithContent();
  }

  @override
  Future<DayEntry> addTodo(DateTime date, String text, {TodoPriority priority = TodoPriority.none}) async {
    var trimmed = text.trim();
    if (trimmed.isEmpty) return getDayEntry(date);
    if (trimmed.length > TodoItem.maxTextLength) {
      trimmed = trimmed.substring(0, TodoItem.maxTextLength);
    }

    final current = await getDayEntry(date);
    final newTodo = TodoItem(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      text: trimmed,
      isDone: false,
      order: current.todos.length,
      priority: priority,
      createdAt: DateTime.now(),
    );

    final updatedTodos = List<TodoItem>.from(current.todos)..add(newTodo);
    final updatedEntry = current.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<DayEntry> toggleTodo(DateTime date, String todoId) async {
    final current = await getDayEntry(date);
    final updatedTodos = current.todos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(isDone: !todo.isDone);
      }
      return todo;
    }).toList();

    final updatedEntry = current.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<DayEntry> updateTodoText(DateTime date, String todoId, String newText) async {
    var trimmed = newText.trim();
    if (trimmed.length > TodoItem.maxTextLength) {
      trimmed = trimmed.substring(0, TodoItem.maxTextLength);
    }

    final current = await getDayEntry(date);
    final updatedTodos = current.todos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(text: trimmed);
      }
      return todo;
    }).toList();

    final updatedEntry = current.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<DayEntry> updateTodoPriority(DateTime date, String todoId, TodoPriority priority) async {
    final current = await getDayEntry(date);
    final updatedTodos = current.todos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(priority: priority);
      }
      return todo;
    }).toList();

    final updatedEntry = current.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<DayEntry> deleteTodo(DateTime date, String todoId) async {
    final current = await getDayEntry(date);
    final updatedTodos = current.todos.where((t) => t.id != todoId).toList();

    final updatedEntry = current.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<DayEntry> reorderTodos(DateTime date, int oldIndex, int newIndex) async {
    final current = await getDayEntry(date);
    final updatedTodos = List<TodoItem>.from(current.todos);
    if (oldIndex < 0 || oldIndex >= updatedTodos.length) return current;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = updatedTodos.removeAt(oldIndex);
    updatedTodos.insert(newIndex, item);

    final indexedTodos = [
      for (int i = 0; i < updatedTodos.length; i++)
        updatedTodos[i].copyWith(order: i)
    ];

    final updatedEntry = current.copyWith(
      todos: indexedTodos,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<DayEntry> updateNote(DateTime date, String noteText) async {
    final current = await getDayEntry(date);
    final updatedEntry = current.copyWith(
      note: noteText,
      updatedAt: DateTime.now(),
    );

    await saveDayEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  Future<bool> hasSeenOnboarding() {
    return _storageService.hasSeenOnboarding();
  }

  @override
  Future<void> setOnboardingSeen(bool seen) {
    return _storageService.setOnboardingSeen(seen);
  }

  @override
  Future<void> loadSampleData() async {
    await _storageService.seedSampleData();
  }
}
