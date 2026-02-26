import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsMoneyRestaurantsScreen extends StatefulWidget {
  static const String route = '/statistics/money/restaurants';

  const StatisticsMoneyRestaurantsScreen({super.key});

  @override
  State<StatisticsMoneyRestaurantsScreen> createState() =>
      _StatisticsMoneyRestaurantsScreenState();
}

class _StatisticsMoneyRestaurantsScreenState
    extends State<StatisticsMoneyRestaurantsScreen> {
  final List<_RestaurantItem> _restaurants = [];
  int _currentPage = 0;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _hasError = false;

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
        ApiConstance.managerRestaurantsPath,
        queryParameters: {'page': page, 'per_page': 10},
      );
      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        final items = (response.data['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(
              (e) => _RestaurantItem(
                id: (e['id'] as num?)?.toInt() ?? 0,
                name: e['name']?.toString() ?? '',
              ),
            )
            .toList();
        final meta = response.data['meta'] as Map<String, dynamic>? ?? {};
        final pagination = meta['pagination'] as Map<String, dynamic>? ?? {};
        setState(() {
          if (page == 1) _restaurants.clear();
          _restaurants.addAll(items);
          _currentPage = (pagination['current_page'] as num?)?.toInt() ?? page;
          _lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
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
    return Scaffold(
      appBar: AppBar(title: Text(l.restaurantsTab)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: _buildBody(context, l),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l) {
    // Initial load
    if (_isLoading && _restaurants.isEmpty) {
      return Center(child: MaterialTheme.getCircularProgressIndicator(context));
    }

    // Initial error
    if (_hasError && _restaurants.isEmpty) {
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
                onPressed: () => _loadPage(1),
                style: MaterialTheme.getPrimaryButtonStyle(context),
                child: Text(l.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (!_isLoading && _restaurants.isEmpty) {
      return Center(
        child: Text(
          l.noStatisticsAvailable,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPage(1),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        itemCount: _restaurants.length + 1, // +1 for footer
        itemBuilder: (context, index) {
          if (index < _restaurants.length) {
            final r = _restaurants[index];
            return _RestaurantCard(
              restaurant: r,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.statisticsMoneyRestaurantDetail,
                arguments: {'id': r.id, 'name': r.name},
              ),
            );
          }
          // Footer: load more button or spinner
          if (_currentPage < _lastPage) {
            if (_isLoading) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Center(
                  child: MaterialTheme.getCircularProgressIndicator(context),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: () => _loadPage(_currentPage + 1),
                  child: Text(l.loadMore),
                ),
              ),
            );
          }
          return SizedBox(height: 2.h);
        },
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _RestaurantItem {
  final int id;
  final String name;

  const _RestaurantItem({required this.id, required this.name});
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final _RestaurantItem restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
