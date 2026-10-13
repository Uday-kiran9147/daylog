import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_entry.dart';
import '../models/todo_item.dart';

class LocalStorageService {
  static const String _keyPrefix = 'daynote_entry_';
  static const String _indexKey = 'daynote_saved_dates_index';
  static const String _onboardingSeenKey = 'daynote_has_seen_onboarding';

  static SharedPreferences? _cachedPrefs;

  static void resetCache() {
    _cachedPrefs = null;
  }

  Future<SharedPreferences> get _prefs async {
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  Future<void> initSeedIfFirstRun() async {
    // Fresh start: no automatic seeded data
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingSeenKey, seen);
  }

  Future<void> seedSampleData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Sample Today Entry
    final todayEntry = DayEntry(
      dateKey: DayEntry.formatDateKey(today),
      todos: [
        TodoItem(
          id: 'todo_sample_1',
          text: 'Explore the month & year calendar navigation',
          isDone: false,
          order: 0,
          priority: TodoPriority.high,
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
        TodoItem(
          id: 'todo_sample_2',
          text: 'Write today\'s thoughts in the journal notes',
          isDone: false,
          order: 1,
          priority: TodoPriority.medium,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        TodoItem(
          id: 'todo_sample_3',
          text: 'Organize key tasks and set priorities',
          isDone: false,
          order: 2,
          priority: TodoPriority.low,
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      ],
      note: 'Welcome to your DayLog planner!\n\nThis is your quiet, distraction-free space for daily reflections, plans, and moments of clarity. Select any date on the calendar above to begin keeping your daily record.',
      createdAt: now.subtract(const Duration(hours: 4)),
      updatedAt: now,
      noteCreatedAt: now.subtract(const Duration(hours: 4)),
      noteUpdatedAt: now,
    );

    // Sample Yesterday Entry
    final yesterdayEntry = DayEntry(
      dateKey: DayEntry.formatDateKey(yesterday),
      todos: [
        TodoItem(
          id: 'todo_sample_4',
          text: 'Review creative design ideas and sketches',
          isDone: true,
          order: 0,
          priority: TodoPriority.medium,
          createdAt: yesterday.add(const Duration(hours: 10)),
          updatedAt: yesterday.add(const Duration(hours: 12)),
        ),
        TodoItem(
          id: 'todo_sample_5',
          text: 'Take a quiet 20-minute evening walk',
          isDone: true,
          order: 1,
          priority: TodoPriority.low,
          createdAt: yesterday.add(const Duration(hours: 18)),
          updatedAt: yesterday.add(const Duration(hours: 19)),
        ),
      ],
      note: '"Simplicity is the ultimate sophistication." — Leonardo da Vinci\n\nA calm evening reflecting on the week\'s creative work and personal milestones.',
      createdAt: yesterday.add(const Duration(hours: 9)),
      updatedAt: yesterday.add(const Duration(hours: 20)),
      noteCreatedAt: yesterday.add(const Duration(hours: 9)),
      noteUpdatedAt: yesterday.add(const Duration(hours: 20)),
    );

    await saveEntry(todayEntry);
    await saveEntry(yesterdayEntry);
  }

  Future<DayEntry?> getEntry(String dateKey) async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString('$_keyPrefix$dateKey');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return DayEntry.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveEntry(DayEntry entry) async {
    final prefs = await _prefs;
    final dateKey = entry.dateKey;
    final index = await getDatesWithContent();

    if (entry.isEmpty) {
      await prefs.remove('$_keyPrefix$dateKey');
      if (index.contains(dateKey)) {
        index.remove(dateKey);
        await prefs.setStringList(_indexKey, index.toList());
      }
    } else {
      await prefs.setString('$_keyPrefix$dateKey', entry.toJson());
      if (!index.contains(dateKey)) {
        index.add(dateKey);
        await prefs.setStringList(_indexKey, index.toList());
      }
    }
  }

  Future<Set<String>> getDatesWithContent() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_indexKey) ?? [];
    return list.toSet();
  }
}
