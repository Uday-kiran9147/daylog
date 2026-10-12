import '../models/day_entry.dart';
import '../models/todo_item.dart';

abstract class DayNoteRepository {
  void setUserId(String? newUserId);
  Future<void> initialize();
  Future<DayEntry> getDayEntry(DateTime date);
  Future<void> saveDayEntry(DayEntry entry);
  Future<Set<String>> getDatesWithContent();
  Future<DayEntry> addTodo(DateTime date, String text, {TodoPriority priority = TodoPriority.none});
  Future<DayEntry> toggleTodo(DateTime date, String todoId);
  Future<DayEntry> updateTodoText(DateTime date, String todoId, String newText);
  Future<DayEntry> updateTodoPriority(DateTime date, String todoId, TodoPriority priority);
  Future<DayEntry> deleteTodo(DateTime date, String todoId);
  Future<DayEntry> reorderTodos(DateTime date, int oldIndex, int newIndex);
  Future<DayEntry> updateNote(DateTime date, String noteText);
  Future<bool> hasSeenOnboarding();
  Future<void> setOnboardingSeen(bool seen);
  Future<void> loadSampleData();
}
