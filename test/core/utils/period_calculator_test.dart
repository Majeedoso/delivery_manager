import 'package:clock/clock.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

/// The days of the periods the bank and the statistics filter by: each one
/// ends today and counts today in, from midnight, whatever the time now. A
/// week, a month and a year are the calendar ones, as the server counts them
/// under the same names. They were the last 7, 30 and 365 days: those have no
/// name any more, and a range to pick opens on the last 7.
void main() {
  // Thursday 1 October 2026, mid-afternoon
  final now = DateTime(2026, 10, 1, 15, 30);
  final today = DateTime(2026, 10, 1);

  ({DateTime? startDate, DateTime? endDate}) range(
    String period, {
    DateTime? at,
  }) => withClock(
    Clock.fixed(at ?? now),
    () => PeriodCalculator.calculatePeriodRange(period),
  );

  test('a day is today only', () {
    expect(range('day'), (startDate: today, endDate: today));
  });

  test('a week is this week, since Sunday', () {
    // The last 7 days began on Friday the 25th
    expect(range('week'), (startDate: DateTime(2026, 9, 27), endDate: today));
  });

  test('on a Sunday the week is that day; on a Saturday, its seventh', () {
    expect(range('week', at: DateTime(2026, 9, 27, 0, 5)), (
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2026, 9, 27),
    ));
    expect(range('week', at: DateTime(2026, 10, 3, 23, 55)), (
      startDate: DateTime(2026, 9, 27),
      endDate: DateTime(2026, 10, 3),
    ));
  });

  test('a week begun in the month before starts there', () {
    // Wednesday 1 April 2026
    expect(range('week', at: DateTime(2026, 4, 1, 0, 5)), (
      startDate: DateTime(2026, 3, 29),
      endDate: DateTime(2026, 4, 1),
    ));
  });

  test('a month is this month, since the 1st', () {
    // The last 30 days began on 2 September
    expect(range('month'), (startDate: today, endDate: today));
    expect(range('month', at: DateTime(2026, 10, 31, 9)), (
      startDate: DateTime(2026, 10),
      endDate: DateTime(2026, 10, 31),
    ));
  });

  test('a year is this year, since 1 January', () {
    // The last 365 days began on 2 October 2025
    expect(range('year'), (startDate: DateTime(2026), endDate: today));
  });

  test('everything, a range to pick, or an unknown period filters nothing', () {
    for (final period in ['all', 'dateRange', 'fortnight']) {
      expect(range(period), (startDate: null, endDate: null), reason: period);
    }
  });

  test('a range to pick starts as the last 7 days', () {
    final range = withClock(
      Clock.fixed(now),
      PeriodCalculator.getDefaultDateRange,
    );

    expect(range, (startDate: DateTime(2026, 9, 25), endDate: today));
  });
}
