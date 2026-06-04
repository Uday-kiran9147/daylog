# Claude Guide: AI Assistant Guidelines for DayLog

Welcome, AI coder! This guide explains the architecture, dependencies, and code patterns of the DayLog application to help you make safe, clean, and consistent edits.

---

## 🛠️ Code Generation & Database Schemas

DayLog uses **Isar** as its embedded local database and **Riverpod** for state management. Both libraries rely on code generation.

### Important Commands

If you modify database models (`lib/models/*.dart`) or Riverpod annotations, you **MUST** regenerate the part files:

```bash
# Run the build runner to regenerate part (.g.dart) files
dart run build_runner build --delete-conflicting-outputs
```

Always run `flutter analyze` after code generation to ensure everything builds correctly.

---

## 📁 Key Components & Code Patterns

### 1. Modifying Categories
Categories are used for grouping tasks and displaying statistics:
* **Definitions**: Managed in [constants.dart](file:///C:/flutter%20festival/daylog/lib/utils/constants.dart) via `kCategories` (list of strings) and `kCategoryColors` (map of string categories to `Color` tokens).
* **Auto-detection**: Located in [start_task_sheet.dart](file:///C:/flutter%20festival/daylog/lib/screens/timer/start_task_sheet.dart). If you add or modify a category, update the `_onTextChanged()` method’s keyword matching regular expressions.
* **Capitalization**: Helper `capitalizeCategory()` in [constants.dart](file:///C:/flutter%20festival/daylog/lib/utils/constants.dart) formats abbreviation categories (like `dsa` to `DSA`) and capitalizes words.

### 2. Modifying Journal Questions
The end-of-day journal asks the user multiple structured questions:
* **Model**: Add the new field to the `JournalEntry` class in [journal_entry.dart](file:///C:/flutter%20festival/daylog/lib/models/journal_entry.dart) and run `build_runner`.
* **State & Saver**: Update the `save()` signature and data binding inside [journal_provider.dart](file:///C:/flutter%20festival/daylog/lib/providers/journal_provider.dart).
* **Form UI**: Modify [journal_screen.dart](file:///C:/flutter%20festival/daylog/lib/screens/journal/journal_screen.dart):
  * Define a new `TextEditingController` inside `_JournalScreenState`.
  * Ensure the controller is disposed and cleared in `dispose()` and reset logic.
  * Render a new `_QuestionCard` inside the ListView.
  * Update `_SavedView` (which is a `ConsumerWidget`) to display the new saved section.
* **History UI**: Update the detailed journal overlay dialog in [journal_history_screen.dart](file:///C:/flutter%20festival/daylog/lib/screens/journal/journal_history_screen.dart) to show the new saved question.
* **Data Portability**: Add the new field mapping inside [export_service.dart](file:///C:/flutter%20festival/daylog/lib/services/export_service.dart) to prevent backup data loss.

### 3. Native File Picker (v11+)
DayLog uses the `file_picker` package for data import:
* Starting with version 11, the package uses static methods. **Do NOT use** `FilePicker.platform.pickFiles()`.
* **Correct Syntax**:
  ```dart
  final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
  ```

### 4. Local Timezone & Notifications
* Native timezone lookup is handled via the `flutter_timezone` package.
* Standard timezone abbreviations (like `"IST"`, `"GMT"`, `"PST"`) are not natively recognized as IANA locations by the `timezone` package and will crash initialization.
* Map any unrecognized timezone abbreviations inside the `abbrevMap` in the `init()` method of [notification_service.dart](file:///C:/flutter%20festival/daylog/lib/services/notification_service.dart).

---

## 🎨 Styling & Design Aesthetics
* **Theme**: DayLog supports custom Light and Dark themes with typography using the `Inter` font.
* **Colors**: Avoid standard raw material colors. Use the curated tokens defined in `ColorScheme` or `kCategoryColors`.
* **Aesthetics**: UI sections use rounded border cards (`BorderRadius.circular(12)`), smooth margins, high-contrast typography, and tabular figures for timer displays to prevent layout shifting.
