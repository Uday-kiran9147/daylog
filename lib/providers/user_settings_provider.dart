// lib/providers/user_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_settings_service.dart';
import '../utils/constants.dart';

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(const UserSettings()) {
    _load();
  }

  Future<void> _load() async {
    final s = await UserSettingsService.loadSettings();
    state = s;
  }

  Future<void> completeOnboarding({
    required List<String> selectedCategories,
    double? dailyGoalHours,
  }) async {
    final updated = state.copyWith(
      hasCompletedOnboarding: true,
      selectedCategories: selectedCategories.isNotEmpty ? selectedCategories : kDefaultUserCategories,
      dailyGoalHours: dailyGoalHours ?? state.dailyGoalHours,
    );
    state = updated;
    await UserSettingsService.saveSettings(updated);
  }

  Future<void> updateSelectedCategories(List<String> categories) async {
    final updated = state.copyWith(
      selectedCategories: categories.isNotEmpty ? categories : kDefaultUserCategories,
    );
    state = updated;
    await UserSettingsService.saveSettings(updated);
  }

  Future<void> addCustomCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final custom = [...state.customCategories];
    if (!custom.contains(trimmed)) {
      custom.add(trimmed);
    }
    final selected = [...state.selectedCategories];
    if (!selected.contains(trimmed)) {
      selected.add(trimmed);
    }
    final updated = state.copyWith(
      customCategories: custom,
      selectedCategories: selected,
    );
    state = updated;
    await UserSettingsService.saveSettings(updated);
  }

  Future<void> removeCategory(String name) async {
    final selected = state.selectedCategories.where((c) => c != name).toList();
    final custom = state.customCategories.where((c) => c != name).toList();
    final updated = state.copyWith(
      selectedCategories: selected.isNotEmpty ? selected : ['General'],
      customCategories: custom,
    );
    state = updated;
    await UserSettingsService.saveSettings(updated);
  }

  Future<void> setDailyGoalHours(double hours) async {
    final updated = state.copyWith(dailyGoalHours: hours);
    state = updated;
    await UserSettingsService.saveSettings(updated);
  }

  Future<void> setReminders({bool? evening, bool? task}) async {
    final updated = state.copyWith(
      eveningReminderEnabled: evening ?? state.eveningReminderEnabled,
      taskReminderEnabled: task ?? state.taskReminderEnabled,
    );
    state = updated;
    await UserSettingsService.saveSettings(updated);
  }
}

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});

/// Returns only the active categories chosen by the user
final userCategoriesProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.selectedCategories.isNotEmpty
      ? settings.selectedCategories
      : kDefaultUserCategories;
});

/// Returns all available catalog categories plus any user-created custom categories
final allAvailableCategoriesProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(userSettingsProvider);
  final set = <String>{...kCategories, ...settings.customCategories};
  return set.toList();
});
