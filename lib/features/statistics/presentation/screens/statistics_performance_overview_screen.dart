import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StatisticsPerformanceOverviewScreen extends StatefulWidget {
  static const String route = '/statistics/performance/overview';

  const StatisticsPerformanceOverviewScreen({super.key});

  @override
  State<StatisticsPerformanceOverviewScreen> createState() =>
      _StatisticsPerformanceOverviewScreenState();
}

class _StatisticsPerformanceOverviewScreenState
    extends State<StatisticsPerformanceOverviewScreen> {
  late Future<_PerformanceOverviewStats> _statsFuture;
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

  Future<_PerformanceOverviewStats> _fetchStats() async {
    final dio = sl<Dio>();
    final backendPeriod = _selectedPeriod == 'dateRange'
        ? 'custom'
        : _selectedPeriod;
    final q = <String, dynamic>{'period': backendPeriod};
    if (_dateFrom != null) q['start_date'] = _fmt(_dateFrom!);
    if (_dateTo != null) q['end_date'] = _fmt(_dateTo!);

    final responses = await Future.wait([
      dio.get(
        ApiConstance.managerRestaurantStatisticsOverviewPath,
        queryParameters: q,
      ),
      dio.get(ApiConstance.managerDeliveryAnalyticsPath, queryParameters: q),
    ]);

    Map<String, dynamic> asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      return {};
    }

    int readInt(Map<String, dynamic> map, String key) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final sanitized = (value?.toString() ?? '').replaceAll(',', '');
      return int.tryParse(sanitized) ?? 0;
    }

    double readDouble(Map<String, dynamic> map, String key) {
      final value = map[key];
      if (value is num) return value.toDouble();
      final sanitized = (value?.toString() ?? '').replaceAll(',', '');
      return double.tryParse(sanitized) ?? 0.0;
    }

    double? readNullableDouble(Map<String, dynamic> map, String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is num) return value.toDouble();
      final sanitized = value.toString().replaceAll(',', '');
      return double.tryParse(sanitized);
    }

    final restaurantsRoot = asMap(responses[0].data);
    final driversRoot = asMap(responses[1].data);
    if (restaurantsRoot['success'] != true || driversRoot['success'] != true) {
      throw Exception('Failed to load performance overview');
    }

    final restaurantData = asMap(restaurantsRoot['data']);
    final restaurantCounts = asMap(restaurantData['order_counts']);
    final restaurantPerf = asMap(restaurantData['performance']);

    final driverData = asMap(driversRoot['data']);
    final driverOverview = asMap(driverData['overview']);
    final driverPerf = asMap(driverData['performance_metrics']);

    return _PerformanceOverviewStats(
      pending: readInt(restaurantCounts, 'pending'),
      accepted: readInt(restaurantCounts, 'accepted'),
      rejected: readInt(restaurantCounts, 'rejected'),
      delivered: readInt(restaurantCounts, 'delivered'),
      responseSpeed: readNullableDouble(restaurantPerf, 'response_speed'),
      preparationSpeed: readNullableDouble(restaurantPerf, 'preparation_speed'),
      decisionQuality: readDouble(restaurantPerf, 'decision_quality'),
      poorDecisions: readDouble(restaurantPerf, 'poor_decisions'),
      totalDeliveries: readInt(driverOverview, 'total_deliveries'),
      completedDeliveries: readInt(driverOverview, 'completed_deliveries'),
      cancelledDeliveries: readInt(driverOverview, 'cancelled_deliveries'),
      completionRate: readDouble(driverOverview, 'completion_rate'),
      averageDeliveryTime: readDouble(driverOverview, 'average_delivery_time_minutes'),
      onTimeDeliveryRate: readDouble(driverPerf, 'on_time_delivery_rate'),
      fastestDelivery: readDouble(driverPerf, 'fastest_delivery_minutes'),
      slowestDelivery: readDouble(driverPerf, 'slowest_delivery_minutes'),
      responseSpeedMinutes: readDouble(driverPerf, 'response_speed_minutes'),
      pickupSpeedMinutes: readDouble(driverPerf, 'pickup_speed_minutes'),
      cancellationRate: readDouble(driverPerf, 'cancellation_rate'),
    );
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _fetchStats();
    });
    try {
      await _statsFuture;
    } catch (_) {}
  }

  String _formatMinutes(double? minutes, String minutesAbbr) {
    if (minutes == null) return 'N/A';
    if (minutes <= 0) return '-';
    if (minutes < 1) {
      final secs = (minutes * 60).round();
      return '$secs s';
    }
    return '${minutes.toStringAsFixed(1)} $minutesAbbr';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.overview)),
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
                  DateTime? from;
                  DateTime? to;
                  if (value == 'dateRange') {
                    final r = PeriodCalculator.getDefaultDateRange();
                    from = r.startDate;
                    to = r.endDate;
                  } else if (value != 'all') {
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
                      _dateTo = DateTime(picked.year, picked.month, picked.day);
                    });
                    _refreshStats();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<_PerformanceOverviewStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: MaterialTheme.getCircularProgressIndicator(context),
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
                            title: l.restaurantsTab.toUpperCase(),
                            icon: Icons.store_outlined,
                          ),
                          SizedBox(height: 1.5.h),
                          _SubHeader(title: l.overview.toUpperCase()),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.pending.toUpperCase(),
                                value: stats.pending.toString(),
                                icon: Icons.hourglass_empty_outlined,
                                iconColor: Colors.orange.shade700,
                                circleColor: const Color(0xFFFFF3E0),
                              ),
                              _MetricCard(
                                label: l.accepted.toUpperCase(),
                                value: stats.accepted.toString(),
                                icon: Icons.check_circle_outline,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                              ),
                              _MetricCard(
                                label: l.rejected.toUpperCase(),
                                value: stats.rejected.toString(),
                                icon: Icons.cancel_outlined,
                                iconColor: Colors.red.shade700,
                                circleColor: const Color(0xFFFFEBEE),
                              ),
                              _MetricCard(
                                label: l.delivered.toUpperCase(),
                                value: stats.delivered.toString(),
                                icon: Icons.delivery_dining_outlined,
                                iconColor: Colors.blue.shade700,
                                circleColor: const Color(0xFFE3F2FD),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _SubHeader(title: l.performanceMetrics.toUpperCase()),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.responseSpeed.toUpperCase(),
                                value: _formatMinutes(
                                  stats.responseSpeed,
                                  l.minutesAbbr,
                                ),
                                icon: Icons.access_time_outlined,
                                iconColor: Colors.blue.shade700,
                                circleColor: const Color(0xFFE3F2FD),
                              ),
                              _MetricCard(
                                label: l.preparationSpeed.toUpperCase(),
                                value: _formatMinutes(
                                  stats.preparationSpeed,
                                  l.minutesAbbr,
                                ),
                                icon: Icons.restaurant_outlined,
                                iconColor: Colors.purple.shade700,
                                circleColor: const Color(0xFFF3E5F5),
                              ),
                              _MetricCard(
                                label: l.decisionQuality.toUpperCase(),
                                value:
                                    '${stats.decisionQuality.toStringAsFixed(1)}%',
                                icon: Icons.check_circle_outline,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                              ),
                              _MetricCard(
                                label: l.poorDecisions.toUpperCase(),
                                value:
                                    '${stats.poorDecisions.toStringAsFixed(1)}%',
                                icon: Icons.cancel_outlined,
                                iconColor: Colors.red.shade700,
                                circleColor: const Color(0xFFFFEBEE),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          _SectionHeader(
                            title: l.driversTab.toUpperCase(),
                            icon: Icons.delivery_dining_outlined,
                          ),
                          SizedBox(height: 1.5.h),
                          _SubHeader(title: l.deliveryPerformance.toUpperCase()),
                          SizedBox(height: 1.h),
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
                              ),
                              _MetricCard(
                                label: l.completedDeliveries
                                    .toUpperCase()
                                    .replaceAll(' DELIVERIES', ''),
                                value: stats.completedDeliveries.toString(),
                                icon: Icons.check_circle_outline,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                              ),
                              _MetricCard(
                                label: l.cancelledDeliveries
                                    .toUpperCase()
                                    .replaceAll(' DELIVERIES', ''),
                                value: stats.cancelledDeliveries.toString(),
                                icon: Icons.cancel_outlined,
                                iconColor: Colors.red.shade700,
                                circleColor: const Color(0xFFFFEBEE),
                              ),
                              _MetricCard(
                                label: l.completionRate.toUpperCase(),
                                value:
                                    '${stats.completionRate.toStringAsFixed(1)}%',
                                icon: Icons.trending_up_outlined,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _SubHeader(title: l.avgDeliveryTime.toUpperCase()),
                          SizedBox(height: 1.h),
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
                              ),
                              _MetricCard(
                                label: l.onTimeRate.toUpperCase(),
                                value:
                                    '${stats.onTimeDeliveryRate.toStringAsFixed(1)}%',
                                icon: Icons.timer_outlined,
                                iconColor: const Color(0xFFE64A19),
                                circleColor: const Color(0xFFFFEBE3),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _SubHeader(title: l.performance.toUpperCase()),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.fastestDelivery.toUpperCase(),
                                value:
                                    '${stats.fastestDelivery.toStringAsFixed(0)} ${l.minutesAbbr}',
                                icon: Icons.bolt_outlined,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                              ),
                              _MetricCard(
                                label: l.slowestDelivery.toUpperCase(),
                                value:
                                    '${stats.slowestDelivery.toStringAsFixed(0)} ${l.minutesAbbr}',
                                icon: Icons.hourglass_empty_outlined,
                                iconColor: Colors.orange.shade700,
                                circleColor: const Color(0xFFFFF3E0),
                              ),
                              _MetricCard(
                                label: l.responseSpeed.toUpperCase(),
                                value:
                                    '${stats.responseSpeedMinutes.toStringAsFixed(1)} ${l.minutesAbbr}',
                                icon: Icons.alt_route_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                circleColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              _MetricCard(
                                label: l.pickupSpeed.toUpperCase(),
                                value:
                                    '${stats.pickupSpeedMinutes.toStringAsFixed(1)} ${l.minutesAbbr}',
                                icon: Icons.directions_run_outlined,
                                iconColor: Theme.of(context).colorScheme.primary,
                                circleColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
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

class _PerformanceOverviewStats {
  final int pending;
  final int accepted;
  final int rejected;
  final int delivered;
  final double? responseSpeed;
  final double? preparationSpeed;
  final double decisionQuality;
  final double poorDecisions;
  final int totalDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final double completionRate;
  final double averageDeliveryTime;
  final double onTimeDeliveryRate;
  final double fastestDelivery;
  final double slowestDelivery;
  final double responseSpeedMinutes;
  final double pickupSpeedMinutes;
  final double cancellationRate;

  const _PerformanceOverviewStats({
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.delivered,
    required this.responseSpeed,
    required this.preparationSpeed,
    required this.decisionQuality,
    required this.poorDecisions,
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.completionRate,
    required this.averageDeliveryTime,
    required this.onTimeDeliveryRate,
    required this.fastestDelivery,
    required this.slowestDelivery,
    required this.responseSpeedMinutes,
    required this.pickupSpeedMinutes,
    required this.cancellationRate,
  });
}

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

class _SubHeader extends StatelessWidget {
  final String title;

  const _SubHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color circleColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
  });

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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
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
    );
  }
}
