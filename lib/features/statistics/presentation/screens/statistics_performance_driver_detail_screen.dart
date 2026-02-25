import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsPerformanceDriverDetailScreen extends StatefulWidget {
  static const String route = '/statistics/performance/driver-detail';

  final int driverId;
  final String driverName;

  const StatisticsPerformanceDriverDetailScreen({
    super.key,
    required this.driverId,
    required this.driverName,
  });

  @override
  State<StatisticsPerformanceDriverDetailScreen> createState() =>
      _StatisticsPerformanceDriverDetailScreenState();
}

class _StatisticsPerformanceDriverDetailScreenState
    extends State<StatisticsPerformanceDriverDetailScreen> {
  late Future<_DriverStats> _statsFuture;
  String _selectedPeriod = 'week';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    final range = PeriodCalculator.calculatePeriodRange(_selectedPeriod);
    _dateFrom = range.startDate;
    _dateTo = range.endDate;
    _statsFuture = _fetchStats();
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<_DriverStats> _fetchStats() async {
    final dio = sl<Dio>();
    final q = <String, dynamic>{'driver_id': widget.driverId};
    if (_dateFrom != null) q['start_date'] = _fmt(_dateFrom!);
    if (_dateTo != null) q['end_date'] = _fmt(_dateTo!);

    final response = await dio.get(
      ApiConstance.managerDeliveryAnalyticsPath,
      queryParameters: q,
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final overview = data['overview'] as Map<String, dynamic>? ?? {};
      final perf = data['performance_metrics'] as Map<String, dynamic>? ?? {};

      double readDouble(Map<String, dynamic> map, String key) {
        final v = map[key];
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '') ?? 0.0;
      }

      int readInt(Map<String, dynamic> map, String key) {
        final v = map[key];
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse(v?.toString() ?? '') ?? 0;
      }

      return _DriverStats(
        totalDeliveries: readInt(overview, 'total_deliveries'),
        completedDeliveries: readInt(overview, 'completed_deliveries'),
        cancelledDeliveries: readInt(overview, 'cancelled_deliveries'),
        completionRate: readDouble(overview, 'completion_rate'),
        averageDeliveryTime:
            readDouble(overview, 'average_delivery_time_minutes'),
        fastestDelivery: readDouble(perf, 'fastest_delivery_minutes'),
        slowestDelivery: readDouble(perf, 'slowest_delivery_minutes'),
        onTimeDeliveryRate: readDouble(perf, 'on_time_delivery_rate'),
        responseSpeedMinutes: readDouble(perf, 'response_speed_minutes'),
        pickupSpeedMinutes: readDouble(perf, 'pickup_speed_minutes'),
        cancellationRate: readDouble(perf, 'cancellation_rate'),
      );
    }
    throw Exception('Failed to load driver performance');
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _fetchStats();
    });
    try {
      await _statsFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.driverName)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: PeriodDateSelector(
                selectedPeriod: _selectedPeriod,
                dateFrom: _dateFrom,
                dateTo: _dateTo,
                onPeriodChanged: (value) {
                  DateTime? from, to;
                  if (value == 'dateRange') {
                    final r = PeriodCalculator.getDefaultDateRange();
                    from = r.startDate;
                    to = r.endDate;
                  } else {
                    final r = PeriodCalculator.calculatePeriodRange(value);
                    from = r.startDate;
                    to = r.endDate;
                  }
                  setState(() {
                    _selectedPeriod = value;
                    _dateFrom = from;
                    _dateTo = to;
                  });
                  _refreshStats();
                },
                onDateFromSelected: (current) async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: current ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    final d = DateTime(picked.year, picked.month, picked.day);
                    DateTime? newTo = _dateTo;
                    if (newTo != null && d.isAfter(newTo)) {
                      newTo = d.add(const Duration(days: 6));
                    }
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateFrom = d;
                      _dateTo = newTo;
                    });
                    _refreshStats();
                  }
                },
                onDateToSelected: (current) async {
                  final first = _dateFrom ?? DateTime(2020);
                  final init = (current ?? DateTime.now()).isBefore(first)
                      ? first
                      : (current ?? DateTime.now());
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: init,
                    firstDate: first,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateTo =
                          DateTime(picked.year, picked.month, picked.day);
                    });
                    _refreshStats();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<_DriverStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child:
                          MaterialTheme.getCircularProgressIndicator(context),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.errorLoadingStatistics,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                            ),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: _refreshStats,
                              style:
                                  MaterialTheme.getPrimaryButtonStyle(context),
                              child: Text(l.tryAgain),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final stats = snapshot.data;
                  if (stats == null) {
                    return Center(
                      child: Text(
                        l.noStatisticsAvailable,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshStats,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(title: l.deliveryPerformance),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 1.5.h,
                            childAspectRatio: 1.55,
                            children: [
                              _MetricCard(
                                label: l.totalDeliveries,
                                value: stats.totalDeliveries.toString(),
                                description: l.totalDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: l.completedDeliveries,
                                value: stats.completedDeliveries.toString(),
                                color: Colors.green,
                                description: l.completedDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: l.cancelledDeliveries,
                                value: stats.cancelledDeliveries.toString(),
                                color: Colors.red,
                                description: l.cancelledDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: l.completionRate,
                                value:
                                    '${stats.completionRate.toStringAsFixed(1)}%',
                                color: stats.completionRate >= 90
                                    ? Colors.green
                                    : stats.completionRate >= 75
                                        ? Colors.orange
                                        : Colors.red,
                                description: l.completionRateDesc,
                              ),
                              _MetricCard(
                                label: l.cancellationRate,
                                value:
                                    '${stats.cancellationRate.toStringAsFixed(1)}%',
                                color: Theme.of(context).colorScheme.error,
                                description: l.cancellationRateDescription,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _SectionHeader(title: l.avgDeliveryTime),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 1.5.h,
                            childAspectRatio: 1.55,
                            children: [
                              _MetricCard(
                                label: l.avgDeliveryTime,
                                value:
                                    '${stats.averageDeliveryTime.toStringAsFixed(0)} ${l.minutesAbbr}',
                                description: l.avgDeliveryTimeDesc,
                              ),
                              _MetricCard(
                                label: l.onTimeRate,
                                value:
                                    '${stats.onTimeDeliveryRate.toStringAsFixed(1)}%',
                                color: stats.onTimeDeliveryRate >= 80
                                    ? Colors.green
                                    : Colors.orange,
                                description: l.onTimeRateDesc,
                              ),
                              _MetricCard(
                                label: l.fastestDelivery,
                                value:
                                    '${stats.fastestDelivery.toStringAsFixed(0)} ${l.minutesAbbr}',
                                color: Colors.green,
                                description: l.fastestDeliveryDesc,
                              ),
                              _MetricCard(
                                label: l.slowestDelivery,
                                value:
                                    '${stats.slowestDelivery.toStringAsFixed(0)} ${l.minutesAbbr}',
                                color: Colors.orange,
                                description: l.slowestDeliveryDesc,
                              ),
                              _MetricCard(
                                label: l.responseSpeed,
                                value:
                                    '${stats.responseSpeedMinutes.toStringAsFixed(1)} ${l.minutesAbbr}',
                                description: l.responseSpeedDescription,
                              ),
                              _MetricCard(
                                label: l.pickupSpeed,
                                value:
                                    '${stats.pickupSpeedMinutes.toStringAsFixed(1)} ${l.minutesAbbr}',
                                description: l.pickupSpeedDescription,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _DriverStats {
  final int totalDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final double completionRate;
  final double averageDeliveryTime;
  final double fastestDelivery;
  final double slowestDelivery;
  final double onTimeDeliveryRate;
  final double responseSpeedMinutes;
  final double pickupSpeedMinutes;
  final double cancellationRate;

  const _DriverStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.completionRate,
    required this.averageDeliveryTime,
    required this.fastestDelivery,
    required this.slowestDelivery,
    required this.onTimeDeliveryRate,
    required this.responseSpeedMinutes,
    required this.pickupSpeedMinutes,
    required this.cancellationRate,
  });
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final String? description;

  const _MetricCard({
    required this.label,
    required this.value,
    this.color,
    this.description,
  });

  void _showInfo(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: Text(description!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
      child: InkWell(
        onTap: description != null ? () => _showInfo(context) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: cardColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 0.6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
