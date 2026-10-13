enum TodoPriority {
  none,
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TodoPriority.high:
        return 'High';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.none:
        return '';
    }
  }

  static TodoPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'high':
        return TodoPriority.high;
      case 'medium':
      case 'med':
        return TodoPriority.medium;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.none;
    }
  }
}

class TodoItem {
  static const int maxTextLength = 120;

  final String id;
  final String text;
  final bool isDone;
  final int order;
  final TodoPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoItem({
    required this.id,
    required this.text,
    this.isDone = false,
    this.order = 0,
    this.priority = TodoPriority.none,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isDone,
    int? order,
    TodoPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
      order: order ?? this.order,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isDone': isDone,
      'order': order,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    final created = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now();
    return TodoItem(
      id: map['id'] as String,
      text: map['text'] as String,
      isDone: map['isDone'] as bool? ?? false,
      order: map['order'] as int? ?? 0,
      priority: TodoPriority.fromString(map['priority'] as String?),
      createdAt: created,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? created,
    );
  }
}
