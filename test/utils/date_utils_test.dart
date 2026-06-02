import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/utils/date_utils.dart';

void main() {
  group('Date Utils Tests', () {
    test('dayKey formats DateTime to yyyy-MM-dd correctly', () {
      final date = DateTime(2026, 6, 2);
      expect(dayKey(date), '2026-06-02');

      final dateSingleDigits = DateTime(2026, 1, 9);
      expect(dayKey(dateSingleDigits), '2026-01-09');
    });

    test('formatDuration formats seconds to human-readable strings correctly', () {
      expect(formatDuration(0), '0s');
      expect(formatDuration(45), '45s');
      expect(formatDuration(60), '1m');
      expect(formatDuration(125), '2m');
      expect(formatDuration(3600), '1h 0m');
      expect(formatDuration(3665), '1h 1m');
      expect(formatDuration(7325), '2h 2m');
    });

    test('formatTimer formats seconds to hh:mm:ss correctly', () {
      expect(formatTimer(0), '00:00:00');
      expect(formatTimer(5), '00:00:05');
      expect(formatTimer(65), '00:01:05');
      expect(formatTimer(3600), '01:00:00');
      expect(formatTimer(3665), '01:01:05');
    });

    test('friendlyDate formats to EEE, d MMM correctly', () {
      final date = DateTime(2026, 6, 2); // Tuesday, June 2nd
      expect(friendlyDate(date), 'Tue, 2 Jun');
    });
  });
}
