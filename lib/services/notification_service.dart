// lib/services/notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../app.dart';
import '../models/task_entry.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _journalId = 1;
  static const _reminderBaseId = 100;
  static const _remindersCount = 12; // 12 reminders of 2 hours = 24 hours
  static ProviderContainer? container;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      var timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier.trim();
      debugPrint('Device timezone identifier returned: "$timeZoneName"');
      
      const abbrevMap = {
        'ist': 'Asia/Kolkata',
        'jst': 'Asia/Tokyo',
        'gmt': 'Europe/London',
        'bst': 'Europe/London',
        'cet': 'Europe/Paris',
        'cest': 'Europe/Paris',
        'eet': 'Europe/Bucharest',
        'eest': 'Europe/Bucharest',
        'pst': 'America/Los_Angeles',
        'pdt': 'America/Los_Angeles',
        'mst': 'America/Denver',
        'mdt': 'America/Denver',
        'cst': 'America/Chicago',
        'cdt': 'America/Chicago',
        'est': 'America/New_York',
        'edt': 'America/New_York',
        'aest': 'Australia/Sydney',
        'aedt': 'Australia/Sydney',
        'awst': 'Australia/Perth',
      };
      
      final lowerTz = timeZoneName.toLowerCase();
      if (abbrevMap.containsKey(lowerTz)) {
        timeZoneName = abbrevMap[lowerTz]!;
        debugPrint('Mapped abbreviation "$lowerTz" to timezone: "$timeZoneName"');
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Successfully set local timezone to: "$timeZoneName"');
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
    _initialized = true;
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
            styleInformation: BigTextStyleInformation(
              'Log what you do today — takes 2 minutes.',
              contentTitle: 'Time to wrap up',
            ),
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

  static Future<void> updateTaskReminders(TaskEntry? activeTask) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized yet. Skipping task reminders update.');
      return;
    }
    try {
      // 1. Cancel any existing reminders
      for (int i = 0; i < _remindersCount; i++) {
        await _plugin.cancel(id: _reminderBaseId + i);
      }

      final now = tz.TZDateTime.now(tz.local);

      // 2. Schedule new reminders
      for (int i = 0; i < _remindersCount; i++) {
        // TO TEST: Change Duration(hours: (i + 1) * 2) to Duration(seconds: (i + 1) * 10)
        final duration = Duration(hours: (i + 1) * 2);
        // final duration = Duration(seconds: (i + 1) * 10); // 10s, 20s, 30s, etc.
        // print('Scheduling reminder in ${duration.inSeconds} seconds');
        final scheduledTime = now.add(duration);

        // Formats duration text automatically (e.g. "2 hours" or "10 seconds")
        final timeStr = duration.inHours > 0
            ? '${duration.inHours} hours'
            : '${duration.inSeconds} seconds';

        String title;
        String body;

        if (activeTask != null) {
          if (activeTask.isPaused) {
            title = 'Task Paused';
            body = 'Task "${activeTask.title}" has been paused for $timeStr. Ready to resume?';
          } else {
            title = 'Focus Check';
            if (duration.inHours == 2) {
              body = 'You\'ve been working on "${activeTask.title}" for 2 hours. Time for a quick stretch?';
            } else if (duration.inHours == 4) {
              body = 'You\'ve been working on "${activeTask.title}" for 4 hours. Take a screen break!';
            } else {
              body = 'You\'ve been working on "${activeTask.title}" for $timeStr. Make sure to rest!';
            }
          }
        } else {
          title = 'Track your progress';
          body = 'You haven\'t logged any tasks in the last $timeStr. Starting something new?';
        }

        await _plugin.zonedSchedule(
          id: _reminderBaseId + i,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'daylog_task_reminders',
              'Task Reminders',
              channelDescription: 'Reminds you about active, paused, or idle tasks every 2 hours',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(
                body,
                contentTitle: title,
              ),
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e, stack) {
      debugPrint('Failed to update task reminders: $e\n$stack');
    }
  }

  static Future<void> showTestNotification() async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized yet. Cannot show test notification.');
      return;
    }
    try {
      await _plugin.show(
        id: 999,
        title: 'Notification Test',
        body: 'If you see this, notifications are working and permission is granted!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daylog_test',
            'Test Channel',
            channelDescription: 'For testing instant notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            styleInformation: BigTextStyleInformation(
              'If you see this, notifications are working and permission is granted!',
              contentTitle: 'Notification Test',
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Failed to show test notification: $e\n$stack');
    }
  }
}
