import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:daylog/models/journal_entry.dart';
import 'package:daylog/providers/journal_provider.dart';
import 'package:daylog/services/db_service.dart';
import 'package:flutter/services.dart';

void main() {
  group('JournalProvider Tests', () {
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

    test('JournalNotifier.save() creates and updates journal entries', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(journalNotifierProvider.notifier);

      // Check initial state is null
      final initial = await container.read(journalNotifierProvider.future);
      expect(initial, null);

      // Save a new entry
      await notifier.save(
        shipped: 'Built notifications',
        blockers: 'Timezones',
        tomorrow: 'Write tests',
      );

      final saved = await container.read(journalNotifierProvider.future);
      expect(saved, isNotNull);
      expect(saved!.shipped, 'Built notifications');
      expect(saved.blockers, 'Timezones');
      expect(saved.tomorrow, 'Write tests');

      // Update the entry
      await notifier.save(
        shipped: 'Built notifications & completed Phase 5',
        blockers: 'None',
        tomorrow: 'Write more tests',
      );

      final updated = await container.read(journalNotifierProvider.future);
      expect(updated!.shipped, 'Built notifications & completed Phase 5');
      expect(updated.blockers, 'None');
      expect(updated.tomorrow, 'Write more tests');

      // Verify db count is still 1
      final count = await isar.journalEntrys.where().count();
      expect(count, 1);
    });
  });
}
