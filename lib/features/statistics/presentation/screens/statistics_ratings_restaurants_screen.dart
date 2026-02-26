import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Restaurant list screen
// ─────────────────────────────────────────────────────────────────────────────

class StatisticsRatingsRestaurantsScreen extends StatefulWidget {
  static const String route = '/statistics/ratings/restaurants';

  const StatisticsRatingsRestaurantsScreen({super.key});

  @override
  State<StatisticsRatingsRestaurantsScreen> createState() =>
      _StatisticsRatingsRestaurantsScreenState();
}

class _StatisticsRatingsRestaurantsScreenState
    extends State<StatisticsRatingsRestaurantsScreen> {
  late Future<List<_RestaurantSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchRestaurants();
  }

  Future<List<_RestaurantSummary>> _fetchRestaurants() async {
    final dio = sl<Dio>();
    final response = await dio.get(
      ApiConstance.managerRestaurantsPath,
      queryParameters: {'per_page': 100},
    );
    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final items = response.data['data'] as List? ?? [];
      return items.whereType<Map<String, dynamic>>().map((e) {
        return _RestaurantSummary(
          id: (e['id'] as num?)?.toInt() ?? 0,
          name: e['name']?.toString() ?? '',
          rating: (e['rating'] as num?)?.toDouble() ?? 0.0,
          totalReviews: (e['total_reviews'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }
    throw Exception('Failed to load restaurants');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.restaurantsTab)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: FutureBuilder<List<_RestaurantSummary>>(
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => _future = _fetchRestaurants()),
                        style: MaterialTheme.getPrimaryButtonStyle(context),
                        child: Text(l.tryAgain),
                      ),
                    ],
                  ),
                ),
              );
            }

            final restaurants = snapshot.data ?? [];
            if (restaurants.isEmpty) {
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
                setState(() => _future = _fetchRestaurants());
                try {
                  await _future;
                } catch (_) {}
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(4.w),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final r = restaurants[index];
                  return _RestaurantCard(
                    restaurant: r,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _RestaurantDetailPage(restaurant: r),
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
// Restaurant detail page (individual reviews)
// ─────────────────────────────────────────────────────────────────────────────

class _RestaurantDetailPage extends StatefulWidget {
  final _RestaurantSummary restaurant;

  const _RestaurantDetailPage({required this.restaurant});

  @override
  State<_RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<_RestaurantDetailPage> {
  final List<_Review> _reviews = [];
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
        ApiConstance.managerRestaurantRatingsPath(widget.restaurant.id),
        queryParameters: {'page': page, 'per_page': 20},
      );
      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        final items = (response.data['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => _Review.fromJson(e, isRestaurant: true))
            .toList();
        final meta = response.data['meta'] as Map<String, dynamic>? ?? {};
        final pagination = meta['pagination'] as Map<String, dynamic>? ?? {};
        setState(() {
          if (page == 1) {
            _reviews.clear();
            _stats = meta['statistics'] as Map<String, dynamic>?;
          }
          _reviews.addAll(items);
          _currentPage = (pagination['current_page'] as num?)?.toInt() ?? page;
          _lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
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
        (_stats?['average_rating'] as num?)?.toDouble() ??
        widget.restaurant.rating;
    final totalRatings =
        (_stats?['total_ratings'] as num?)?.toInt() ??
        widget.restaurant.totalReviews;
    final rawDist =
        _stats?['rating_distribution'] as Map<String, dynamic>? ?? {};
    final distribution = _parseDistribution(rawDist);

    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurant.name)),
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

  List<Widget> _buildReviewsContent(BuildContext context, AppLocalizations l) {
    if (_hasError && _reviews.isEmpty) {
      return [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 4.h),
              Text(
                l.errorLoadingStatistics,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
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
            child: Text(
              l.noRatingsYet,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      ..._reviews.map((r) => _ReviewCard(review: r, l: l)),
      if (_currentPage < _lastPage) ...[
        SizedBox(height: 0.5.h),
        if (_isLoading)
          Center(child: MaterialTheme.getCircularProgressIndicator(context))
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

class _RestaurantSummary {
  final int id;
  final String name;
  final double rating;
  final int totalReviews;

  const _RestaurantSummary({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalReviews,
  });
}

class _Review {
  final int id;
  final String customerName;
  final int overallRating;
  final int? foodQualityRating;
  final int? restaurantServiceRating;
  final int? driverRating;
  final int? deliverySpeedRating;
  final String? comment;
  final bool? wouldReorder;
  final bool? wouldRecommend;
  final String ratedAt;

  const _Review({
    required this.id,
    required this.customerName,
    required this.overallRating,
    this.foodQualityRating,
    this.restaurantServiceRating,
    this.driverRating,
    this.deliverySpeedRating,
    this.comment,
    this.wouldReorder,
    this.wouldRecommend,
    required this.ratedAt,
  });

  factory _Review.fromJson(
    Map<String, dynamic> json, {
    bool isRestaurant = true,
  }) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    return _Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerName: customer['name']?.toString() ?? '-',
      overallRating: (json['overall_rating'] as num?)?.toInt() ?? 0,
      foodQualityRating: (json['food_quality_rating'] as num?)?.toInt(),
      restaurantServiceRating: (json['restaurant_service_rating'] as num?)
          ?.toInt(),
      driverRating: (json['driver_rating'] as num?)?.toInt(),
      deliverySpeedRating: (json['delivery_speed_rating'] as num?)?.toInt(),
      comment: json['comment']?.toString(),
      wouldReorder: json['would_reorder'] as bool?,
      wouldRecommend: json['would_recommend'] as bool?,
      ratedAt: json['rated_at']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          l.outOf5,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '$totalRatings ${l.totalRatings}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
            borderRadius: MaterialTheme.getBorderRadiusCard(),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = distribution[star] ?? 0;
                final fraction = totalRatings > 0 ? count / totalRatings : 0.0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 0.8.h),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: 4.w, color: Colors.amber),
                      SizedBox(width: 1.w),
                      Text(
                        '$star',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
        ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final _RestaurantSummary restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _starColor(restaurant.rating);
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 1.6.h),
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
      child: InkWell(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: MaterialTheme.getBorderRadiusButton(),
                ),
                child: Center(
                  child: Icon(
                    Icons.store,
                    color: Theme.of(context).colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      '${restaurant.totalReviews} ${l.reviews}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    restaurant.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 1.w),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.35),
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  final AppLocalizations l;

  const _ReviewCard({required this.review, required this.l});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 1.6.h),
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _formatDate(review.ratedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.overallRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 4.w,
                    );
                  }),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              SizedBox(height: 0.8.h),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
            SizedBox(height: 0.8.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 0.5.h,
              children: [
                if (review.foodQualityRating != null)
                  _Badge(
                    icon: Icons.restaurant,
                    label: '${review.foodQualityRating}★',
                    color: Colors.orange,
                  ),
                if (review.restaurantServiceRating != null)
                  _Badge(
                    icon: Icons.store,
                    label: '${review.restaurantServiceRating}★',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (review.driverRating != null)
                  _Badge(
                    icon: Icons.delivery_dining,
                    label: '${review.driverRating}★',
                    color: Colors.blue,
                  ),
                if (review.deliverySpeedRating != null)
                  _Badge(
                    icon: Icons.speed,
                    label: '${review.deliverySpeedRating}★',
                    color: Colors.teal,
                  ),
                if (review.wouldReorder == true)
                  _Badge(
                    icon: Icons.repeat,
                    label: l.reorderRate.split(' ').first,
                    color: Colors.green,
                  ),
                if (review.wouldRecommend == true)
                  _Badge(
                    icon: Icons.thumb_up,
                    label: l.recommendRate.split(' ').first,
                    color: Colors.indigo,
                  ),
              ],
            ),
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

  const _Badge({required this.icon, required this.label, required this.color});

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
