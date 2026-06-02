# DayLog — offline-first journal + time tracker

Flutter app. No backend. No auth. No internet required.

## Stack
- **Isar** — local embedded db (fast, no setup)
- **Riverpod** — state management
- **flutter_local_notifications** — 9pm daily journal reminder (no server)

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

> `build_runner` generates Isar schema files (`*.g.dart`) and Riverpod providers.
> Run it once after `pub get`, and again if you modify any `@Collection` model.

## Project structure

```
lib/
  main.dart                    # entry: init Isar + notifications
  app.dart                     # MaterialApp + bottom nav shell
  models/
    task_entry.dart            # @Collection — task with timer
    journal_entry.dart         # @Collection — daily journal (1 per day)
  providers/
    task_provider.dart         # active task, today's tasks, recent
    journal_provider.dart      # today's journal, week history
    stats_provider.dart        # weekly breakdown by category
  screens/
    home/home_screen.dart      # today overview + task list
    timer/
      timer_screen.dart        # live timer, stop/pause, quick-start
      start_task_sheet.dart    # bottom sheet: task name + category
    journal/journal_screen.dart # 3-question end-of-day form
    stats/stats_screen.dart    # weekly bar chart + insights
  services/
    db_service.dart            # Isar singleton
    notification_service.dart  # flutter_local_notifications setup
  utils/
    constants.dart             # theme, categories, colors
    date_utils.dart            # dayKey, formatDuration, formatTimer
```

## Categories
`backend` · `mobile` · `content` · `job hunt` · `other`

## Android permissions (AndroidManifest.xml additions)
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## iOS (Info.plist)
No extra keys needed for local notifications — handled by `flutter_local_notifications`.
