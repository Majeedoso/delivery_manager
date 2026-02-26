import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsPerformanceRestaurantDetailScreen extends StatefulWidget {
  static const String route = '/statistics/performance/restaurant-detail';

  final int restaurantId;
  final String restaurantName;

  const StatisticsPerformanceRestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<StatisticsPerformanceRestaurantDetailScreen> createState() =>
      _StatisticsPerformanceRestaurantDetailScreenState();
}

class _StatisticsPerformanceRestaurantDetailScreenState
    extends State<StatisticsPerformanceRestaurantDetailScreen> {
  late Future<_RestaurantStats> _statsFuture;
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

  Future<_RestaurantStats> _fetchStats() async {
    final dio = sl<Dio>();
    final q = <String, dynamic>{'period': _selectedPeriod};
    if (_dateFrom != null) q['start_date'] = _fmt(_dateFrom!);
    if (_dateTo != null) q['end_date'] = _fmt(_dateTo!);

    final response = await dio.get(
      ApiConstance.managerRestaurantStatisticsPath(widget.restaurantId),
      queryParameters: q,
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final counts = data['order_counts'] as Map<String, dynamic>? ?? {};
      final perf = data['performance'] as Map<String, dynamic>? ?? {};

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

      return _RestaurantStats(
        pending: readInt(counts, 'pending'),
        accepted: readInt(counts, 'accepted'),
        rejected: readInt(counts, 'rejected'),
        delivered: readInt(counts, 'delivered'),
        responseSpeed: perf['response_speed'] == null
            ? null
            : readDouble(perf, 'response_speed'),
        preparationSpeed: perf['preparation_speed'] == null
            ? null
            : readDouble(perf, 'preparation_speed'),
        decisionQuality: readDouble(perf, 'decision_quality'),
        poorDecisions: readDouble(perf, 'poor_decisions'),
      );
    }
    throw Exception('Failed to load restaurant statistics');
  }

  void _onPeriodChanged(String period) {
    DateTime? dateFrom;
    DateTime? dateTo;
    if (period == 'dateRange') {
      final now = DateTime.now();
      dateFrom = now.subtract(const Duration(days: 6));
      dateTo = now;
    } else if (period != 'all') {
      final range = PeriodCalculator.calculatePeriodRange(period);
      dateFrom = range.startDate;
      dateTo = range.endDate;
    }
    setState(() {
      _selectedPeriod = period;
      _dateFrom = dateFrom;
      _dateTo = dateTo;
      _statsFuture = _fetchStats();
    });
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
      appBar: AppBar(title: Text(widget.restaurantName)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
              child: PeriodDateSelector(
                selectedPeriod: _selectedPeriod,
                dateFrom: _dateFrom,
                dateTo: _dateTo,
                onPeriodChanged: _onPeriodChanged,
                onDateFromSelected: (currentDate) async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateFrom = picked;
                      if (_dateTo != null && _dateTo!.isBefore(picked)) {
                        _dateTo = picked;
                      }
                      _statsFuture = _fetchStats();
                    });
                  }
                },
                onDateToSelected: (currentDate) async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentDate ?? DateTime.now(),
                    firstDate: _dateFrom ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateTo = picked;
                      _statsFuture = _fetchStats();
                    });
                  }
                },
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              ),
            ),
            Expanded(
              child: FutureBuilder<_RestaurantStats>(
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
                            title: l.overview.toUpperCase(),
                            icon: Icons.bar_chart_outlined,
                          ),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 1.5.h,
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
                          _SectionHeader(
                            title: l.performanceMetrics.toUpperCase(),
                            icon: Icons.speed_outlined,
                          ),
                          SizedBox(height: 1.h),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.w,
                            mainAxisSpacing: 1.5.h,
                            childAspectRatio: 1.1,
                            children: [
                              _MetricCard(
                                label: l.responseSpeed.toUpperCase(),
                                value: _formatMinutes(
                                  context,
                                  stats.responseSpeed,
                                ),
                                icon: Icons.access_time_outlined,
                                iconColor: Colors.blue.shade700,
                                circleColor: const Color(0xFFE3F2FD),
                                description: l.responseSpeedDescription,
                                onInfo: () => _showInfoDialog(
                                  context,
                                  title: l.responseSpeed,
                                  description: l.responseSpeedDescription,
                                  whenGood: l.averageRespondingTimeGood,
                                  whenBad: l.averageRespondingTimeBad,
                                ),
                              ),
                              _MetricCard(
                                label: l.preparationSpeed.toUpperCase(),
                                value: _formatMinutes(
                                  context,
                                  stats.preparationSpeed,
                                ),
                                icon: Icons.restaurant_outlined,
                                iconColor: Colors.purple.shade700,
                                circleColor: const Color(0xFFF3E5F5),
                                description: l.preparationSpeedDescription,
                                onInfo: () => _showInfoDialog(
                                  context,
                                  title: l.preparationSpeed,
                                  description: l.preparationSpeedDescription,
                                  whenGood: l.averageRespondingTimeGood,
                                  whenBad: l.averageRespondingTimeBad,
                                ),
                              ),
                              _MetricCard(
                                label: l.decisionQuality.toUpperCase(),
                                value:
                                    '${stats.decisionQuality.toStringAsFixed(1)}%',
                                icon: Icons.check_circle_outline,
                                iconColor: Colors.green.shade700,
                                circleColor: const Color(0xFFE8F5E9),
                                description: l.decisionQualityDescription,
                                onInfo: () => _showInfoDialog(
                                  context,
                                  title: l.decisionQuality,
                                  description: l.decisionQualityDescription,
                                  whenGood: l.acceptedOrdersSuccessRateGood,
                                  whenBad: l.acceptedOrdersSuccessRateBad,
                                ),
                              ),
                              _MetricCard(
                                label: l.poorDecisions.toUpperCase(),
                                value:
                                    '${stats.poorDecisions.toStringAsFixed(1)}%',
                                icon: Icons.cancel_outlined,
                                iconColor: Colors.red.shade700,
                                circleColor: const Color(0xFFFFEBEE),
                                description: l.poorDecisionsDescription,
                                onInfo: () => _showInfoDialog(
                                  context,
                                  title: l.poorDecisions,
                                  description: l.poorDecisionsDescription,
                                  whenGood: l.acceptedOrdersFailureRateGood,
                                  whenBad: l.acceptedOrdersFailureRateBad,
                                ),
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

  String _formatMinutes(BuildContext context, double? minutes) {
    if (minutes == null) return 'N/A';
    if (minutes <= 0) return '—';
    if (minutes < 1) {
      final secs = (minutes * 60).round();
      return '$secs s';
    }
    return '${minutes.toStringAsFixed(1)} min';
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String whenGood,
    required String whenBad,
  }) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(ctx).colorScheme.primary),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description, style: Theme.of(ctx).textTheme.bodyMedium),
              SizedBox(height: 3.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.whenGood,
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          whenGood,
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20.sp),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.whenBad,
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(whenBad, style: Theme.of(ctx).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _RestaurantStats {
  final int pending;
  final int accepted;
  final int rejected;
  final int delivered;
  final double? responseSpeed;
  final double? preparationSpeed;
  final double decisionQuality;
  final double poorDecisions;

  const _RestaurantStats({
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.delivered,
    required this.responseSpeed,
    required this.preparationSpeed,
    required this.decisionQuality,
    required this.poorDecisions,
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
  final VoidCallback? onInfo;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
    this.description,
    this.onInfo,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onInfo,
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
      ),
    );
  }
}
