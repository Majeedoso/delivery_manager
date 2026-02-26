import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsRatingsOverviewScreen extends StatefulWidget {
  static const String route = '/statistics/ratings/overview';

  const StatisticsRatingsOverviewScreen({super.key});

  @override
  State<StatisticsRatingsOverviewScreen> createState() =>
      _StatisticsRatingsOverviewScreenState();
}

class _StatisticsRatingsOverviewScreenState
    extends State<StatisticsRatingsOverviewScreen> {
  late Future<_RatingsStats> _statsFuture;
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

  Future<_RatingsStats> _fetchStats() async {
    final dio = sl<Dio>();
    final q = <String, dynamic>{};
    if (_dateFrom != null) q['start_date'] = _fmt(_dateFrom!);
    if (_dateTo != null) q['end_date'] = _fmt(_dateTo!);
    final response = await dio.get(
      ApiConstance.managerRatingStatisticsPath,
      queryParameters: q.isEmpty ? null : q,
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final overall = data['overall'] as Map<String, dynamic>? ?? {};
      final restaurantPerf =
          data['restaurant_performance'] as Map<String, dynamic>? ?? {};
      final driverPerf =
          data['driver_performance'] as Map<String, dynamic>? ?? {};
      final satisfaction =
          data['customer_satisfaction'] as Map<String, dynamic>? ?? {};
      final rawDist =
          overall['rating_distribution'] as Map<String, dynamic>? ?? {};

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

      final distribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        final val = rawDist[i.toString()];
        distribution[i] = val is num ? val.toInt() : 0;
      }

      return _RatingsStats(
        totalRatings: readInt(overall, 'total_ratings'),
        averageRating: readDouble(overall, 'average_rating'),
        ratingDistribution: distribution,
        avgFoodQuality: readDouble(
          restaurantPerf,
          'average_food_quality_rating',
        ),
        avgRestaurantService: readDouble(
          restaurantPerf,
          'average_restaurant_service_rating',
        ),
        avgDriverRating: readDouble(driverPerf, 'average_driver_rating'),
        avgDeliverySpeed: readDouble(
          driverPerf,
          'average_delivery_speed_rating',
        ),
        reorderRate: readDouble(satisfaction, 'reorder_rate'),
        recommendRate: readDouble(satisfaction, 'recommendation_rate'),
      );
    }
    throw Exception('Failed to load rating statistics');
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
                      _dateTo = DateTime(picked.year, picked.month, picked.day);
                    });
                    _refreshStats();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<_RatingsStats>(
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
                          _OverallRatingCard(stats: stats, l: l),
                          SizedBox(height: 2.h),
                          _SectionHeader(title: l.ratingDistribution),
                          SizedBox(height: 1.h),
                          _RatingDistributionCard(
                            distribution: stats.ratingDistribution,
                            total: stats.totalRatings,
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

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _RatingsStats {
  final int totalRatings;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final double avgFoodQuality;
  final double avgRestaurantService;
  final double avgDriverRating;
  final double avgDeliverySpeed;
  final double reorderRate;
  final double recommendRate;

  const _RatingsStats({
    required this.totalRatings,
    required this.averageRating,
    required this.ratingDistribution,
    required this.avgFoodQuality,
    required this.avgRestaurantService,
    required this.avgDriverRating,
    required this.avgDeliverySpeed,
    required this.reorderRate,
    required this.recommendRate,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

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

class _OverallRatingCard extends StatelessWidget {
  final _RatingsStats stats;
  final AppLocalizations l;

  const _OverallRatingCard({required this.stats, required this.l});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                return Icon(icon, color: Colors.amber, size: 9.w);
              }),
            ),
            SizedBox(height: 1.h),
            Text(
              '${stats.averageRating.toStringAsFixed(1)} ${l.outOf5}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.4.h),
            Text(
              '${stats.totalRatings} ${l.totalRatings}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingDistributionCard extends StatelessWidget {
  final Map<int, int> distribution;
  final int total;

  const _RatingDistributionCard({
    required this.distribution,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Column(
          children: List.generate(5, (i) {
            final star = 5 - i;
            final count = distribution[star] ?? 0;
            final fraction = total > 0 ? count / total : 0.0;
            return Padding(
              padding: EdgeInsets.only(bottom: 0.8.h),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, size: 4.w, color: Colors.amber),
                  SizedBox(width: 1.w),
                  Text('$star', style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 8,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  SizedBox(
                    width: 8.w,
                    child: Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
