import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/day_entry.dart';
import '../models/todo_item.dart';
import '../repositories/day_note_repository.dart';

class DayNoteViewModel extends ChangeNotifier {
  final DayNoteRepository repository;

  DateTime _selectedDate;
  DateTime _currentMonth;
  DayEntry _currentEntry;
  Set<String> _datesWithContent = {};
  bool _isLoading = true;
  bool _isAddingTodo = false;
  bool _isNoteFieldFocused = false;
  String? _errorMessage;

  bool _shouldShowOnboarding = false;
  bool _disposed = false;

  Timer? _noteDebounceTimer;

  bool get isDisposed => _disposed;

  DayNoteViewModel({required this.repository})
      : _selectedDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
        _currentMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        ),
        _currentEntry = DayEntry.empty(DateTime.now());

  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  DayEntry get currentEntry => _currentEntry;
  Set<String> get datesWithContent => _datesWithContent;
  bool get isLoading => _isLoading;
  bool get isAddingTodo => _isAddingTodo;
  bool get isNoteFieldFocused => _isNoteFieldFocused;
  String? get errorMessage => _errorMessage;
  bool get shouldShowOnboarding => _shouldShowOnboarding;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> init() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();

    try {
      await repository.initialize();
      if (_disposed) return;

      // Parallelize onboarding check, dates with content, and today's entry
      final results = await Future.wait([
        repository.hasSeenOnboarding(),
        repository.getDatesWithContent(),
        repository.getDayEntry(_selectedDate),
      ]);

      if (_disposed) return;
      _shouldShowOnboarding = !(results[0] as bool);
      _datesWithContent = results[1] as Set<String>;
      _currentEntry = results[2] as DayEntry;
    } catch (e) {
      if (_disposed) return;
      _errorMessage = 'Could not load journal entries: $e';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> dismissOnboarding({bool loadSampleData = false}) async {
    if (_disposed) return;
    await repository.setOnboardingSeen(true);
    if (_disposed) return;
    _shouldShowOnboarding = false;

    if (loadSampleData) {
      await repository.loadSampleData();
      if (_disposed) return;
      final results = await Future.wait([
        repository.getDatesWithContent(),
        repository.getDayEntry(_selectedDate),
      ]);
      if (_disposed) return;
      _datesWithContent = results[0] as Set<String>;
      _currentEntry = results[1] as DayEntry;
    }
    notifyListeners();
  }

  Future<void> updateUserContext(String? userId) async {
    if (_disposed) return;
    _flushNoteSave();
    repository.setUserId(userId);
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getDatesWithContent(),
        repository.getDayEntry(_selectedDate),
      ]);
      if (_disposed) return;
      _datesWithContent = results[0] as Set<String>;
      _currentEntry = results[1] as DayEntry;
    } catch (e) {
      if (_disposed) return;
      _errorMessage = 'Error loading user entries: $e';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _refreshDatesWithContent() async {
    if (_disposed) return;
    final dates = await repository.getDatesWithContent();
    if (_disposed) return;
    _datesWithContent = dates;
  }

  Future<void> _loadEntryForDate(DateTime date) async {
    if (_disposed) return;
    final entry = await repository.getDayEntry(date);
    if (_disposed) return;
    _currentEntry = entry;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    // Flush any pending note auto-save before changing dates
    _flushNoteSave();

    final normalized = DateTime(date.year, date.month, date.day);
    if (_selectedDate == normalized) return;

    _selectedDate = normalized;
    // Also sync month view if selected date is in a different month
    if (_currentMonth.year != normalized.year || _currentMonth.month != normalized.month) {
      _currentMonth = DateTime(normalized.year, normalized.month, 1);
    }

    _isAddingTodo = false;
    _isNoteFieldFocused = false;
    await _loadEntryForDate(_selectedDate);
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    notifyListeners();
  }

  void setMonthYear(int year, int month) {
    _currentMonth = DateTime(year, month, 1);
    notifyListeners();
  }

  Future<void> goToToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(today.year, today.month, 1);
    await selectDate(today);
  }

  void setAddingTodo(bool value) {
    _isAddingTodo = value;
    notifyListeners();
  }

  void setNoteFieldFocused(bool value) {
    _isNoteFieldFocused = value;
    notifyListeners();
  }

  void _syncDateIndicatorOptimistically(DateTime date, DayEntry entry) {
    final dateKey = DayEntry.formatDateKey(date);
    if (entry.hasContent) {
      _datesWithContent.add(dateKey);
    } else {
      _datesWithContent.remove(dateKey);
    }
  }

  /// Optimistic Add Todo: Updates UI instantly, rolls back if storage/sync fails.
  Future<void> addTodo(String text, {TodoPriority priority = TodoPriority.none}) async {
    var trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > TodoItem.maxTextLength) {
      trimmed = trimmed.substring(0, TodoItem.maxTextLength);
    }

    // 1. Snapshot previous state
    final previousEntry = _currentEntry;
    final previousDates = Set<String>.from(_datesWithContent);

    // 2. Apply optimistic update immediately
    final optimisticTodo = TodoItem(
      id: 'todo_temp_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isDone: false,
      order: _currentEntry.todos.length,
      priority: priority,
      createdAt: DateTime.now(),
    );

    final optimisticTodos = List<TodoItem>.from(_currentEntry.todos)..add(optimisticTodo);
    _currentEntry = _currentEntry.copyWith(
      todos: optimisticTodos,
      updatedAt: DateTime.now(),
    );
    _syncDateIndicatorOptimistically(_selectedDate, _currentEntry);
    notifyListeners(); // Immediate 0ms UI update!

    // 3. Persist in background
    try {
      final savedEntry = await repository.addTodo(_selectedDate, trimmed, priority: priority);
      if (_disposed) return;
      _currentEntry = savedEntry;
      await _refreshDatesWithContent();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      // Rollback on error
      _currentEntry = previousEntry;
      _datesWithContent = previousDates;
      _errorMessage = 'Failed to save todo. Reverted.';
      notifyListeners();
    }
  }

  /// Optimistic Toggle Todo: Toggles checkbox instantly, rolls back if storage/sync fails.
  Future<void> toggleTodo(String todoId) async {
    // 1. Snapshot previous state
    final previousEntry = _currentEntry;
    final previousDates = Set<String>.from(_datesWithContent);

    // 2. Apply optimistic toggle immediately
    final updatedTodos = _currentEntry.todos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(isDone: !todo.isDone);
      }
      return todo;
    }).toList();

    _currentEntry = _currentEntry.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );
    notifyListeners(); // Immediate 0ms UI update!

    // 3. Persist in background
    try {
      final savedEntry = await repository.toggleTodo(_selectedDate, todoId);
      if (_disposed) return;
      _currentEntry = savedEntry;
      await _refreshDatesWithContent();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      // Rollback on error
      _currentEntry = previousEntry;
      _datesWithContent = previousDates;
      _errorMessage = 'Failed to update todo status. Reverted.';
      notifyListeners();
    }
  }

  /// Optimistic Update Todo Text: Updates text instantly, rolls back if storage/sync fails.
  Future<void> updateTodoText(String todoId, String newText) async {
    var trimmed = newText.trim();
    if (trimmed.length > TodoItem.maxTextLength) {
      trimmed = trimmed.substring(0, TodoItem.maxTextLength);
    }

    // 1. Snapshot previous state
    final previousEntry = _currentEntry;

    // 2. Apply optimistic update immediately
    final updatedTodos = _currentEntry.todos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(text: trimmed);
      }
      return todo;
    }).toList();

    _currentEntry = _currentEntry.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );
    notifyListeners(); // Immediate 0ms UI update!

    // 3. Persist in background
    try {
      final savedEntry = await repository.updateTodoText(_selectedDate, todoId, trimmed);
      if (_disposed) return;
      _currentEntry = savedEntry;
      await _refreshDatesWithContent();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      // Rollback on error
      _currentEntry = previousEntry;
      _errorMessage = 'Failed to update todo text. Reverted.';
      notifyListeners();
    }
  }

  /// Optimistic Update Todo Priority: Updates priority instantly, rolls back if storage/sync fails.
  Future<void> updateTodoPriority(String todoId, TodoPriority priority) async {
    // 1. Snapshot previous state
    final previousEntry = _currentEntry;

    // 2. Apply optimistic update immediately
    final updatedTodos = _currentEntry.todos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(priority: priority);
      }
      return todo;
    }).toList();

    _currentEntry = _currentEntry.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );
    notifyListeners(); // Immediate 0ms UI update!

    // 3. Persist in background
    try {
      final savedEntry = await repository.updateTodoPriority(_selectedDate, todoId, priority);
      if (_disposed) return;
      _currentEntry = savedEntry;
      await _refreshDatesWithContent();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      // Rollback on error
      _currentEntry = previousEntry;
      _errorMessage = 'Failed to update priority. Reverted.';
      notifyListeners();
    }
  }

  /// Optimistic Delete Todo: Removes item instantly, rolls back if storage/sync fails.
  Future<void> deleteTodo(String todoId) async {
    // 1. Snapshot previous state
    final previousEntry = _currentEntry;
    final previousDates = Set<String>.from(_datesWithContent);

    // 2. Apply optimistic delete immediately
    final updatedTodos = _currentEntry.todos.where((t) => t.id != todoId).toList();
    _currentEntry = _currentEntry.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );
    _syncDateIndicatorOptimistically(_selectedDate, _currentEntry);
    notifyListeners(); // Immediate 0ms UI update!

    // 3. Persist in background
    try {
      final savedEntry = await repository.deleteTodo(_selectedDate, todoId);
      if (_disposed) return;
      _currentEntry = savedEntry;
      await _refreshDatesWithContent();
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      // Rollback on error
      _currentEntry = previousEntry;
      _datesWithContent = previousDates;
      _errorMessage = 'Failed to delete todo. Reverted.';
      notifyListeners();
    }
  }

  /// Optimistic Reorder Todos: Reorders instantly, rolls back if storage/sync fails.
  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    // 1. Snapshot previous state
    final previousEntry = _currentEntry;

    // 2. Apply optimistic reorder immediately
    final updatedTodos = List<TodoItem>.from(_currentEntry.todos);
    if (oldIndex < 0 || oldIndex >= updatedTodos.length) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = updatedTodos.removeAt(oldIndex);
    updatedTodos.insert(newIndex, item);

    final indexedTodos = [
      for (int i = 0; i < updatedTodos.length; i++)
        updatedTodos[i].copyWith(order: i)
    ];

    _currentEntry = _currentEntry.copyWith(
      todos: indexedTodos,
      updatedAt: DateTime.now(),
    );
    notifyListeners(); // Immediate 0ms UI update!

    // 3. Persist in background
    try {
      final savedEntry = await repository.reorderTodos(_selectedDate, oldIndex, newIndex);
      if (_disposed) return;
      _currentEntry = savedEntry;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      // Rollback on error
      _currentEntry = previousEntry;
      _errorMessage = 'Failed to reorder todos. Reverted.';
      notifyListeners();
    }
  }

  /// Optimistic Note Edit: Instant memory update + debounced persist with rollback on failure.
  void onNoteChanged(String newNote) {
    final previousEntrySnapshot = _currentEntry;
    final previousDatesSnapshot = Set<String>.from(_datesWithContent);
    final previousHadContent = _currentEntry.hasContent;

    _currentEntry = _currentEntry.copyWith(
      note: newNote,
      updatedAt: DateTime.now(),
    );
    _syncDateIndicatorOptimistically(_selectedDate, _currentEntry);

    _noteDebounceTimer?.cancel();
    _noteDebounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (_disposed) return;
      try {
        await repository.updateNote(_selectedDate, newNote);
        if (_disposed) return;
        final nowHasContent = _currentEntry.hasContent;
        if (previousHadContent != nowHasContent) {
          await _refreshDatesWithContent();
          notifyListeners();
        }
      } catch (e) {
        if (_disposed) return;
        _currentEntry = previousEntrySnapshot;
        _datesWithContent = previousDatesSnapshot;
        _errorMessage = 'Failed to save note. Reverted.';
        notifyListeners();
      }
    });
  }

  void _flushNoteSave() {
    if (_noteDebounceTimer?.isActive ?? false) {
      _noteDebounceTimer?.cancel();
      try {
        repository.updateNote(_selectedDate, _currentEntry.note);
        _refreshDatesWithContent();
      } catch (e) {
        debugPrint('Note flush save error: $e');
      }
    }
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _noteDebounceTimer?.cancel();
    super.dispose();
  }
}
