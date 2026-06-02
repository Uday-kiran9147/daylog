import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:daylog/models/task_entry.dart';
import 'package:daylog/providers/task_provider.dart';
import 'package:daylog/services/db_service.dart';
import 'package:flutter/services.dart';

void main() {
  group('TaskProvider Tests', () {
    late Isar isar;
    late Directory tempDir;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp();

      // Mock path provider
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });

      // Clear any existing db instance
      await DbService.close();
      isar = await DbService.db;
    });

    tearDownAll(() async {
      await DbService.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    setUp(() async {
      await isar.writeTxn(() => isar.clear());
    });

    test('ActiveTaskNotifier startTask creates and sets running task', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final activeBefore = await container.read(activeTaskProvider.future);
      expect(activeBefore, null);

      final task = await container.read(activeTaskProvider.notifier).startTask('Coding', 'backend');
      expect(task.title, 'Coding');
      expect(task.category, 'backend');
      expect(task.isRunning, isTrue);

      final activeAfter = await container.read(activeTaskProvider.future);
      expect(activeAfter?.id, task.id);
      expect(activeAfter?.title, 'Coding');
    });

    test('ActiveTaskNotifier stopActive stops the running task', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeTaskProvider.notifier);
      await notifier.startTask('Writing Code', 'mobile');

      final activeBefore = await container.read(activeTaskProvider.future);
      expect(activeBefore, isNotNull);
      expect(activeBefore!.isRunning, isTrue);

      await notifier.stopActive();

      final activeAfter = await container.read(activeTaskProvider.future);
      expect(activeAfter, null);

      final tasks = await isar.taskEntrys.where().findAll();
      expect(tasks.length, 1);
      expect(tasks.first.isRunning, isFalse);
      expect(tasks.first.durationSeconds, greaterThanOrEqualTo(0));
    });
  });
}
