import 'package:clock/clock.dart';
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
        averageDeliveryTime: readDouble(
          overview,
          'average_delivery_time_minutes',
        ),
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
                    initialDate: current ?? clock.now(),
                    firstDate: DateTime(2020),
                    lastDate: clock.now(),
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
                  final init = (current ?? clock.now()).isBefore(first)
                      ? first
                      : (current ?? clock.now());
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: init,
                    firstDate: first,
                    lastDate: clock.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateTo = DateTime(picked.year, picked.month, picked.day);
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
                      child: MaterialTheme.getCircularProgressIndicator(
                        context,
                      ),
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
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: _refreshStats,
                              style: MaterialTheme.getPrimaryButtonStyle(
                                context,
                              ),
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
                            title: l.deliveryPerformance.toUpperCase(),
                            icon: Icons.bar_chart_outlined,
                          ),
                          SizedBox(height: 1.5.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.totalDeliveries.toUpperCase(),
                                value: stats.totalDeliveries.toString(),
                                icon: Icons.inventory_2_outlined,
                                iconColor: const Color(0xFFE64A19),
                                circleColor: const Color(0xFFFFEBE3),
                                description: l.totalDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: l.completedDeliveries
                                    .toUpperCase()
                                    .replaceAll(' DELIVERIES', ''),
                                value: stats.completedDeliveries.toString(),
                                icon: Icons.check_circle_outline,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                                description: l.completedDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: l.cancelledDeliveries
                                    .toUpperCase()
                                    .replaceAll(' DELIVERIES', ''),
                                value: stats.cancelledDeliveries.toString(),
                                icon: Icons.cancel_outlined,
                                iconColor: Colors.red.shade700,
                                circleColor: const Color(0xFFFFEBEE),
                                description: l.cancelledDeliveriesDesc,
                              ),
                              _MetricCard(
                                label: l.completionRate.toUpperCase(),
                                value:
                                    '${stats.completionRate.toStringAsFixed(1)}%',
                                icon: Icons.trending_up_outlined,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                                description: l.completionRateDesc,
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          _SectionHeader(
                            title: l.avgDeliveryTime.toUpperCase(),
                            icon: Icons.timer_outlined,
                          ),
                          SizedBox(height: 1.5.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.avgDeliveryTime
                                    .toUpperCase()
                                    .replaceAll('DELIVERY ', ''),
                                value:
                                    '${stats.averageDeliveryTime.toStringAsFixed(0)} ${l.minutesAbbr}',
                                icon: Icons.access_time_outlined,
                                iconColor: const Color(0xFFE64A19),
                                circleColor: const Color(0xFFFFEBE3),
                                description: l.avgDeliveryTimeDesc,
                              ),
                              _MetricCard(
                                label: l.onTimeRate.toUpperCase(),
                                value:
                                    '${stats.onTimeDeliveryRate.toStringAsFixed(1)}%',
                                icon: Icons.timer_outlined,
                                iconColor: const Color(0xFFE64A19),
                                circleColor: const Color(0xFFFFEBE3),
                                description: l.onTimeRateDesc,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          // Keep the rest of the metrics in a different style or just as they were
                          // But the user only showed these sections in the images.
                          // I'll keep the other metrics but maybe style them similarly or just hide if not in image?
                          // The images only show these two sections.
                          // I'll keep the others but style them with the same _MetricCard for consistency
                          _SectionHeader(
                            title: l.performance.toUpperCase(),
                            icon: Icons.speed_outlined,
                          ),
                          SizedBox(height: 1.5.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 1.5.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.fastestDelivery.toUpperCase(),
                                value:
                                    '${stats.fastestDelivery.toStringAsFixed(0)} ${l.minutesAbbr}',
                                icon: Icons.bolt_outlined,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                                description: l.fastestDeliveryDesc,
                              ),
                              _MetricCard(
                                label: l.slowestDelivery.toUpperCase(),
                                value:
                                    '${stats.slowestDelivery.toStringAsFixed(0)} ${l.minutesAbbr}',
                                icon: Icons.hourglass_empty_outlined,
                                iconColor: Colors.orange.shade700,
                                circleColor: const Color(0xFFFFF3E0),
                                description: l.slowestDeliveryDesc,
                              ),
                              _MetricCard(
                                label: l.responseSpeed.toUpperCase(),
                                value:
                                    '${stats.responseSpeedMinutes.toStringAsFixed(1)} ${l.minutesAbbr}',
                                icon: Icons.alt_route_outlined,
                                iconColor: const Color(0xFFE64A19),
                                circleColor: const Color(0xFFFFEBE3),
                                description: l.responseSpeedDescription,
                              ),
                              _MetricCard(
                                label: l.pickupSpeed.toUpperCase(),
                                value:
                                    '${stats.pickupSpeedMinutes.toStringAsFixed(1)} ${l.minutesAbbr}',
                                icon: Icons.directions_run_outlined,
                                iconColor: const Color(0xFFE64A19),
                                circleColor: const Color(0xFFFFEBE3),
                                description: l.pickupSpeedDescription,
                              ),
                              _MetricCard(
                                label: l.cancellationRate.toUpperCase(),
                                value:
                                    '${stats.cancellationRate.toStringAsFixed(1)}%',
                                icon: Icons.report_gmailerrorred_outlined,
                                iconColor: Theme.of(context).colorScheme.error,
                                circleColor: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.1),
                                description: l.cancellationRateDescription,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
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
  final IconData? icon;
  const _SectionHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFFE64A19),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        if (icon != null)
          Icon(
            icon,
            size: 18,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final String? description;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: description != null ? () => _showInfo(context) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              SizedBox(height: 0.8.h),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  // The card is white in both modes: the theme's text
                  // colour, white in dark mode, could not be read on it
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 0.2.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 22.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
