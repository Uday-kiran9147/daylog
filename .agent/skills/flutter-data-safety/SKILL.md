---
name: flutter-data-safety
description: >
  Strict data-safety rules for Flutter/Isar projects. Must be read before
  touching any database service, migration, schema change, or recovery logic.
  Prevents accidental data loss from destructive API calls.
---

# Flutter Data Safety — Zero-Tolerance Rules

This skill enforces non-negotiable rules for working with local databases
(Isar, SQLite, Hive, etc.) in Flutter projects. Every rule here exists because
a real data-loss incident happened when these rules were violated.

---

## 🚨 ABSOLUTE PROHIBITIONS — Never Do These

### 1. Never call `close(deleteFromDisk: true)`
```dart
// ❌ FORBIDDEN — This permanently deletes the database file
await isar.close(deleteFromDisk: true);
```
This API call **destroys the entire database and all user data**. It is never
safe to call in recovery or error-handling code because:
- Errors during `Isar.open()` do not mean the data is corrupt — they often mean
  a schema version mismatch that can be fixed without touching the file.
- The user may have months of irreplaceable data in that file.

**There is no situation where this is acceptable in production code.**

---

### 2. Never delete `.isar`, `.isar.lock`, or any database file
```dart
// ❌ FORBIDDEN — Never delete user data files
await File('$dir/default.isar').delete();
await File('$dir/default.isar.lock').delete();
```
Even in a "recovery" path, file deletion is forbidden. If the database cannot
be opened, the correct action is to **surface the error to the user** and let
them decide — not to silently wipe their data.

---

### 3. Never write "auto-recovery" that deletes data
```dart
// ❌ FORBIDDEN — Recovery logic must NEVER be destructive
try {
  await Isar.open([...]);
} catch (e) {
  await deleteDatabase(); // ← This destroys data. Never do this.
}
```
Recovery logic may only:
- Log the error clearly.
- Try alternative open strategies (e.g., different name, subset of schemas).
- Show the user an error message.
- Suggest manual steps (e.g., export first, then clear data).

---

### 4. Never add a new collection to an existing `Isar.open()` call
```dart
// ❌ WRONG — Adding NewSchema to an existing open() breaks the database
_isar = await Isar.open(
  [ExistingSchemaA, ExistingSchemaB, NewSchema], // ← schema mismatch crash
  directory: dir.path,
);
```
Isar v3 validates collection IDs at open time. If the database file on disk
was created with a different set of schemas, it throws
`IllegalArg: Collection id is invalid`. This is **not a corrupt database** —
it is a version check. See the correct solution below.

---

## ✅ REQUIRED PATTERNS — Always Do These

### 1. New Isar collections → Always use a separate named database
When adding a new collection to an existing Isar project:

```dart
// ✅ CORRECT — New collection gets its own isolated file
static Future<Isar> _openTodos() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [TodoEntrySchema],          // Only the new schema
    directory: dir.path,
    name: 'todos',              // → creates todos.isar, never touches default.isar
  );
}
```

**Rule:** Every logically independent feature with new Isar schemas gets its
own `name:` parameter so it can never conflict with existing databases.

| File | Contents | Rule |
|------|----------|------|
| `default.isar` | Original collections | Never modify the schema list |
| `todos.isar` | New `TodoEntry` | Created fresh, no migration |
| `settings.isar` | New settings schema | Created fresh, no migration |

---

### 2. Deduplicate concurrent `Isar.open()` calls
Multiple Riverpod providers all call `DbService.db` at startup simultaneously.
Without a guard, this triggers multiple parallel `Isar.open()` calls which
crash with `Instance has already been opened`.

```dart
// ✅ CORRECT — Single shared Future ensures open() is only called once
static Future<Isar>? _openFuture;

static Future<Isar> get db async {
  if (_isar != null && _isar!.isOpen) return _isar!;
  _openFuture ??= _openMain();   // All concurrent callers share this one Future
  try {
    return await _openFuture!;
  } catch (e, st) {
    _openFuture = null;          // Reset only on failure so next call retries
    debugPrint('Failed to open database: $e\n$st');
    rethrow;
  }
}
```

---

### 3. On schema errors — log and surface, never destroy
```dart
// ✅ CORRECT — Inform, don't destroy
} catch (e) {
  debugPrint('Database schema mismatch: $e');
  // Show an error screen with a message like:
  // "Database version conflict detected. Please export your data first,
  //  then clear app storage in device Settings."
  container.read(appInitErrorProvider.notifier).state =
      'Database error: $e\n\nPlease export your data before clearing app storage.';
}
```

---

### 4. Always export before risky operations
Before any migration, schema change, or database restructuring, always guide
the user to export their data first:
- Confirm the export succeeded.
- Only then proceed with the structural change.
- Never make a structural database change irreversible without a backup step.

---

### 5. Test schema changes on a fresh install first
When adding new Isar schemas:
1. Test on a **fresh emulator** with no existing data first.
2. Then test on a device **with existing data** to confirm no crash.
3. Never ship a schema change that has only been tested on a clean install.

---

## Checklist Before Any Database Change

Before modifying `DbService`, adding an Isar schema, or writing any DB
recovery code, verify all of the following:

- [ ] Does this change call `close(deleteFromDisk: true)`? → **Remove it.**
- [ ] Does this change delete any `.isar` file? → **Remove it.**
- [ ] Am I adding a new schema to an existing `Isar.open()` call? → **Use a new named instance instead.**
- [ ] Could multiple callers hit `Isar.open()` concurrently? → **Add a `_openFuture ??=` guard.**
- [ ] Is there any "auto-recovery" that destroys data on error? → **Replace with an error message.**
- [ ] Has this been tested with existing data on a real device? → **Test before shipping.**

---

## Incident Record

**Date:** 2026-06-11  
**Cause:** Added `TodoEntry` to an existing `Isar.open()` call → schema ID
mismatch → recovery code called `close(deleteFromDisk: true)` → all user data
(tasks, journals) permanently deleted.  
**Correct fix:** `TodoEntry` should have been opened in a separate named Isar
instance (`name: 'todos'`) from the start, never added to the existing schema
list.
