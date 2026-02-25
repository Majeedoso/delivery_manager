import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsDeliveryScreen extends StatefulWidget {
  static const String route = '/statistics/delivery';

  const StatisticsDeliveryScreen({super.key});

  @override
  State<StatisticsDeliveryScreen> createState() =>
      _StatisticsDeliveryScreenState();
}

class _StatisticsDeliveryScreenState extends State<StatisticsDeliveryScreen> {
  late Future<_DeliveryStats> _statsFuture;
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

  Future<_DeliveryStats> _fetchStats() async {
    final dio = sl<Dio>();
    final q = <String, dynamic>{};
    if (_dateFrom != null) q['start_date'] = _fmt(_dateFrom!);
    if (_dateTo != null) q['end_date'] = _fmt(_dateTo!);
    final response = await dio.get(
      ApiConstance.managerDeliveryAnalyticsPath,
      queryParameters: q.isEmpty ? null : q,
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

      final driverList = <_DriverPerformance>[];
      final rawDrivers = data['driver_performance'];
      if (rawDrivers is List) {
        for (final d in rawDrivers) {
          if (d is Map<String, dynamic>) {
            driverList.add(
              _DriverPerformance(
                driverName: d['driver_name']?.toString() ?? '-',
                totalDeliveries: (d['total_deliveries'] as num?)?.toInt() ?? 0,
                avgDeliveryTime:
                    (d['average_delivery_time'] as num?)?.toDouble() ?? 0.0,
                totalEarnings:
                    (d['total_earnings'] as num?)?.toDouble() ?? 0.0,
              ),
            );
          }
        }
      }

      return _DeliveryStats(
        totalDeliveries: readInt(overview, 'total_deliveries'),
        completedDeliveries: readInt(overview, 'completed_deliveries'),
        cancelledDeliveries: readInt(overview, 'cancelled_deliveries'),
        completionRate: readDouble(overview, 'completion_rate'),
        averageDeliveryTime: readDouble(overview, 'average_delivery_time_minutes'),
        fastestDelivery: readDouble(perf, 'fastest_delivery_minutes'),
        slowestDelivery: readDouble(perf, 'slowest_delivery_minutes'),
        onTimeDeliveryRate: readDouble(perf, 'on_time_delivery_rate'),
        responseSpeedMinutes: readDouble(perf, 'response_speed_minutes'),
        pickupSpeedMinutes: readDouble(perf, 'pickup_speed_minutes'),
        cancellationRate: readDouble(perf, 'cancellation_rate'),
        driverPerformance: driverList,
      );
    }
    throw Exception('Failed to load delivery statistics');
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
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.statisticsDelivery)),
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
              child: FutureBuilder<_DeliveryStats>(
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
                              localizations.errorLoadingStatistics,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: _refreshStats,
                              style:
                                  MaterialTheme.getPrimaryButtonStyle(context),
                              child: Text(localizations.tryAgain),
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
                        localizations.noStatisticsAvailable,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                          _SectionHeader(
                            title: localizations.deliveryPerformance,
                          ),
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
                                label: localizations.totalDeliveries,
                                value: stats.totalDeliveries.toString(),
                                description: localizations.totalDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: localizations.completedDeliveries,
                                value: stats.completedDeliveries.toString(),
                                color: Colors.green,
                                description: localizations.completedDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: localizations.cancelledDeliveries,
                                value: stats.cancelledDeliveries.toString(),
                                color: Colors.red,
                                description: localizations.cancelledDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: localizations.completionRate,
                                value: '${stats.completionRate.toStringAsFixed(1)}%',
                                color: stats.completionRate >= 90
                                    ? Colors.green
                                    : stats.completionRate >= 75
                                        ? Colors.orange
                                        : Colors.red,
                                description: localizations.completionRateDesc,
                              ),
                              _MetricCard(
                                label: localizations.cancellationRate,
                                value: '${stats.cancellationRate.toStringAsFixed(1)}%',
                                color: Theme.of(context).colorScheme.error,
                                description: localizations.cancellationRateDescription,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _SectionHeader(title: localizations.avgDeliveryTime),
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
                                label: localizations.avgDeliveryTime,
                                value: '${stats.averageDeliveryTime.toStringAsFixed(0)} ${localizations.minutesAbbr}',
                                description: localizations.avgDeliveryTimeDesc,
                              ),
                              _MetricCard(
                                label: localizations.onTimeRate,
                                value: '${stats.onTimeDeliveryRate.toStringAsFixed(1)}%',
                                color: stats.onTimeDeliveryRate >= 80
                                    ? Colors.green
                                    : Colors.orange,
                                description: localizations.onTimeRateDesc,
                              ),
                              _MetricCard(
                                label: localizations.fastestDelivery,
                                value: '${stats.fastestDelivery.toStringAsFixed(0)} ${localizations.minutesAbbr}',
                                color: Colors.green,
                                description: localizations.fastestDeliveryDesc,
                              ),
                              _MetricCard(
                                label: localizations.slowestDelivery,
                                value: '${stats.slowestDelivery.toStringAsFixed(0)} ${localizations.minutesAbbr}',
                                color: Colors.orange,
                                description: localizations.slowestDeliveryDesc,
                              ),
                              _MetricCard(
                                label: localizations.responseSpeed,
                                value: '${stats.responseSpeedMinutes.toStringAsFixed(1)} ${localizations.minutesAbbr}',
                                description: localizations.responseSpeedDescription,
                              ),
                              _MetricCard(
                                label: localizations.pickupSpeed,
                                value: '${stats.pickupSpeedMinutes.toStringAsFixed(1)} ${localizations.minutesAbbr}',
                                description: localizations.pickupSpeedDescription,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _SectionHeader(
                            title: localizations.driverPerformance,
                          ),
                          SizedBox(height: 1.h),
                          if (stats.driverPerformance.isEmpty)
                            Text(
                              localizations.noDriverData,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                            )
                          else
                            _DriverPerformanceTable(
                              drivers: stats.driverPerformance,
                              minutesAbbr: localizations.minutesAbbr,
                              currency: localizations.currency,
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


class _DeliveryStats {
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
  final List<_DriverPerformance> driverPerformance;

  const _DeliveryStats({
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
    required this.driverPerformance,
  });
}

class _DriverPerformance {
  final String driverName;
  final int totalDeliveries;
  final double avgDeliveryTime;
  final double totalEarnings;

  const _DriverPerformance({
    required this.driverName,
    required this.totalDeliveries,
    required this.avgDeliveryTime,
    required this.totalEarnings,
  });
}

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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverPerformanceTable extends StatelessWidget {
  final List<_DriverPerformance> drivers;
  final String minutesAbbr;
  final String currency;

  const _DriverPerformanceTable({
    required this.drivers,
    required this.minutesAbbr,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: drivers.map((driver) {
            return Padding(
              padding: EdgeInsets.only(bottom: 1.2.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      driver.driverName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${driver.totalDeliveries} orders',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${driver.avgDeliveryTime.toStringAsFixed(0)} $minutesAbbr',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
