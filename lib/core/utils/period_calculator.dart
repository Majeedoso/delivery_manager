import 'package:clock/clock.dart';
import 'package:delivery_manager/core/utils/week.dart';

/// Helper class for calculating date ranges based on period selection
/// 
/// This keeps business logic (date calculations) out of the presentation layer,
/// following Clean Architecture principles. Used across multiple features
/// (Statistics, Orders) to ensure consistent period calculations.
class PeriodCalculator {
  /// Calculate date range for a given period
  /// 
  /// Returns a tuple of (startDate, endDate) or (null, null) for 'all'
  /// 
  /// Periods:
  /// - 'all': Returns (null, null) - no date filtering
  /// - 'day': Today only
  /// - 'week': This week, since its first day (Sunday: `firstDayOfWeek`)
  /// - 'month': This month, since the 1st
  /// - 'year': This year, since 1 January
  /// - 'dateRange': Returns (null, null) - dates should be set manually
  ///
  /// The periods the server counts by the same names. They were the last 7,
  /// 30 and 365 days: whoever wants those picks the days ('dateRange', which
  /// opens on the last 7).
  static ({DateTime? startDate, DateTime? endDate}) calculatePeriodRange(String period) {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case 'all':
        return (startDate: null, endDate: null);
      case 'day':
        return (startDate: today, endDate: today);
      case 'week':
        // The first day of this week (today, on that day)
        return (
          startDate: startOfWeek(today),
          endDate: today,
        );
      case 'month':
        // The 1st of this month
        return (startDate: DateTime(now.year, now.month), endDate: today);
      case 'year':
        // 1 January of this year
        return (startDate: DateTime(now.year), endDate: today);
      case 'dateRange':
        // For dateRange, return nulls - dates should be set manually
        return (startDate: null, endDate: null);
      default:
        return (startDate: null, endDate: null);
    }
  }
  
  /// Get default date range for 'dateRange' period
  /// Returns last 7 days (today minus 6 days to today)
  static ({DateTime startDate, DateTime endDate}) getDefaultDateRange() {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    return (startDate: today.subtract(const Duration(days: 6)), endDate: today);
  }
  
  /// Calculate date range for 'all' period in orders context
  /// Returns date range from 2020-01-01 to now
  static ({DateTime startDate, DateTime endDate}) getAllTimeRange() {
    final now = clock.now();
    return (startDate: DateTime(2020, 1, 1), endDate: now);
  }
}

