import 'package:isar/isar.dart';

part 'todo_entry.g.dart';

@Collection()
class TodoEntry {
  Id id = Isar.autoIncrement;

  late String title;

  bool isCompleted = false;

  bool isHighPriority = false;

  DateTime? dueDate;

  late DateTime createdAt;
  DateTime? completedAt;
}
