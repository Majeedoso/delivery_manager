import 'package:delivery_manager/core/utils/server_time.dart';
import 'package:flutter_test/flutter_test.dart';

/// The server keeps UTC; the manager reads the phone's clock. Shown as they
/// came, every time in the app was one hour early in Algeria (D25).
void main() {
  final instant = DateTime.utc(2026, 9, 30, 10, 40);

  test('an ISO time is the same instant, on the phone\'s clock', () {
    for (final text in [
      '2026-09-30T10:40:00+00:00',
      '2026-09-30T10:40:00Z',
      '2026-09-30T10:40:00.000000Z',
      '2026-09-30T11:40:00+01:00',
    ]) {
      final time = parseServerTime(text);

      expect(time.isUtc, isFalse, reason: text);
      expect(time.isAtSameMomentAs(instant), isTrue, reason: text);
      expect(time, instant.toLocal(), reason: text);
    }
  });

  test('a time without a zone is the server\'s: UTC', () {
    for (final text in ['2026-09-30 10:40:00', '2026-09-30T10:40:00']) {
      final time = parseServerTime(text);

      expect(time.isUtc, isFalse, reason: text);
      expect(
        time.isAtSameMomentAs(instant),
        isTrue,
        reason: '$text was read as 10:40 on the phone\'s clock',
      );
    }
  });

  test('a date alone is a day, not a moment: it stays that day', () {
    expect(parseServerTime('2026-09-30'), DateTime(2026, 9, 30));
  });

  test('nothing, or nothing readable, is no time', () {
    expect(tryParseServerTime(null), isNull);
    expect(tryParseServerTime(''), isNull);
    expect(tryParseServerTime('soon'), isNull);
    expect(tryParseServerTime(1759228800), isNull);
    expect(tryParseServerTime('2026-09-30 10:40:00'), instant.toLocal());
  });
}
