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
  /// - 'week': Last 7 days (today minus 6 days)
  /// - 'month': Last 30 days (today minus 29 days)
  /// - 'year': Last 365 days (today minus 364 days)
  /// - 'dateRange': Returns (null, null) - dates should be set manually
  static ({DateTime? startDate, DateTime? endDate}) calculatePeriodRange(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case 'all':
        return (startDate: null, endDate: null);
      case 'day':
        return (startDate: today, endDate: today);
      case 'week':
        // Go back 6 days from today (total 7 days including today)
        return (startDate: today.subtract(const Duration(days: 6)), endDate: today);
      case 'month':
        // Go back 29 days from today (total 30 days including today)
        return (startDate: today.subtract(const Duration(days: 29)), endDate: today);
      case 'year':
        // Go back 364 days from today (total 365 days including today)
        return (startDate: today.subtract(const Duration(days: 364)), endDate: today);
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (startDate: today.subtract(const Duration(days: 6)), endDate: today);
  }
  
  /// Calculate date range for 'all' period in orders context
  /// Returns date range from 2020-01-01 to now
  static ({DateTime startDate, DateTime endDate}) getAllTimeRange() {
    final now = DateTime.now();
    return (startDate: DateTime(2020, 1, 1), endDate: now);
  }
}

