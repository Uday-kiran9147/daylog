import 'dart:convert';
import 'todo_item.dart';

class DayEntry {
  final String dateKey; // Format: YYYY-MM-DD
  final List<TodoItem> todos;
  final String note;
  final DateTime updatedAt;

  const DayEntry({
    required this.dateKey,
    this.todos = const [],
    this.note = '',
    required this.updatedAt,
  });

  bool get isEmpty => todos.isEmpty && note.trim().isEmpty;
  bool get hasContent => !isEmpty;
  int get completedTodosCount => todos.where((t) => t.isDone).length;
  int get totalTodosCount => todos.length;

  static String formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  factory DayEntry.empty(DateTime date) {
    return DayEntry(
      dateKey: formatDateKey(date),
      todos: const [],
      note: '',
      updatedAt: DateTime.now(),
    );
  }

  DayEntry copyWith({
    String? dateKey,
    List<TodoItem>? todos,
    String? note,
    DateTime? updatedAt,
  }) {
    return DayEntry(
      dateKey: dateKey ?? this.dateKey,
      todos: todos ?? this.todos,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'todos': todos.map((x) => x.toMap()).toList(),
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DayEntry.fromMap(Map<String, dynamic> map) {
    return DayEntry(
      dateKey: map['dateKey'] as String,
      todos: (map['todos'] as List<dynamic>? ?? [])
          .map((x) => TodoItem.fromMap(x as Map<String, dynamic>))
          .toList(),
      note: map['note'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DayEntry.fromJson(String source) =>
      DayEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
