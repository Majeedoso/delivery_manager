import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsMoneyOverviewScreen extends StatefulWidget {
  static const String route = '/statistics/money/overview';

  const StatisticsMoneyOverviewScreen({super.key});

  @override
  State<StatisticsMoneyOverviewScreen> createState() =>
      _StatisticsMoneyOverviewScreenState();
}

class _StatisticsMoneyOverviewScreenState
    extends State<StatisticsMoneyOverviewScreen> {
  late Future<_MoneyStats> _statsFuture;
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

  Future<_MoneyStats> _fetchStats() async {
    final dio = sl<Dio>();
    final q = <String, dynamic>{};
    if (_dateFrom != null) q['start_date'] = _fmt(_dateFrom!);
    if (_dateTo != null) q['end_date'] = _fmt(_dateTo!);

    final response = await dio.get(
      ApiConstance.managerAnalyticsRevenuePath,
      queryParameters: q.isEmpty ? null : q,
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final summary = data['summary'] as Map<String, dynamic>? ?? {};

      String readStr(String key) => summary[key]?.toString() ?? '0.00';

      return _MoneyStats(
        totalRevenue: readStr('total_revenue'),
        subtotalRevenue: readStr('subtotal_revenue'),
        deliveryFees: readStr('delivery_fees'),
        platformRevenue: readStr('platform_revenue'),
        driverEarnings: readStr('driver_earnings'),
        restaurantEarnings: readStr('restaurant_earnings'),
        averageOrderValue: readStr('average_order_value'),
      );
    }
    throw Exception('Failed to load money statistics');
  }

  Future<void> _refresh() async {
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
                  _refresh();
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
                    _refresh();
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
                    _refresh();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<_MoneyStats>(
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
                              onPressed: _refresh,
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
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(title: l.revenueOverview),
                          SizedBox(height: 1.h),
                          _MoneyCard(
                            label: l.totalRevenue,
                            value: '${stats.totalRevenue} ${l.currency}',
                            icon: Icons.attach_money,
                            description: l.totalRevenueDesc,
                          ),
                          _MoneyCard(
                            label: l.subtotalRevenue,
                            value: '${stats.subtotalRevenue} ${l.currency}',
                            icon: Icons.receipt,
                            description: l.subtotalRevenueDesc,
                          ),
                          _MoneyCard(
                            label: l.deliveryFeesCollected,
                            value: '${stats.deliveryFees} ${l.currency}',
                            icon: Icons.delivery_dining,
                            description: l.deliveryFeesDesc,
                          ),
                          SizedBox(height: 2.h),
                          _SectionHeader(title: l.platformEarnings),
                          SizedBox(height: 1.h),
                          _MoneyCard(
                            label: l.platformShort,
                            value: '${stats.platformRevenue} ${l.currency}',
                            icon: Icons.business,
                            description: l.platformRevenueDesc,
                          ),
                          _MoneyCard(
                            label: l.driversShort,
                            value: '${stats.driverEarnings} ${l.currency}',
                            icon: Icons.person,
                            description: l.driversRevenueDesc,
                          ),
                          _MoneyCard(
                            label: l.restaurantsShort,
                            value: '${stats.restaurantEarnings} ${l.currency}',
                            icon: Icons.restaurant,
                            description: l.restaurantsRevenueDesc,
                          ),
                          SizedBox(height: 2.h),
                          _SectionHeader(title: l.orderMetrics),
                          SizedBox(height: 1.h),
                          _MoneyCard(
                            label: l.averageOrderValue,
                            value: '${stats.averageOrderValue} ${l.currency}',
                            icon: Icons.shopping_bag,
                            description: l.averageOrderValueDesc,
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

class _MoneyStats {
  final String totalRevenue;
  final String subtotalRevenue;
  final String deliveryFees;
  final String platformRevenue;
  final String driverEarnings;
  final String restaurantEarnings;
  final String averageOrderValue;

  const _MoneyStats({
    required this.totalRevenue,
    required this.subtotalRevenue,
    required this.deliveryFees,
    required this.platformRevenue,
    required this.driverEarnings,
    required this.restaurantEarnings,
    required this.averageOrderValue,
  });
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

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

class _MoneyCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? description;

  const _MoneyCard({
    required this.label,
    required this.value,
    required this.icon,
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
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 1.6.h),
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
      child: InkWell(
        onTap: description != null ? () => _showInfo(context) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: MaterialTheme.getBorderRadiusButton(),
                ),
                child: Icon(
                  icon,
                  size: 5.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
