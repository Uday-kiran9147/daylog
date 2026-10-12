// lib/main_common.dart
// import 'package:daylog/utils/marketing_seed_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/flavor_config.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/revenue_cat_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'daynote/providers/daynote_providers.dart';

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
    await NotificationService.init();
    await NotificationService.scheduleDaily9pmReminder();

    // Initialize Firebase for optional DayNote cloud sync
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      container.read(firebaseInitializedProvider.notifier).state = true;
      debugPrint('Firebase initialized successfully for DayNote.');
    } catch (e) {
      debugPrint('Firebase initialization notice (running offline): $e');
      container.read(firebaseInitializedProvider.notifier).state = false;
    }
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    container.read(appInitErrorProvider.notifier).state = e.toString();
  }
}
