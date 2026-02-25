import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver list screen
// ─────────────────────────────────────────────────────────────────────────────

class StatisticsRatingsDriversScreen extends StatefulWidget {
  static const String route = '/statistics/ratings/drivers';

  const StatisticsRatingsDriversScreen({super.key});

  @override
  State<StatisticsRatingsDriversScreen> createState() =>
      _StatisticsRatingsDriversScreenState();
}

class _StatisticsRatingsDriversScreenState
    extends State<StatisticsRatingsDriversScreen> {
  late Future<List<_DriverSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchDrivers();
  }

  Future<List<_DriverSummary>> _fetchDrivers() async {
    final dio = sl<Dio>();
    final response = await dio.get(
      ApiConstance.managerDriversPath,
      queryParameters: {'per_page': 100},
    );
    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final items = response.data['data'] as List? ?? [];
      return items.whereType<Map<String, dynamic>>().map((e) {
        final perf = e['performance_metrics'] as Map<String, dynamic>? ?? {};
        final ratingInfo =
            perf['rating_info'] as Map<String, dynamic>? ?? {};
        return _DriverSummary(
          id: (e['id'] as num?)?.toInt() ?? 0,
          name: e['name']?.toString() ?? '',
          avgRating:
              (ratingInfo['average_driver_rating'] as num?)?.toDouble() ??
                  0.0,
          totalRatings:
              (ratingInfo['total_driver_ratings'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }
    throw Exception('Failed to load drivers');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.driversTab)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: FutureBuilder<List<_DriverSummary>>(
          future: _future,
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
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => _future = _fetchDrivers()),
                        style:
                            MaterialTheme.getPrimaryButtonStyle(context),
                        child: Text(l.tryAgain),
                      ),
                    ],
                  ),
                ),
              );
            }

            final drivers = snapshot.data ?? [];
            if (drivers.isEmpty) {
              return Center(
                child: Text(
                  l.noRatingsYet,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _fetchDrivers());
                try {
                  await _future;
                } catch (_) {}
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(4.w),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final d = drivers[index];
                  return _DriverCard(
                    driver: d,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _DriverDetailPage(driver: d),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Driver detail page (individual reviews)
// ─────────────────────────────────────────────────────────────────────────────

class _DriverDetailPage extends StatefulWidget {
  final _DriverSummary driver;

  const _DriverDetailPage({required this.driver});

  @override
  State<_DriverDetailPage> createState() => _DriverDetailPageState();
}

class _DriverDetailPageState extends State<_DriverDetailPage> {
  final List<_DriverReview> _reviews = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _hasError = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final dio = sl<Dio>();
      final response = await dio.get(
        ApiConstance.managerDriverRatingsPath(widget.driver.id),
        queryParameters: {'page': page, 'per_page': 20},
      );
      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        final items = (response.data['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(_DriverReview.fromJson)
            .toList();
        final meta = response.data['meta'] as Map<String, dynamic>? ?? {};
        final pagination =
            meta['pagination'] as Map<String, dynamic>? ?? {};
        setState(() {
          if (page == 1) {
            _reviews.clear();
            _stats = meta['statistics'] as Map<String, dynamic>?;
          }
          _reviews.addAll(items);
          _currentPage =
              (pagination['current_page'] as num?)?.toInt() ?? page;
          _lastPage =
              (pagination['last_page'] as num?)?.toInt() ?? 1;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final avgRating =
        (_stats?['average_driver_rating'] as num?)?.toDouble() ??
            widget.driver.avgRating;
    final totalRatings =
        (_stats?['total_driver_ratings'] as num?)?.toInt() ??
            widget.driver.totalRatings;
    final rawDist =
        _stats?['rating_distribution'] as Map<String, dynamic>? ?? {};
    final distribution = _parseDistribution(rawDist);

    return Scaffold(
      appBar: AppBar(title: Text(widget.driver.name)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: RefreshIndicator(
          onRefresh: () => _loadPage(1),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(4.w),
            children: [
              if (_stats != null) ...[
                _StatsHeader(
                  avgRating: avgRating,
                  totalRatings: totalRatings,
                  distribution: distribution,
                  l: l,
                ),
                SizedBox(height: 2.h),
                _SectionHeader(title: l.reviews),
                SizedBox(height: 1.h),
              ],
              ..._buildReviewsContent(context, l),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReviewsContent(
      BuildContext context, AppLocalizations l) {
    if (_hasError && _reviews.isEmpty) {
      return [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 4.h),
              Text(l.errorLoadingStatistics,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _loadPage(1),
                style: MaterialTheme.getPrimaryButtonStyle(context),
                child: Text(l.tryAgain),
              ),
            ],
          ),
        ),
      ];
    }
    if (_isLoading && _reviews.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: MaterialTheme.getCircularProgressIndicator(context),
          ),
        ),
      ];
    }
    if (_reviews.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(l.noRatingsYet,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ),
      ];
    }
    return [
      ..._reviews.map((r) => _DriverReviewCard(review: r, l: l)),
      if (_currentPage < _lastPage) ...[
        SizedBox(height: 0.5.h),
        if (_isLoading)
          Center(
              child:
                  MaterialTheme.getCircularProgressIndicator(context))
        else
          Center(
            child: TextButton(
              onPressed: () => _loadPage(_currentPage + 1),
              child: Text(l.loadMore),
            ),
          ),
      ],
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _DriverSummary {
  final int id;
  final String name;
  final double avgRating;
  final int totalRatings;

  const _DriverSummary({
    required this.id,
    required this.name,
    required this.avgRating,
    required this.totalRatings,
  });
}

class _DriverReview {
  final int id;
  final String customerName;
  final String restaurantName;
  final int? driverRating;
  final int? deliverySpeedRating;
  final String? driverComment;
  final String? comment;
  final String ratedAt;

  const _DriverReview({
    required this.id,
    required this.customerName,
    required this.restaurantName,
    this.driverRating,
    this.deliverySpeedRating,
    this.driverComment,
    this.comment,
    required this.ratedAt,
  });

  factory _DriverReview.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    final restaurant = json['restaurant'] as Map<String, dynamic>? ?? {};
    return _DriverReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerName: customer['name']?.toString() ?? '-',
      restaurantName: restaurant['name']?.toString() ?? '-',
      driverRating: (json['driver_rating'] as num?)?.toInt(),
      deliverySpeedRating:
          (json['delivery_speed_rating'] as num?)?.toInt(),
      driverComment: json['driver_comment']?.toString(),
      comment: json['comment']?.toString(),
      ratedAt: json['rated_at']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers & widgets
// ─────────────────────────────────────────────────────────────────────────────

Map<int, int> _parseDistribution(Map<String, dynamic> raw) {
  final dist = <int, int>{};
  for (int i = 1; i <= 5; i++) {
    final v = raw[i.toString()];
    dist[i] = v is num ? v.toInt() : 0;
  }
  return dist;
}

Color _starColor(double rating) {
  if (rating >= 4.5) return Colors.green;
  if (rating >= 3.5) return Colors.amber;
  if (rating >= 2.5) return Colors.orange;
  return Colors.red;
}

String _formatDate(String ratedAt) {
  try {
    final dt = DateTime.parse(ratedAt);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return ratedAt.length > 10 ? ratedAt.substring(0, 10) : ratedAt;
  }
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

class _StatsHeader extends StatelessWidget {
  final double avgRating;
  final int totalRatings;
  final Map<int, int> distribution;
  final AppLocalizations l;

  const _StatsHeader({
    required this.avgRating,
    required this.totalRatings,
    required this.distribution,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final color = _starColor(avgRating);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Icon(Icons.star_rounded, size: 12.w, color: color),
                SizedBox(width: 4.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          l.outOf5,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$totalRatings ${l.totalRatings}',
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
              ],
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
              borderRadius: MaterialTheme.getBorderRadiusCard()),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = distribution[star] ?? 0;
                final fraction =
                    totalRatings > 0 ? count / totalRatings : 0.0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 0.8.h),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 4.w, color: Colors.amber),
                      SizedBox(width: 1.w),
                      Text('$star',
                          style:
                              Theme.of(context).textTheme.bodySmall),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 8,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
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
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  final _DriverSummary driver;
  final VoidCallback onTap;

  const _DriverCard({required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _starColor(driver.avgRating);
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 1.6.h),
      shape: RoundedRectangleBorder(
          borderRadius: MaterialTheme.getBorderRadiusCard()),
      child: InkWell(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
        onTap: onTap,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: MaterialTheme.getBorderRadiusButton(),
                ),
                child: Center(
                  child: Icon(Icons.delivery_dining,
                      color: Theme.of(context).colorScheme.primary,
                      size: 5.w),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      '${driver.totalRatings} ${l.reviews}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: color, size: 5.w),
                  SizedBox(width: 1.w),
                  Text(
                    driver.avgRating.toStringAsFixed(1),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 1.w),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverReviewCard extends StatelessWidget {
  final _DriverReview review;
  final AppLocalizations l;

  const _DriverReviewCard({required this.review, required this.l});

  @override
  Widget build(BuildContext context) {
    final displayComment = (review.driverComment != null &&
            review.driverComment!.isNotEmpty)
        ? review.driverComment
        : (review.comment != null && review.comment!.isNotEmpty)
            ? review.comment
            : null;

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 1.6.h),
      shape: RoundedRectangleBorder(
          borderRadius: MaterialTheme.getBorderRadiusCard()),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.store,
                            size: 3.w,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              review.restaurantName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ' · ${_formatDate(review.ratedAt)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (review.driverRating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < review.driverRating!
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 4.w,
                      );
                    }),
                  ),
              ],
            ),
            if (displayComment != null) ...[
              SizedBox(height: 0.8.h),
              Text(
                displayComment,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
            if (review.deliverySpeedRating != null) ...[
              SizedBox(height: 0.8.h),
              _Badge(
                icon: Icons.speed,
                label: '${review.deliverySpeedRating}★',
                color: Colors.teal,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 3.w, color: color),
          SizedBox(width: 0.8.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
