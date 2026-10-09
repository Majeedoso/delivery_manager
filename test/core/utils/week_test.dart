import 'package:delivery_manager/core/utils/week.dart';
import 'package:flutter_test/flutter_test.dart';

/// The week begins on Sunday and ends on Saturday, in every language (the
/// owner's rule): the statistics' default week and the table of each day's
/// hours begin on that day, as the server's week does.
void main() {
  test('the week begins on Sunday', () {
    expect(firstDayOfWeek, DateTime.sunday);
  });

  test('every day of a week goes back to its Sunday', () {
    // Sunday 27 September 2026 to Saturday 3 October
    for (var day = 27; day <= 33; day++) {
      final date = DateTime(2026, 9, day, 15, 30);
      expect(
        startOfWeek(date),
        DateTime(2026, 9, 27),
        reason: 'from $date (weekday ${date.weekday})',
      );
    }
  });

  test('Saturday ends a week and Sunday begins the next', () {
    expect(startOfWeek(DateTime(2026, 9, 26, 23, 59)), DateTime(2026, 9, 20));
    expect(startOfWeek(DateTime(2026, 10, 4)), DateTime(2026, 10, 4));
  });

  test('a week can begin in the month, or the year, before', () {
    expect(startOfWeek(DateTime(2026, 10, 1)), DateTime(2026, 9, 27));
    expect(startOfWeek(DateTime(2027, 1, 1)), DateTime(2026, 12, 27));
  });
}
