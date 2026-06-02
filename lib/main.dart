// lib/main.dart
import 'package:daylog/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future.wait([
    DbService.db,
    NotificationService.init().then((_) {
      NotificationService.scheduleDaily9pmReminder();
      final activeTask = container.read(activeTaskProvider).valueOrNull;
      NotificationService.updateTaskReminders(activeTask);
    }),
  ]).catchError((e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    container.read(appInitErrorProvider.notifier).state = e.toString();
    return [];
  });
}
