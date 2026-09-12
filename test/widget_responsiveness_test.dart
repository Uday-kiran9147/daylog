import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daylog/models/task_entry.dart';
import 'package:daylog/models/todo_entry.dart';
import 'package:daylog/models/journal_entry.dart';
import 'package:daylog/providers/task_provider.dart';
import 'package:daylog/providers/todo_provider.dart';
import 'package:daylog/providers/stats_provider.dart';
import 'package:daylog/providers/journal_provider.dart';
import 'package:daylog/providers/user_settings_provider.dart';
import 'package:daylog/widgets/daylog_widgets.dart';
import 'package:daylog/screens/timer/start_task_sheet.dart';
import 'package:daylog/screens/timer/edit_task_sheet.dart';
import 'package:daylog/screens/todos/todos_screen.dart';
import 'package:daylog/screens/stats/stats_screen.dart';
import 'package:daylog/utils/constants.dart';

// Fake Todo Notifier for testing
class _FakeTodoNotifier extends TodoNotifier {
  final List<TodoEntry> _initial;
  _FakeTodoNotifier(this._initial);

  @override
  Future<List<TodoEntry>> build() async => _initial;
}

// Fake Active Task Notifier for testing
class _FakeActiveTaskNotifier extends ActiveTaskNotifier {
  final TaskEntry? _initial;
  _FakeActiveTaskNotifier(this._initial);

  @override
  Future<TaskEntry?> build() async => _initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSizes = <String, Size>{
    'Small Phone (320x568)': const Size(320, 568),
    'Standard Phone (390x844)': const Size(390, 844),
    'Large Phone (428x926)': const Size(428, 926),
    'Tablet (768x1024)': const Size(768, 1024),
  };

  group('Design System Widgets Responsiveness', () {
    for (final entry in testSizes.entries) {
      testWidgets('DaylogStatCard, CategoryTag, and Header render without overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: kLightTheme,
            home: Scaffold(
              body: SafeArea(
                child: ListView(
                  children: [
                    const DaylogPageHeader(
                      title: 'Very Long Page Header Title For Overflow Testing',
                      subtitle: 'Subtitle text describing the page contents with details',
                      showBackButton: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: const [
                          Expanded(
                            child: DaylogStatCard(
                              kicker: 'Tracked today',
                              value: '1h 45m',
                              isAccent: true,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: DaylogStatCard(
                              kicker: 'Tasks logged',
                              value: '12',
                              isAccent: false,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: DaylogStatCard(
                              kicker: 'Pending items',
                              value: '5',
                              isAccent: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          CategoryTag(category: 'Development'),
                          CategoryTag(category: 'System Design'),
                          CategoryTag(category: 'Very Long Custom Category Name Exceeding Normal Width'),
                          CategoryTag(category: 'Learning'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Floating Frosted Shell Confirmation Dialog Responsiveness', () {
    for (final entry in testSizes.entries) {
      testWidgets('showDaylogConfirmSheet adapts without overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: kDarkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDaylogConfirmSheet(
                        context: context,
                        title: 'Delete focus task with a very long descriptive confirmation title?',
                        message: 'Are you sure you want to delete this recorded session? This action cannot be undone and will remove it from your statistics.',
                        confirmLabel: 'Delete Permanently',
                        cancelLabel: 'Keep Task',
                        isDestructive: true,
                        icon: Icons.delete_outline_rounded,
                      );
                    },
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap to open sheet
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Verify sheet elements exist and no overflow occurred
        expect(find.text('Keep Task'), findsOneWidget);
        expect(find.text('Delete Permanently'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Tap cancel to close
        await tester.tap(find.text('Keep Task'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('StartTaskSheet Responsiveness & Action Items Quick Start', () {
    for (final entry in testSizes.entries) {
      testWidgets('StartTaskSheet displays category chips, pending action items without overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final sampleTodos = [
          TodoEntry()
            ..id = 1
            ..title = 'Refactor database service connection pool with extra long title for testing layout constraints'
            ..isCompleted = false
            ..isHighPriority = true
            ..createdAt = DateTime.now(),
          TodoEntry()
            ..id = 2
            ..title = 'Fix UI bug'
            ..isCompleted = false
            ..isHighPriority = false
            ..createdAt = DateTime.now(),
        ];

        final sampleTasks = [
          TaskEntry()
            ..id = 10
            ..title = 'System Architecture Design & Review'
            ..category = 'System Design'
            ..startedAt = DateTime.now().subtract(const Duration(hours: 2))
            ..durationSeconds = 3600,
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              todoProvider.overrideWith(() => _FakeTodoNotifier(sampleTodos)),
              recentTasksProvider.overrideWith((ref) => Future.value(sampleTasks)),
              userCategoriesProvider.overrideWith((ref) => ['Development', 'System Design', 'Learning', 'DSA']),
            ],
            child: MaterialApp(
              theme: kLightTheme,
              home: const Scaffold(
                body: StartTaskSheet(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('New focus session'), findsOneWidget);
        expect(find.text('From your action items'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('EditTaskSheet Responsiveness & Confirmation Trigger', () {
    for (final entry in testSizes.entries) {
      testWidgets('EditTaskSheet renders and triggers shell confirmation on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final sampleTask = TaskEntry()
          ..id = 42
          ..title = 'Optimizing Flutter list view performance and memory profiling'
          ..category = 'Development'
          ..startedAt = DateTime.now().subtract(const Duration(minutes: 45))
          ..durationSeconds = 2700;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userCategoriesProvider.overrideWith((ref) => ['Development', 'System Design', 'Learning']),
              activeTaskProvider.overrideWith(() => _FakeActiveTaskNotifier(null)),
            ],
            child: MaterialApp(
              theme: kDarkTheme,
              home: Scaffold(
                body: EditTaskSheet(task: sampleTask),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Edit Task'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Tap delete icon to trigger shell confirmation dialog
        final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
        expect(deleteIcon, findsOneWidget);
        await tester.tap(deleteIcon);
        await tester.pumpAndSettle();

        // Confirm shell dialog opened without overflow
        expect(find.text('Delete focus task?'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('TodosScreen Responsiveness', () {
    for (final entry in testSizes.entries) {
      testWidgets('TodosScreen renders items with flags and confirmation without overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final sampleTodos = [
          TodoEntry()
            ..id = 1
            ..title = 'Complete end-to-end integration test suite for cross-platform support'
            ..isCompleted = false
            ..isHighPriority = true
            ..dueDate = DateTime.now().add(const Duration(days: 2))
            ..createdAt = DateTime.now(),
          TodoEntry()
            ..id = 2
            ..title = 'Short task'
            ..isCompleted = true
            ..createdAt = DateTime.now(),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              todoProvider.overrideWith(() => _FakeTodoNotifier(sampleTodos)),
            ],
            child: MaterialApp(
              theme: kLightTheme,
              home: const TodosScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Action Items'), findsOneWidget);
        expect(find.text('To do'), findsOneWidget);
        expect(find.text('Done'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('StatsScreen Bar Chart & Category Breakdown Responsiveness', () {
    for (final entry in testSizes.entries) {
      testWidgets('StatsScreen bar chart and category list render without overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final now = DateTime.now();
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

        final sampleStats = List.generate(7, (i) {
          final d = startOfWeek.add(Duration(days: i));
          final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          return DayStats(
            dayKey: key,
            totalSeconds: (i + 1) * 720, // 12m, 24m, 36m, etc.
            byCategory: {
              'Development': (i + 1) * 500,
              'System Design': (i + 1) * 220,
            },
          );
        });

        final sampleJournals = [
          JournalEntry()
            ..id = 1
            ..dayKey = sampleStats.first.dayKey
            ..shipped = 'Shipped feature v1'
            ..blockers = ''
            ..improved = ''
            ..tomorrow = ''
            ..createdAt = DateTime.now(),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              weekStatsProvider.overrideWith((ref) => Future.value(sampleStats)),
              weekJournalsProvider.overrideWith((ref) => Future.value(sampleJournals)),
              activeTaskProvider.overrideWith(() => _FakeActiveTaskNotifier(null)),
            ],
            child: MaterialApp(
              theme: kDarkTheme,
              home: const StatsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Insights'), findsOneWidget);
        expect(find.text('Focus hours by day'), findsOneWidget);
        expect(find.text('By category this week'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Accessibility / Large Text Scale Factor Adaptiveness', () {
    testWidgets('UI elements adapt gracefully under 1.3x font scaling', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: kLightTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  DaylogStatCard(
                    kicker: 'Tracked today',
                    value: '2h 15m',
                    isAccent: true,
                  ),
                  SizedBox(height: 12),
                  CategoryTag(
                    category: 'System Design & Distributed Infrastructure Architecture',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
