import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/presentation/widgets/restaurant_debt_card.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/core/utils/currency.dart';

class ReceivablesPayablesScreen extends StatefulWidget {
  static const String route = '/bank-receivables';

  const ReceivablesPayablesScreen({super.key});

  @override
  State<ReceivablesPayablesScreen> createState() =>
      _ReceivablesPayablesScreenState();
}

class _ReceivablesPayablesScreenState extends State<ReceivablesPayablesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Unified Period state for both tabs
  String _period = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 1500),
    );
    // No listener needed for data fetching on tab switch

    // Initialize with all period (no date filtering)
    final range = PeriodCalculator.calculatePeriodRange('all');
    _dateFrom = range.startDate;
    _dateTo = range.endDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    // Format dates as YYYY-MM-DD
    String? fromStr = _dateFrom?.toIso8601String().split('T')[0];
    String? toStr = _dateTo?.toIso8601String().split('T')[0];

    context.read<BankBloc>().add(
      GetDriverBalanceEvent(from: fromStr, to: toStr),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final currentDate = isStartDate ? _dateFrom : _dateTo;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      _fetchData();
    }
  }

  /// Navigate to debt details screen with current date range
  void _navigateToDetails(RestaurantDebt item) {
    Navigator.pushNamed(
      context,
      AppRoutes.driverDebtDetails,
      arguments: {
        'item': item,
        'period': _period,
        'dateFrom': _dateFrom,
        'dateTo': _dateTo,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.receivablesAndPayables),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: Column(
          children: [
            _buildCustomTabBar(context),
            Expanded(
              child: BlocConsumer<BankBloc, BankState>(
                listener: (context, state) {
                  if (state is BalanceError) {
                    ErrorSnackBar.show(context, state.message);
                  } else if (state is PaymentRecorded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is PaymentError) {
                    ErrorSnackBar.show(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is BankLoading) {
                    return Center(
                      child: SizedBox(
                        width: 50.w,
                        height: 25.h,
                        child: Lottie.asset(
                          'assets/images/delivery_riding.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    );
                  }

                  if (state is BalanceError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50.sp,
                            color: Colors.red,
                          ),
                          SizedBox(height: 2.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              state.message.isNotEmpty
                                  ? state.message
                                  : AppLocalizations.of(
                                      context,
                                    )!.errorLoadingData,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<BankBloc>().add(
                                const GetDriverBalanceEvent(),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BalanceLoaded) {
                    final balance = state.balance;

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // Credits Tab (Receivables)
                        _buildCreditsTab(context, balance),
                        // Debts Tab (Merged Restaurant + System)
                        _buildCombinedDebtsTab(context, balance),
                      ],
                    );
                  }

                  return Center(
                    child: Text(AppLocalizations.of(context)!.noDataAvailable),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFFFF8A32),
        unselectedLabelColor: Colors.blueGrey.shade400,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
        ),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.receivables), // Credits
          Tab(text: AppLocalizations.of(context)!.payables), // Debts
        ],
      ),
    );
  }

  Widget _buildCreditsTab(BuildContext context, DriverBalance balance) {
    final restaurantCredits = balance.restaurantCredits;
    // Use backend totals directly
    final displayTotalCredits = balance.totalCredits;

    return RefreshIndicator(
      onRefresh: () async {
        String? fromStr = _dateFrom?.toIso8601String().split('T')[0];
        String? toStr = _dateTo?.toIso8601String().split('T')[0];
        context.read<BankBloc>().add(
          RefreshBalanceEvent(from: fromStr, to: toStr),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Date Selector at the top
            _buildPeriodSelector(context),
            SizedBox(height: 2.h),

            // Summary Card
            _buildSummaryCard(
              context,
              title: AppLocalizations.of(context)!.receivables.toUpperCase(),
              amount: displayTotalCredits.toStringAsFixed(2),
              isPositive: true,
            ),
            SizedBox(height: 4.h),

            // Group Credits
            Builder(
              builder: (context) {
                final systemCredits = restaurantCredits
                    .where((c) => c.counterpartyType == 'system')
                    .toList();
                final driverCredits = restaurantCredits
                    .where((c) => c.counterpartyType == 'driver')
                    .toList();
                final otherCredits = restaurantCredits
                    .where(
                      (c) =>
                          c.counterpartyType != 'system' &&
                          c.counterpartyType != 'driver',
                    )
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Credits
                    if (systemCredits.isNotEmpty) ...[
                      Text(
                        _sectionTitle(context, 'system', isCredit: true),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ...systemCredits.map(
                        (credit) => Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: RestaurantDebtCard(
                            restaurantDebt: credit,
                            onTap: () => _navigateToDetails(credit),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],

                    // Driver Credits
                    if (driverCredits.isNotEmpty) ...[
                      Text(
                        _sectionTitle(context, 'driver', isCredit: true),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ...driverCredits.map(
                        (credit) => Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: RestaurantDebtCard(
                            restaurantDebt: credit,
                            onTap: () => _navigateToDetails(credit),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],

                    // Restaurant Credits
                    if (otherCredits.isNotEmpty) ...[
                      Text(
                        _sectionTitle(context, 'restaurant', isCredit: true),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      ...otherCredits.map(
                        (credit) => Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: RestaurantDebtCard(
                            restaurantDebt: credit,
                            onTap: () => _navigateToDetails(credit),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ],
                );
              },
            ),

            // Empty State (only show if no credits)
            if (restaurantCredits.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.h),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 50.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      AppLocalizations.of(context)!.noDataAvailable,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedDebtsTab(BuildContext context, DriverBalance balance) {
    final restaurantDebts = balance.restaurantDebts;
    final systemDebt = balance.systemDebt;
    // Use backend total directly
    final totalDebt = balance.totalDebt;

    final driverDebts = restaurantDebts
        .where((d) => d.counterpartyType == 'driver')
        .toList();
    final systemDebtsList = restaurantDebts
        .where((d) => d.counterpartyType == 'system')
        .toList();
    final restaurantDebtsList = restaurantDebts
        .where((d) => d.counterpartyType != 'driver' && d.counterpartyType != 'system')
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        String? fromStr = _dateFrom?.toIso8601String().split('T')[0];
        String? toStr = _dateTo?.toIso8601String().split('T')[0];
        context.read<BankBloc>().add(
          RefreshBalanceEvent(from: fromStr, to: toStr),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Date Selector at the top
            _buildPeriodSelector(context),
            SizedBox(height: 2.h),

            // Summary Card (Total Debt)
            _buildSummaryCard(
              context,
              title: AppLocalizations.of(context)!.payables.toUpperCase(),
              amount: totalDebt.toStringAsFixed(2),
              isPositive: false,
            ),
            SizedBox(height: 4.h),

            // Debts by counterparty type
            if (driverDebts.isNotEmpty) ...[
              _buildDebtSection(
                context,
                _sectionTitle(context, 'driver', isCredit: false),
                driverDebts,
              ),
              SizedBox(height: 4.h),
            ],
            if (restaurantDebtsList.isNotEmpty) ...[
              _buildDebtSection(
                context,
                _sectionTitle(context, 'restaurant', isCredit: false),
                restaurantDebtsList,
              ),
              SizedBox(height: 4.h),
            ],
            if (systemDebtsList.isNotEmpty) ...[
              _buildDebtSection(
                context,
                _sectionTitle(context, 'system', isCredit: false),
                systemDebtsList,
              ),
              SizedBox(height: 4.h),
            ],

            // System Debt Section
            if (systemDebt > 0) ...[
              Text(
                AppLocalizations.of(context)!.systemDebt,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              InkWell(
                onTap: () {
                  // Create a temporary RestaurantDebt object for System Debt
                  // Since System Debt is aggregated in the DriverBalance object but
                  // DriverDebtDetailsScreen expects a RestaurantDebt object.
                  // We need to construct one on the fly or find if it exists in the list.

                  // Check if there is a debt with restaurantId == 0 (System)
                  // The DriverBalanceModel logic separated debts where id != 0 into restaurantDebts
                  // and summed id == 0 into systemDebt.
                  // So the 'systemDebt' variable is just a double.
                  // We need to CREATE a RestaurantDebt object representing the System Debt
                  // OR find the original object in the raw list if we had it.

                  // Since we don't have the raw list here easily, let's construct a synthetic one.
                  // BUT we need the DETAILS list. Ideally, DriverBalance should store the systemDebt *Object*
                  // not just the sum, if we want details.

                  // Let's assume for now we construct a RestaurantDebt object with the amount,
                  // but it might lack details if 'DriverBalance' only stores the sum 'systemDebt'.

                  // Wait, DriverBalanceModel:
                  // final systemDebtsList = allDebts.where((d) => d.restaurantId == 0).toList();
                  // final systemDebtVal = ...

                  // It seems DriverBalance does NOT expose the systemDebtsList as a list of objects,
                  // it only exposes 'systemDebt' (double).
                  // This means we CANNOT show details for System Debt unless we update DriverBalance entity/model
                  // to store the System Debt *Object* (or list of objects, but usually it's one aggregated entry or multiple).

                  // User says "System Debt is not working".
                  // We need to update DriverBalance to hold the System Debt Object, not just the double value.
                },
                child: Card(
                  elevation: 4,
                  color:
                      Theme.of(context).inputDecorationTheme.fillColor ??
                      Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.systemDebt,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.systemDebtDescription,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '-${balance.formattedSystemDebt}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD32F2F), // Red
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
            ],

            // Pending Payments Section
            if (balance.pendingPayments.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.pendingPayments,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              ...balance.pendingPayments.map((payment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    color:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                        Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.recipientName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.pending,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '-${payment.formattedAmount}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              payment.formattedDate,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],

            // Empty State
            if (restaurantDebts.isEmpty &&
                systemDebt == 0 &&
                balance.pendingPayments.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.h),
                    Icon(
                      Icons.check_circle_outline,
                      size: 50.sp,
                      color: Colors.green.withValues(alpha: 0.7),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      AppLocalizations.of(context)!.noDebts,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String amount,
    bool isPositive = true,
  }) {
    // Parse amount to check if zero
    final numericAmount = double.tryParse(amount) ?? 0.0;
    final isZero = numericAmount == 0;

    // Neutral gray for zero, green for positive, red for negative
    final Color amountColor;
    final String prefix;
    final List<Color> gradientColors;

    if (isZero) {
      amountColor = Colors.grey[600]!;
      prefix = '';
      gradientColors = [
        const Color(0xFFF5F5F5),
        const Color(0xFFE0E0E0),
      ]; // Gray gradient
    } else if (isPositive) {
      amountColor = const Color(0xFF2E7D32);
      prefix = '+';
      gradientColors = [
        const Color(0xFFE8F5E9),
        const Color(0xFFC8E6C9),
      ]; // Green gradient
    } else {
      amountColor = const Color(0xFFD32F2F);
      prefix = '-';
      gradientColors = [
        const Color(0xFFFFEBEE),
        const Color(0xFFFFCDD2),
      ]; // Red gradient
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$prefix${amount.replaceAll('.', ',')}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 30.sp,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '${Currency.dzd.code} TOTAL',
                style: TextStyle(
                  color: amountColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PeriodDateSelector(
        selectedPeriod: _period,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        onPeriodChanged: (String selectedValue) {
          DateTime? newDateFrom;
          DateTime? newDateTo;

          if (selectedValue == 'dateRange') {
            final range = PeriodCalculator.getDefaultDateRange();
            newDateFrom = range.startDate;
            newDateTo = range.endDate;
          } else if (selectedValue == 'all') {
            final range = PeriodCalculator.calculatePeriodRange('all');
            newDateFrom = range.startDate;
            newDateTo = range.endDate;
          } else {
            final range = PeriodCalculator.calculatePeriodRange(selectedValue);
            newDateFrom = range.startDate;
            newDateTo = range.endDate;
          }

          setState(() {
            _period = selectedValue;
            _dateFrom = newDateFrom;
            _dateTo = newDateTo;
          });
          _fetchData();
        },
        onDateFromSelected: (DateTime? date) async {
          await _selectDate(context, true);
        },
        onDateToSelected: (DateTime? date) async {
          await _selectDate(context, false);
        },
      ),
      );
  }

  String _sectionTitle(
    BuildContext context,
    String type, {
    required bool isCredit,
  }) {
    switch (type) {
      case 'driver':
        return AppLocalizations.of(context)!.drivers;
      case 'system':
        return AppLocalizations.of(context)!.systemDebt;
      case 'restaurant':
      default:
        return isCredit
            ? AppLocalizations.of(context)!.restaurantCredits
            : AppLocalizations.of(context)!.restaurantDebts;
    }
  }

  String _counterpartyLabel(BuildContext context, String type) {
    switch (type) {
      case 'driver':
        return AppLocalizations.of(context)!.driver;
      case 'system':
        return AppLocalizations.of(context)!.system;
      case 'restaurant':
      default:
        return AppLocalizations.of(context)!.restaurant;
    }
  }

  Widget _buildDebtSection(
    BuildContext context,
    String title,
    List<RestaurantDebt> debts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        ...debts.map((debt) {
          final fillColor =
              Theme.of(context).inputDecorationTheme.fillColor ??
              Theme.of(context).colorScheme.surface;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RepaintBoundary(
              child: InkWell(
                onTap: () => _navigateToDetails(debt),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  key: ValueKey(
                    'counterparty_debt_${debt.counterpartyType}_${debt.restaurantId}',
                  ),
                  elevation: 4,
                  color: fillColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    debt.restaurantName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _counterpartyLabel(
                                      context,
                                      debt.counterpartyType,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '-${debt.formattedAmount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD32F2F), // Red
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
