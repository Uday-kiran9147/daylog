# DayLog — Offline-First Journal & Focus Tracker

DayLog is a minimalist, privacy-focused Flutter application designed for developers. It enables offline focus tracking, session logging, and daily reflections with zero cloud storage, accounts, or internet dependencies.

---

## 🌟 Key Features

* **Focus Timer**: Start, pause, resume, and log task sessions. Includes quick suggestion chips generated from your most recent activities.
* **Auto-Category Detection**: Automatically parses task names to categorize them into relevant focus areas (e.g. coding detects `development`, interview prep detects `job hunt`).
* **Structured Daily Journal**: Log your progress, obstacles, self-improvements, and next-day priorities with a 4-question daily reflection.
* **Yesterday's Priority Integration**: Highlights yesterday's planned priorities directly in today's journal screen to keep you accountable.
* **Vibrant Charts & Statistics**: Displays a daily focus hours bar chart, weekly category progress breakdown, and top-focus insights.
* **Local Data Portability**: Export and import your entire data log (tasks and journals) using native file managers and sharing tools.
* **Timezone-Aligned Alarms**: Daily 9:00 PM wrap-up notifications adjusted dynamically to the device's native local timezone.

---

## 🛠️ Technology Stack

* **Flutter (Dart)** — Application framework
* **Isar Database** — Super fast, offline-first NoSQL embedded local database
* **Riverpod** — Declarative state management and reactive data provider queries
* **Flutter Local Notifications** — Local push notification scheduling
* **Flutter Timezone & Timezone** — Native device timezone resolution and DST handling
* **File Picker & Share Plus** — Local backups (JSON import/export) and data sharing

---

## 🚀 Setup & Installation

### Prerequisites
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Build Steps

1. **Clone the repository** and navigate to the directory:
   ```bash
   cd daylog
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate database schemas and Riverpod code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 📂 Project Directory Structure

```
lib/
  main.dart                    # Entry point (initializes services & starts UI)
  app.dart                     # Main MaterialApp wrapper with dark/light themes
  models/
    task_entry.dart            # Isar model for individual timed focus tasks
    journal_entry.dart         # Isar model for structured daily reflections
  providers/
    task_provider.dart         # Active timer states, completed list, and suggest algorithms
    journal_provider.dart      # Reflections fetcher, save states, and selected day index
    stats_provider.dart        # Weekly totals and breakdown computations
    theme_provider.dart        # Theme mode state (light, dark, or system default)
  screens/
    home/
      home_screen.dart         # Completed list, active session banner, stats summary, import/export
    timer/
      timer_screen.dart        # Fullscreen timer, quick start, and control triggers
      start_task_sheet.dart    # Task startup sheet with auto-category regex detection
      edit_task_sheet.dart     # Manual task updates and category modification
    journal/
      journal_screen.dart      # reflection form + yesterday's priority reminder
      journal_history_screen.dart # Detailed feed of past reflections
    stats/
      stats_screen.dart        # Focus bar charts, weekly progress, and focus insights
  services/
    db_service.dart            # Isar database initialization singleton
    notification_service.dart  # Native channel alarms and local timezone setup
    export_service.dart        # Data importer/exporter (JSON encoding & file picker)
  utils/
    constants.dart             # Curated color tokens, categories, and typography
    date_utils.dart            # Specialized helpers for duration formatting & time display
```

---

## 🔒 Permissions Configuration

### Android (`AndroidManifest.xml`)
The application adds the following permissions for background notification alarms:
```xml
<!-- Required to reschedule alarms on phone boot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<!-- Required for exact daily 9 PM reminder scheduling -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<!-- Required for notifications on Android 13+ -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS (`Info.plist`)
Local notifications are handled internally by the native iOS UserNotification framework (no external remote push notification keys required).
```
