// lib/services/notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _journalId = 1;
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
        body: 'Log today\'s notes & priorities in DayNote.',
        scheduledDate: _next9pm(),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daynote_reminder',
            'Daily DayNote reminder',
            channelDescription: 'Reminds you to write in your daily journal',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(
              'Log today\'s notes & priorities in DayNote.',
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

  static Future<void> cancelDailyReminder() async {
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
