import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
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

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<_RestaurantStats> _fetchStats() async {
    final dio = sl<Dio>();
    final response = await dio.get(
      '${ApiConstance.managerRestaurantsPath}/${widget.restaurantId}',
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
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

      return _RestaurantStats(
        totalOrders: readInt(perf, 'total_orders'),
        completedOrders: readInt(perf, 'completed_orders'),
        cancelledOrders: readInt(perf, 'cancelled_orders'),
        completionRate: readDouble(perf, 'completion_rate'),
        cancellationRate: readDouble(perf, 'cancellation_rate'),
        averageOrderValue: readDouble(perf, 'average_order_value'),
        totalRevenue: readDouble(perf, 'total_revenue'),
        averageRating: readDouble(data, 'rating'),
        totalReviews: readInt(data, 'total_reviews'),
        isOpen: data['is_open'] as bool? ?? false,
      );
    }
    throw Exception('Failed to load restaurant performance');
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
        child: FutureBuilder<_RestaurantStats>(
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _refreshStats,
                        style: MaterialTheme.getPrimaryButtonStyle(context),
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
                          label: l.totalOrders,
                          value: stats.totalOrders.toString(),
                        ),
                        _MetricCard(
                          label: l.completedOrders,
                          value: stats.completedOrders.toString(),
                          color: Colors.green,
                        ),
                        _MetricCard(
                          label: l.cancelledDeliveries,
                          value: stats.cancelledOrders.toString(),
                          color: Colors.red,
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
                        ),
                        _MetricCard(
                          label: l.cancellationRate,
                          value:
                              '${stats.cancellationRate.toStringAsFixed(1)}%',
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _SectionHeader(title: l.orderMetrics),
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
                          label: l.averageOrderValue,
                          value:
                              '${stats.averageOrderValue.toStringAsFixed(0)} ${l.currency}',
                        ),
                        _MetricCard(
                          label: l.totalRevenue,
                          value:
                              '${stats.totalRevenue.toStringAsFixed(0)} ${l.currency}',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _SectionHeader(title: l.averageRating),
                    SizedBox(height: 1.h),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: MaterialTheme.getBorderRadiusCard(),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final pos = i + 1;
                                IconData icon;
                                if (stats.averageRating >= pos) {
                                  icon = Icons.star_rounded;
                                } else if (stats.averageRating >= pos - 0.5) {
                                  icon = Icons.star_half_rounded;
                                } else {
                                  icon = Icons.star_outline_rounded;
                                }
                                return Icon(icon,
                                    color: Colors.amber, size: 9.w);
                              }),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              '${stats.averageRating.toStringAsFixed(1)} ${l.outOf5}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              '${stats.totalReviews} ${l.totalRatings}',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _RestaurantStats {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double completionRate;
  final double cancellationRate;
  final double averageOrderValue;
  final double totalRevenue;
  final double averageRating;
  final int totalReviews;
  final bool isOpen;

  const _RestaurantStats({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.completionRate,
    required this.cancellationRate,
    required this.averageOrderValue,
    required this.totalRevenue,
    required this.averageRating,
    required this.totalReviews,
    required this.isOpen,
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

  const _MetricCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
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
    );
  }
}
