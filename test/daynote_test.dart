import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daylog/app.dart';
import 'package:daylog/config/flavor_config.dart';
import 'package:daylog/utils/constants.dart';
import 'package:daylog/daynote/models/day_entry.dart';
import 'package:daylog/daynote/models/todo_item.dart';
import 'package:daylog/daynote/repositories/day_note_repository_impl.dart';
import 'package:daylog/daynote/services/local_storage_service.dart';
import 'package:daylog/daynote/services/mock_auth_service.dart';
import 'package:daylog/daynote/theme/daynote_theme.dart';
import 'package:daylog/daynote/viewmodels/auth_viewmodel.dart';
import 'package:daylog/daynote/viewmodels/day_note_viewmodel.dart';
import 'package:daylog/daynote/widgets/details_sheet.dart';

class _FailingDayNoteRepository extends DayNoteRepositoryImpl {
  @override
  Future<void> initialize() async {}

  @override
  Future<DayEntry> getDayEntry(DateTime date) async {
    return DayEntry.empty(date);
  }

  @override
  Future<Set<String>> getDatesWithContent() async {
    return {};
  }

  @override
  Future<DayEntry> addTodo(DateTime date, String text, {TodoPriority priority = TodoPriority.none}) async {
    throw Exception('Simulated write failure');
  }

  @override
  Future<DayEntry> toggleTodo(DateTime date, String todoId) async {
    throw Exception('Simulated toggle failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('DayNoteViewModel Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LocalStorageService.resetCache();
    });

    test('DayNoteViewModel initializes and handles todo/note operations correctly', () async {
      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.selectedDate, isNotNull);

      // Fresh state
      expect(viewModel.currentEntry.todos.isEmpty, isTrue);

      // Add todo with priority
      await viewModel.addTodo('Buy fountain pen ink', priority: TodoPriority.high);
      expect(viewModel.currentEntry.todos.length, equals(1));
      expect(viewModel.currentEntry.todos.first.text, equals('Buy fountain pen ink'));
      expect(viewModel.currentEntry.todos.first.isDone, isFalse);
      expect(viewModel.currentEntry.todos.first.priority, equals(TodoPriority.high));

      // Limit length
      final overlyLongText = 'A' * 200;
      await viewModel.addTodo(overlyLongText);
      expect(viewModel.currentEntry.todos.last.text.length, equals(TodoItem.maxTextLength));
      expect(viewModel.currentEntry.todos.last.text, equals('A' * TodoItem.maxTextLength));

      // Update priority
      final todoId = viewModel.currentEntry.todos.first.id;
      await viewModel.updateTodoPriority(todoId, TodoPriority.medium);
      expect(viewModel.currentEntry.todos.first.priority, equals(TodoPriority.medium));

      // Toggle todo
      await viewModel.toggleTodo(todoId);
      expect(viewModel.currentEntry.todos.first.isDone, isTrue);

      // Update note
      viewModel.onNoteChanged('Writing on warm paper.');
      expect(viewModel.currentEntry.note, equals('Writing on warm paper.'));

      // Switch date
      final tomorrow = viewModel.selectedDate.add(const Duration(days: 1));
      await viewModel.selectDate(tomorrow);
      expect(viewModel.selectedDate.day, equals(tomorrow.day));
      expect(viewModel.currentEntry.todos.isEmpty, isTrue);
      expect(viewModel.currentEntry.note.isEmpty, isTrue);
    });

    test('tracks createdAt and updatedAt timestamps for TodoItem and DayEntry note correctly', () async {
      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();

      final beforeTodo = DateTime.now().subtract(const Duration(milliseconds: 10));
      await viewModel.addTodo('Buy journal notebook');
      final todo = viewModel.currentEntry.todos.first;

      expect(todo.createdAt.isAfter(beforeTodo) || todo.createdAt.isAtSameMomentAs(beforeTodo), isTrue);
      expect(todo.updatedAt.isAfter(beforeTodo) || todo.updatedAt.isAtSameMomentAs(beforeTodo), isTrue);

      final initialTodoUpdatedAt = todo.updatedAt;

      // Small delay to ensure timestamp progression
      await Future.delayed(const Duration(milliseconds: 20));

      // Toggle todo updates updatedAt
      await viewModel.toggleTodo(todo.id);
      final toggledTodo = viewModel.currentEntry.todos.first;
      expect(toggledTodo.isDone, isTrue);
      expect(toggledTodo.createdAt, equals(todo.createdAt));
      expect(toggledTodo.updatedAt.isAfter(initialTodoUpdatedAt), isTrue);

      // Note creation sets noteCreatedAt and noteUpdatedAt
      final beforeNote = DateTime.now().subtract(const Duration(milliseconds: 10));
      viewModel.onNoteChanged('First note entry');
      expect(viewModel.currentEntry.note, equals('First note entry'));
      expect(viewModel.currentEntry.noteCreatedAt, isNotNull);
      expect(viewModel.currentEntry.noteUpdatedAt, isNotNull);
      expect(viewModel.currentEntry.noteCreatedAt!.isAfter(beforeNote) || viewModel.currentEntry.noteCreatedAt!.isAtSameMomentAs(beforeNote), isTrue);
      final initialNoteCreated = viewModel.currentEntry.noteCreatedAt!;
      final initialNoteUpdated = viewModel.currentEntry.noteUpdatedAt!;

      await Future.delayed(const Duration(milliseconds: 20));

      // Note modification updates noteUpdatedAt while keeping noteCreatedAt
      viewModel.onNoteChanged('First note entry modified');
      expect(viewModel.currentEntry.noteCreatedAt, equals(initialNoteCreated));
      expect(viewModel.currentEntry.noteUpdatedAt!.isAfter(initialNoteUpdated), isTrue);

      // Serialization round-trip preserves all timestamps
      final entryMap = viewModel.currentEntry.toMap();
      final reconstituted = DayEntry.fromMap(entryMap);
      expect(reconstituted.createdAt.toIso8601String(), equals(viewModel.currentEntry.createdAt.toIso8601String()));
      expect(reconstituted.updatedAt.toIso8601String(), equals(viewModel.currentEntry.updatedAt.toIso8601String()));
      expect(reconstituted.noteCreatedAt?.toIso8601String(), equals(viewModel.currentEntry.noteCreatedAt?.toIso8601String()));
      expect(reconstituted.noteUpdatedAt?.toIso8601String(), equals(viewModel.currentEntry.noteUpdatedAt?.toIso8601String()));
      expect(reconstituted.todos.first.createdAt.toIso8601String(), equals(toggledTodo.createdAt.toIso8601String()));
      expect(reconstituted.todos.first.updatedAt.toIso8601String(), equals(toggledTodo.updatedAt.toIso8601String()));
    });

    test('DayNoteViewModel handles month & year navigation correctly', () async {
      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();

      final currentYear = viewModel.currentMonth.year;
      final currentMonth = viewModel.currentMonth.month;

      viewModel.previousMonth();
      if (currentMonth == 1) {
        expect(viewModel.currentMonth.month, equals(12));
        expect(viewModel.currentMonth.year, equals(currentYear - 1));
      } else {
        expect(viewModel.currentMonth.month, equals(currentMonth - 1));
      }

      viewModel.setMonthYear(2028, 10);
      expect(viewModel.currentMonth.year, equals(2028));
      expect(viewModel.currentMonth.month, equals(10));

      await viewModel.goToToday();
      final now = DateTime.now();
      expect(viewModel.currentMonth.year, equals(now.year));
      expect(viewModel.currentMonth.month, equals(now.month));
    });

    test('DayNoteViewModel rolls back optimistically when repository throws error', () async {
      final failingRepo = _FailingDayNoteRepository();
      final viewModel = DayNoteViewModel(repository: failingRepo);
      await viewModel.init();

      expect(viewModel.currentEntry.todos.isEmpty, isTrue);

      await viewModel.addTodo('Will fail saving');
      expect(viewModel.currentEntry.todos.isEmpty, isTrue);
      expect(viewModel.errorMessage, isNotNull);

      viewModel.clearError();
      expect(viewModel.errorMessage, isNull);
    });

    test('DayNoteViewModel handles onboarding flow and loads sample data', () async {
      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();

      expect(viewModel.shouldShowOnboarding, isTrue);

      await viewModel.dismissOnboarding(loadSampleData: true);
      expect(viewModel.shouldShowOnboarding, isFalse);

      expect(viewModel.currentEntry.todos.isNotEmpty, isTrue);
      expect(viewModel.currentEntry.note.contains('Welcome to your DayLog planner'), isTrue);
      expect(viewModel.datesWithContent.length, greaterThanOrEqualTo(2));
    });

    test('DayNoteViewModel safely handles operations and notifyListeners after disposal without throwing', () async {
      final repository = DayNoteRepositoryImpl();
      final viewModel = DayNoteViewModel(repository: repository);
      await viewModel.init();

      viewModel.dispose();
      expect(viewModel.isDisposed, isTrue);

      // Calling notifyListeners directly or via actions should not throw
      expect(() => viewModel.notifyListeners(), returnsNormally);
      expect(() => viewModel.clearError(), returnsNormally);
      expect(() => viewModel.setAddingTodo(true), returnsNormally);
      expect(() => viewModel.onNoteChanged('Testing post-dispose'), returnsNormally);
      await expectLater(() => viewModel.addTodo('Test'), returnsNormally);
      await expectLater(() => viewModel.init(), returnsNormally);
    });
  });

  group('DayNote AuthViewModel Tests', () {
    late MockAuthService mockAuthService;
    late AuthViewModel authViewModel;

    setUp(() {
      mockAuthService = MockAuthService();
      authViewModel = AuthViewModel(authService: mockAuthService);
    });

    tearDown(() {
      authViewModel.dispose();
      mockAuthService.dispose();
    });

    test('AuthViewModel initial state is unauthenticated', () {
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUser, isNull);
      expect(authViewModel.isLoading, isFalse);
      expect(authViewModel.errorMessage, isNull);
    });

    test('AuthViewModel validates empty inputs on sign in', () async {
      final success = await authViewModel.signIn(email: '', password: '');
      expect(success, isFalse);
      expect(authViewModel.errorMessage, isNotNull);
    });

    test('AuthViewModel validates password matching on sign up', () async {
      final success = await authViewModel.signUp(
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password456',
      );
      expect(success, isFalse);
      expect(authViewModel.errorMessage, equals('Passwords do not match.'));
    });

    test('AuthViewModel sends password reset email successfully', () async {
      final success = await authViewModel.sendPasswordReset(email: 'user@example.com');
      expect(success, isTrue);
      expect(authViewModel.successMessage, contains('Password reset link sent'));
    });
  });

  group('DayNote Primary App Navigation Tests', () {
    test('Default navigation index is 0 representing DayNote as the primary screen', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialIndex = container.read(navigationIndexProvider);
      expect(initialIndex, equals(0));
    });

    test('Production flavor app title is DayLog', () {
      expect(FlavorConfig.prod.appTitle, equals('DayLog'));
    });
  });

  group('Theme & Design Consistency Tests', () {
    testWidgets('Light theme has consistent text selection cursor matching primary accent', (tester) async {
      expect(kLightTheme.textSelectionTheme.cursorColor, equals(DaylogColors.accent));
    });

    testWidgets('Input decoration theme defines uniform border radius and white borders', (tester) async {
      final lightBorder = kLightTheme.inputDecorationTheme.border as OutlineInputBorder?;

      expect(lightBorder?.borderRadius, equals(BorderRadius.circular(14)));
      expect(lightBorder?.borderSide.color, equals(Colors.white));
      expect(kLightTheme.inputDecorationTheme.focusedBorder?.borderSide.color, equals(Colors.white));
      expect(kLightTheme.inputDecorationTheme.filled, isTrue);
    });

    testWidgets('Dialog and Bottom Sheet themes have surfaceTintColor transparent and consistent radius', (tester) async {
      expect(kLightTheme.dialogTheme.surfaceTintColor, equals(Colors.transparent));

      final lightDialogShape = kLightTheme.dialogTheme.shape as RoundedRectangleBorder?;
      expect(lightDialogShape?.borderRadius, equals(BorderRadius.circular(20)));

      expect(kLightTheme.bottomSheetTheme.surfaceTintColor, equals(Colors.transparent));

      final lightSheetShape = kLightTheme.bottomSheetTheme.shape as RoundedRectangleBorder?;
      expect(lightSheetShape?.borderRadius, equals(const BorderRadius.vertical(top: Radius.circular(28))));
    });

    testWidgets('DayNoteTheme provides consistent light theme surfaces, text colors, and borders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: kLightTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              expect(DayNoteTheme.isDark(context), isFalse);
              expect(DayNoteTheme.border(context), equals(Colors.white));
              expect(DayNoteTheme.focusedBorder(context), equals(Colors.white));
              expect(DayNoteTheme.background(context), equals(DaylogColors.lightBg));
              expect(DayNoteTheme.cardBackground(context), equals(DaylogColors.lightCard));
              expect(DayNoteTheme.textPrimary(context), equals(DaylogColors.lightText));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('DetailsSheet Tests (Created & Updated Timestamps)', () {
    test('formatDateTime formats date and time correctly and handles null', () {
      expect(DetailsSheet.formatDateTime(null), equals('—'));
      final dt = DateTime(2026, 10, 13, 14, 30);
      final formatted = DetailsSheet.formatDateTime(dt);
      expect(formatted.contains('Oct 13, 2026'), isTrue);
      expect(formatted.contains('2:30 PM'), isTrue);
    });

    test('formatRelative returns human readable relative descriptions', () {
      expect(DetailsSheet.formatRelative(null), equals(''));
      expect(DetailsSheet.formatRelative(DateTime.now()), equals('Just now'));
      expect(DetailsSheet.formatRelative(DateTime.now().subtract(const Duration(minutes: 5))), equals('5m ago'));
      expect(DetailsSheet.formatRelative(DateTime.now().subtract(const Duration(hours: 2))), equals('2h ago'));
    });

    testWidgets('DetailsSheet.showTodoDetails presents created and updated details', (tester) async {
      final now = DateTime(2026, 10, 13, 10, 15);
      final later = DateTime(2026, 10, 13, 11, 45);
      final todo = TodoItem(
        id: 'todo_1',
        text: 'Finish project presentation',
        isDone: true,
        priority: TodoPriority.high,
        createdAt: now,
        updatedAt: later,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: kLightTheme,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DetailsSheet.showTodoDetails(context, todo),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('TASK DETAILS'), findsOneWidget);
      expect(find.text('Finish project presentation'), findsOneWidget);
      expect(find.text('CREATED'), findsOneWidget);
      expect(find.text('LAST UPDATED'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('DetailsSheet.showEntryDetails presents day and note created and updated details', (tester) async {
      final created = DateTime(2026, 10, 13, 8, 0);
      final updated = DateTime(2026, 10, 13, 9, 30);
      final entry = DayEntry(
        dateKey: '2026-10-13',
        note: 'Morning reflections on architecture',
        createdAt: created,
        updatedAt: updated,
        noteCreatedAt: created,
        noteUpdatedAt: updated,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: kLightTheme,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DetailsSheet.showEntryDetails(
                context,
                entry: entry,
                date: DateTime(2026, 10, 13),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('ENTRY DETAILS'), findsOneWidget);
      expect(find.text('DAILY RECORD'), findsOneWidget);
      expect(find.text('JOURNAL NOTE'), findsOneWidget);
      expect(find.text('CREATED'), findsNWidgets(2));
      expect(find.text('LAST UPDATED'), findsOneWidget);
      expect(find.text('LAST MODIFIED'), findsOneWidget);
    });

    testWidgets('DetailsSheet.showNoteDetails presents note created and modified details', (tester) async {
      final created = DateTime(2026, 10, 13, 8, 0);
      final updated = DateTime(2026, 10, 13, 9, 30);

      await tester.pumpWidget(
        MaterialApp(
          theme: kLightTheme,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DetailsSheet.showNoteDetails(
                context,
                note: 'Daily journal summary',
                createdAt: created,
                updatedAt: updated,
                date: DateTime(2026, 10, 13),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('NOTE DETAILS'), findsOneWidget);
      expect(find.text('WRITING TIMESTAMPS'), findsOneWidget);
      expect(find.text('CREATED'), findsOneWidget);
      expect(find.text('LAST MODIFIED'), findsOneWidget);
    });
  });
}
