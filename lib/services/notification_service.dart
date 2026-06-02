// lib/services/notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../app.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _journalId = 1;
  static ProviderContainer? container;

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Failed to initialize local timezone, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        if (container != null) {
          container!.read(navigationIndexProvider.notifier).state = 2; // Journal screen
        }
      },
    );

    // Request Android 13+ POST_NOTIFICATIONS permission
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Failed to request notifications permission: $e');
    }
  }

  static Future<void> scheduleDaily9pmReminder() async {
    try {
      await _plugin.zonedSchedule(
        id: _journalId,
        title: 'Time to wrap up',
        body: 'Log what you built today — takes 2 minutes.',
        scheduledDate: _next9pm(),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daylog_journal',
            'Daily journal reminder',
            channelDescription: 'Reminds you to fill in your end-of-day journal',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      );
    } catch (e, stack) {
      debugPrint('Failed to schedule notification: $e\n$stack');
    }
  }

  static Future<void> cancelJournalReminder() async {
    try {
      await _plugin.cancel(id: _journalId);
    } catch (e) {
      debugPrint('Failed to cancel reminder: $e');
    }
  }

  static tz.TZDateTime _next9pm() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
