import 'dart:convert';
import 'todo_item.dart';

class DayEntry {
  final String dateKey; // Format: YYYY-MM-DD
  final List<TodoItem> todos;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? noteCreatedAt;
  final DateTime? noteUpdatedAt;

  const DayEntry({
    required this.dateKey,
    this.todos = const [],
    this.note = '',
    DateTime? createdAt,
    required this.updatedAt,
    this.noteCreatedAt,
    this.noteUpdatedAt,
  }) : createdAt = createdAt ?? updatedAt;

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
    final now = DateTime.now();
    return DayEntry(
      dateKey: formatDateKey(date),
      todos: const [],
      note: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  DayEntry copyWith({
    String? dateKey,
    List<TodoItem>? todos,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? noteCreatedAt,
    DateTime? noteUpdatedAt,
    bool clearNoteTimestamps = false,
  }) {
    return DayEntry(
      dateKey: dateKey ?? this.dateKey,
      todos: todos ?? this.todos,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      noteCreatedAt: clearNoteTimestamps ? null : (noteCreatedAt ?? this.noteCreatedAt),
      noteUpdatedAt: clearNoteTimestamps ? null : (noteUpdatedAt ?? this.noteUpdatedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'todos': todos.map((x) => x.toMap()).toList(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (noteCreatedAt != null) 'noteCreatedAt': noteCreatedAt!.toIso8601String(),
      if (noteUpdatedAt != null) 'noteUpdatedAt': noteUpdatedAt!.toIso8601String(),
    };
  }

  factory DayEntry.fromMap(Map<String, dynamic> map) {
    final updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now();
    final createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? updatedAt;
    final noteCreatedAt = DateTime.tryParse(map['noteCreatedAt'] as String? ?? '');
    final noteUpdatedAt = DateTime.tryParse(map['noteUpdatedAt'] as String? ?? '');
    return DayEntry(
      dateKey: map['dateKey'] as String,
      todos: (map['todos'] as List<dynamic>? ?? [])
          .map((x) => TodoItem.fromMap(x as Map<String, dynamic>))
          .toList(),
      note: map['note'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      noteCreatedAt: noteCreatedAt,
      noteUpdatedAt: noteUpdatedAt,
    );
  }

  String toJson() => json.encode(toMap());

  factory DayEntry.fromJson(String source) =>
      DayEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
