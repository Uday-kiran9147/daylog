// lib/services/user_settings_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

class UserSettings {
  final bool hasCompletedOnboarding;
  final List<String> selectedCategories;
  final List<String> customCategories;
  final double dailyGoalHours;
  final String themeMode;
  final bool eveningReminderEnabled;
  final bool taskReminderEnabled;

  const UserSettings({
    this.hasCompletedOnboarding = false,
    this.selectedCategories = kDefaultUserCategories,
    this.customCategories = const [],
    this.dailyGoalHours = 4.0,
    this.themeMode = 'light',
    this.eveningReminderEnabled = true,
    this.taskReminderEnabled = true,
  });

  UserSettings copyWith({
    bool? hasCompletedOnboarding,
    List<String>? selectedCategories,
    List<String>? customCategories,
    double? dailyGoalHours,
    String? themeMode,
    bool? eveningReminderEnabled,
    bool? taskReminderEnabled,
  }) {
    return UserSettings(
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      customCategories: customCategories ?? this.customCategories,
      dailyGoalHours: dailyGoalHours ?? this.dailyGoalHours,
      themeMode: themeMode ?? this.themeMode,
      eveningReminderEnabled: eveningReminderEnabled ?? this.eveningReminderEnabled,
      taskReminderEnabled: taskReminderEnabled ?? this.taskReminderEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'selectedCategories': selectedCategories,
      'customCategories': customCategories,
      'dailyGoalHours': dailyGoalHours,
      'themeMode': themeMode,
      'eveningReminderEnabled': eveningReminderEnabled,
      'taskReminderEnabled': taskReminderEnabled,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          kDefaultUserCategories,
      customCategories: (json['customCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dailyGoalHours: (json['dailyGoalHours'] as num?)?.toDouble() ?? 4.0,
      themeMode: json['themeMode'] as String? ?? 'light',
      eveningReminderEnabled: json['eveningReminderEnabled'] as bool? ?? true,
      taskReminderEnabled: json['taskReminderEnabled'] as bool? ?? true,
    );
  }
}

class UserSettingsService {
  static const _fileName = 'daylog_user_settings.json';
  static UserSettings _cached = const UserSettings();
  static bool _isLoaded = false;

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<UserSettings> loadSettings() async {
    if (_isLoaded) return _cached;
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _cached = UserSettings.fromJson(json);
      } else {
        _cached = const UserSettings();
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading user settings: $e');
      _cached = const UserSettings();
    }
    return _cached;
  }

  static Future<void> saveSettings(UserSettings settings) async {
    _cached = settings;
    _isLoaded = true;
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (e) {
      debugPrint('Error saving user settings: $e');
    }
  }
}
