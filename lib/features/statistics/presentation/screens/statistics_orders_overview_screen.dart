import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsOrdersOverviewScreen extends StatefulWidget {
  static const String route = '/statistics/orders/overview';

  const StatisticsOrdersOverviewScreen({super.key});

  @override
  State<StatisticsOrdersOverviewScreen> createState() =>
      _StatisticsOrdersOverviewScreenState();
}

class _StatisticsOrdersOverviewScreenState
    extends State<StatisticsOrdersOverviewScreen> {
  late Future<Map<String, int>> _statsFuture;
  String _selectedPeriod = 'week';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    final range = PeriodCalculator.calculatePeriodRange(_selectedPeriod);
    _dateFrom = range.startDate;
    _dateTo = range.endDate;
    _statsFuture = _fetchOrderStats();
  }

  Future<Map<String, int>> _fetchOrderStats() async {
    final dio = sl<Dio>();
    final queryParams = <String, dynamic>{};
    if (_dateFrom != null) {
      queryParams['date_from'] =
          '${_dateFrom!.year.toString().padLeft(4, '0')}-'
          '${_dateFrom!.month.toString().padLeft(2, '0')}-'
          '${_dateFrom!.day.toString().padLeft(2, '0')}';
    }
    if (_dateTo != null) {
      queryParams['date_to'] =
          '${_dateTo!.year.toString().padLeft(4, '0')}-'
          '${_dateTo!.month.toString().padLeft(2, '0')}-'
          '${_dateTo!.day.toString().padLeft(2, '0')}';
    }
    final response = await dio.get(
      ApiConstance.managerOrderStatisticsPath,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      int readInt(String key) {
        final value = data[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        return int.tryParse(value?.toString() ?? '') ?? 0;
      }

      return {
        'placed': readInt('placed'),
        'pending_verification': readInt('pending_verification'),
        'accepted_by_operator': readInt('accepted_by_operator'),
        'accepted_by_restaurant': readInt('accepted_by_restaurant'),
        'rejected_by_operator': readInt('rejected_by_operator'),
        'rejected_by_restaurant': readInt('rejected_by_restaurant'),
        'accepted_by_driver': readInt('accepted_by_driver'),
        'cancelled': readInt('cancelled'),
        'delivered': readInt('delivered'),
      };
    }

    throw Exception('Failed to load order statistics');
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _fetchOrderStats();
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
                onPeriodChanged: (String selectedValue) {
                  DateTime? dateFrom;
                  DateTime? dateTo;
                  if (selectedValue == 'dateRange') {
                    final range = PeriodCalculator.getDefaultDateRange();
                    dateFrom = range.startDate;
                    dateTo = range.endDate;
                  } else if (selectedValue == 'all') {
                    final range = PeriodCalculator.calculatePeriodRange('all');
                    dateFrom = range.startDate;
                    dateTo = range.endDate;
                  } else {
                    final range = PeriodCalculator.calculatePeriodRange(
                      selectedValue,
                    );
                    dateFrom = range.startDate;
                    dateTo = range.endDate;
                  }
                  setState(() {
                    _selectedPeriod = selectedValue;
                    _dateFrom = dateFrom;
                    _dateTo = dateTo;
                  });
                  _refreshStats();
                },
                onDateFromSelected: (currentDate) async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    final pickedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                    );
                    DateTime? newDateTo = _dateTo;
                    if (newDateTo != null && pickedDate.isAfter(newDateTo)) {
                      newDateTo = pickedDate.add(const Duration(days: 6));
                    }
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateFrom = pickedDate;
                      _dateTo = newDateTo;
                    });
                    _refreshStats();
                  }
                },
                onDateToSelected: (currentDate) async {
                  final firstDate = _dateFrom ?? DateTime(2020);
                  final lastDate = DateTime.now();
                  final initialDate = currentDate ?? lastDate;
                  final adjustedInitialDate = initialDate.isBefore(firstDate)
                      ? firstDate
                      : initialDate;
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: adjustedInitialDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );
                  if (picked != null) {
                    final pickedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                    );
                    setState(() {
                      _selectedPeriod = 'dateRange';
                      _dateTo = pickedDate;
                    });
                    _refreshStats();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, int>>(
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

                  final data = snapshot.data;
                  if (data == null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Text(
                          l.noStatisticsAvailable,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    );
                  }

                  final orderStats = <_OrderStatItem>[
                    _OrderStatItem(
                      label: l.ordersPlaced,
                      count: data['placed'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersPendingVerification,
                      count: data['pending_verification'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersAcceptedByOperator,
                      count: data['accepted_by_operator'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersAcceptedByRestaurant,
                      count: data['accepted_by_restaurant'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersRejectedByOperator,
                      count: data['rejected_by_operator'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersRejectedByRestaurant,
                      count: data['rejected_by_restaurant'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersAcceptedByDriver,
                      count: data['accepted_by_driver'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.ordersCancelled,
                      count: data['cancelled'] ?? 0,
                    ),
                    _OrderStatItem(
                      label: l.delivered,
                      count: data['delivered'] ?? 0,
                    ),
                  ];

                  return RefreshIndicator(
                    onRefresh: _refreshStats,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...orderStats.map(
                            (item) => _OrderStatCard(item: item),
                          ),
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

class _OrderStatItem {
  final String label;
  final int count;

  const _OrderStatItem({required this.label, required this.count});
}

class _OrderStatCard extends StatelessWidget {
  final _OrderStatItem item;

  const _OrderStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 1.6.h),
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusCard(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: MaterialTheme.getBorderRadiusButton(),
              ),
              child: Text(
                item.count.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
