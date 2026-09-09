import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'app.dart';
import 'models/todo_entry.dart';
import 'providers/task_provider.dart';
import 'services/ad_service.dart';
import 'services/db_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init();
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
    await NotificationService.showActiveTaskNotification(activeTask);
    // await MarketingDataSeeder.seedIndieHackerData();
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    container.read(appInitErrorProvider.notifier).state = e.toString();
  }
}
