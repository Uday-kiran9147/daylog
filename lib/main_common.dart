// lib/main_common.dart
// import 'package:daylog/utils/marketing_seed_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'app.dart';
import 'config/flavor_config.dart';
import 'models/todo_entry.dart';
import 'providers/task_provider.dart';
import 'services/ad_service.dart';
import 'services/db_service.dart';
import 'services/notification_service.dart';
import 'services/revenue_cat_service.dart';

/// Common bootstrap logic for all app flavors.
Future<void> mainCommon(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.instance = config;
  await FlavorConfig.loadAppInfo();

  // Try loading flavor-specific env file, falling back to default '.env'
  try {
    await dotenv.load(fileName: config.envFileName);
  } catch (e) {
    debugPrint('Could not load ${config.envFileName}, falling back to .env: $e');
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Could not load .env file: $e');
    }
  }

  await RevenueCatService.init();
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
    // MarketingDataSeeder.seedIndieHackerData();
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    container.read(appInitErrorProvider.notifier).state = e.toString();
  }
}
