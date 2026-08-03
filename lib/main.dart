// lib/main.dart
import 'package:daylog/models/todo_entry.dart';
import 'package:daylog/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'app.dart';
import 'services/db_service.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  NotificationService.container = container;

  // Run the Flutter app immediately for sub-100ms startup!
  runApp(UncontrolledProviderScope(container: container, child: const DayLogApp()));

  // Initialize database and notifications concurrently in the background
  _initBackgroundServices(container);
}

Future<void> _initBackgroundServices(ProviderContainer container) async {
  try {
    final db = await DbService.db;
    await NotificationService.init();

    final pending = await db.todoEntrys
        .filter()
        .isCompletedEqualTo(false)
        .isHighPriorityEqualTo(true)
        .findAll();
    await NotificationService.updateTodoReminders(pending);

    await NotificationService.scheduleDaily9pmReminder();
    final activeTask = container.read(activeTaskProvider).valueOrNull;
    await NotificationService.updateTaskReminders(activeTask);
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    container.read(appInitErrorProvider.notifier).state = e.toString();
  }
}
