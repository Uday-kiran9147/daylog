// lib/utils/marketing_seed_data.dart
import 'package:flutter/material.dart';
import '../models/task_entry.dart';
import '../models/todo_entry.dart';
import '../models/journal_entry.dart';
import '../services/db_service.dart';

class MarketingDataSeeder {
  static Future<void> seedIndieHackerData() async {
    final db = await DbService.db;
    final now = DateTime.now();

    await db.writeTxn(() async {
      // 1. Clear previous sample data (optional)
      await db.taskEntrys.clear();
      await db.todoEntrys.clear();
      await db.journalEntrys.clear();

      // 2. Insert Active Ticking Task
      final activeTask = TaskEntry()
        ..title = 'Redesigning Checkout Funnel & Stripe Webhooks'
        ..category = 'Coding & Development'
        ..startedAt = now.subtract(const Duration(hours: 1, minutes: 42, seconds: 18))
        ..stoppedAt = null
        ..durationSeconds = 0;
      await db.taskEntrys.put(activeTask);

      // 3. Insert Completed Tasks for Today
      final completedTasks = [
        TaskEntry()
          ..title = 'Drafting Product Hunt Launch Copy & Teaser Video'
          ..category = 'Writing & Content'
          ..startedAt = now.subtract(const Duration(hours: 5))
          ..stoppedAt = now.subtract(const Duration(hours: 2, minutes: 50))
          ..durationSeconds = 7800, // 2h 10m
        TaskEntry()
          ..title = 'User Interview Synthesis (5 Beta Customers)'
          ..category = 'Product Strategy'
          ..startedAt = now.subtract(const Duration(hours: 7))
          ..stoppedAt = now.subtract(const Duration(hours: 5, minutes: 45))
          ..durationSeconds = 4500, // 1h 15m
        TaskEntry()
          ..title = 'Fixing Edge-Case Auth Refresh Token Bug'
          ..category = 'Debugging'
          ..startedAt = now.subtract(const Duration(hours: 8))
          ..stoppedAt = now.subtract(const Duration(hours: 7, minutes: 15))
          ..durationSeconds = 2700, // 45m
      ];
      await db.taskEntrys.putAll(completedTasks);

      // 4. Insert Todos
      final todos = [
        TodoEntry()
          ..title = 'Deploy v2.4.0 hotfix to Production'
          ..isHighPriority = true
          ..isCompleted = false
          ..dueDate = now.add(const Duration(hours: 4))
          ..createdAt = now.subtract(const Duration(hours: 6)),
        TodoEntry()
          ..title = 'Submit iOS build to App Store Review'
          ..isHighPriority = true
          ..isCompleted = false
          ..dueDate = now.add(const Duration(days: 1))
          ..createdAt = now.subtract(const Duration(hours: 4)),
        TodoEntry()
          ..title = 'Record 60s product demo trailer for X'
          ..isHighPriority = true
          ..isCompleted = false
          ..dueDate = now.add(const Duration(days: 2))
          ..createdAt = now.subtract(const Duration(hours: 2)),
        TodoEntry()
          ..title = 'Email early-access invites to top 50 waitlist users'
          ..isHighPriority = false
          ..isCompleted = true
          ..completedAt = now.subtract(const Duration(hours: 1))
          ..createdAt = now.subtract(const Duration(hours: 8)),
        TodoEntry()
          ..title = 'Update landing page pricing comparison table'
          ..isHighPriority = false
          ..isCompleted = false
          ..dueDate = now.add(const Duration(days: 3))
          ..createdAt = now.subtract(const Duration(hours: 3)),
      ];
      await db.todoEntrys.putAll(todos);

      // 5. Insert Journal Entry
      final dayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final journal = JournalEntry()
        ..dayKey = dayKey
        ..shipped = 'Finalized the self-serve subscription upgrade workflow with Stripe webhooks and fixed a critical auth token race condition. Onboarded 5 new beta testers with zero onboarding drop-offs.'
        ..blockers = 'Context-switching between ad-hoc customer emails and core backend logic during midday. Need to batch inbox processing strictly at 4:30 PM.'
        ..improved = 'Discovered that indexing composite foreign keys on the session table shaved ~180ms off query latency.'
        ..tomorrow = 'Record the launch video and submit build 1.4 to App Store TestFlight.'
        ..totalTrackedSeconds = 21180 // 5h 53m
        ..createdAt = now;
      await db.journalEntrys.put(journal);
    });

    debugPrint('✨ Marketing sample data seeded successfully!');
  }
}