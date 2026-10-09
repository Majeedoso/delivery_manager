import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_credit_debt_detail.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/server_time.dart';
import 'package:delivery_manager/core/utils/amounts.dart';

class DriverDebtDetailsScreen extends StatefulWidget {
  static const String route = '/driver-debt-details';
  final RestaurantDebt debtItem;
  final String? initialPeriod;
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;

  const DriverDebtDetailsScreen({
    super.key,
    required this.debtItem,
    this.initialPeriod,
    this.initialDateFrom,
    this.initialDateTo,
  });

  @override
  State<DriverDebtDetailsScreen> createState() =>
      _DriverDebtDetailsScreenState();
}

class _DriverDebtDetailsScreenState extends State<DriverDebtDetailsScreen> {
  String _period = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  // Store the current counterparty's data (refreshed from API)
  RestaurantDebt? _currentItem;

  @override
  void initState() {
    super.initState();
    // Use initial values from parent screen if provided, otherwise default to 'all'
    _period = widget.initialPeriod ?? 'all';
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
    // Initially use the passed item
    _currentItem = widget.debtItem;
    // Fetch fresh data on init (with the initial date range if provided)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    String? fromStr = _dateFrom?.toIso8601String().split('T')[0];
    String? toStr = _dateTo?.toIso8601String().split('T')[0];

    context.read<BankBloc>().add(
      GetDriverBalanceEvent(from: fromStr, to: toStr),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final currentDate = isStartDate ? _dateFrom : _dateTo;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? clock.now(),
      firstDate: DateTime(2020),
      lastDate: clock.now(),
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

  /// The period on screen, in the app's language ("WEEK" was the code itself)
  /// and named as the filter names it
  String _periodLabel(AppLocalizations l10n) =>
      _period == 'all' ? l10n.allTime : periodLabel(l10n, _period);

  /// The same counterparty, on the same side: a restaurant's own id and a
  /// driver's user id can be the same number (the page showed another's
  /// debts), and a restaurant may both owe and be owed
  bool _isSameCounterparty(RestaurantDebt other) =>
      other.counterpartyType == widget.debtItem.counterpartyType &&
      other.restaurantId == widget.debtItem.restaurantId &&
      other.isCredit == widget.debtItem.isCredit;

  /// What the platform owes a restaurant or a driver is paid from here
  /// (decision 6 of manager_suite_report.md: no such payment could be
  /// recorded, so what it owed only grew)
  Widget? _payButton(BuildContext context) {
    final item = _currentItem;
    if (widget.debtItem.isCredit ||
        item == null ||
        item.amount <= 0 ||
        !const {'restaurant', 'driver'}.contains(item.counterpartyType)) {
      return null;
    }
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: BlocBuilder<BankBloc, BankState>(
          builder: (context, state) => ElevatedButton.icon(
            onPressed: state is PaymentRecording
                ? null
                : () => _askPlatformPayment(context, item),
            icon: const Icon(Icons.payments_outlined),
            label: Text(AppLocalizations.of(context)!.payFromPlatform),
          ),
        ),
      ),
    );
  }

  Future<void> _askPlatformPayment(
    BuildContext context,
    RestaurantDebt item,
  ) async {
    final bloc = context.read<BankBloc>();
    final answer = await showDialog<(double, String)>(
      context: context,
      builder: (_) => _PlatformPaymentDialog(item: item),
    );
    if (answer == null) return;
    final (amount, notes) = answer;
    final toRestaurant = item.counterpartyType == 'restaurant';
    bloc.add(
      RecordPlatformPaymentEvent(
        restaurantId: toRestaurant ? item.restaurantId : null,
        driverId: toRestaurant ? null : item.restaurantId,
        amount: amount,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _payButton(context),
      appBar: AppBar(
        title: Text(
          widget.debtItem.isCredit
              ? AppLocalizations.of(context)!.creditDetails
              : AppLocalizations.of(context)!.debtDetails,
        ),
      ),
      body: BlocConsumer<BankBloc, BankState>(
        listener: (context, state) {
          if (state is BalanceLoaded) {
            // Find the matching counterparty in the response
            final balance = state.balance;
            RestaurantDebt? matchingItem;

            // Search in credits first
            for (var credit in balance.restaurantCredits) {
              if (_isSameCounterparty(credit)) {
                matchingItem = credit;
                break;
              }
            }

            // If not found in credits, search in debts
            if (matchingItem == null) {
              for (var debt in balance.restaurantDebts) {
                if (_isSameCounterparty(debt)) {
                  matchingItem = debt;
                  break;
                }
              }
            }

            if (matchingItem != null) {
              setState(() {
                _currentItem = matchingItem;
              });
            } else {
              // Counterparty not found in this date range - clear item
              setState(() {
                _currentItem = null;
              });
            }
          } else if (state is BalanceError) {
            // The figures stay as they were last read: say they could not be
            // read again, instead of showing them as if they were fresh
            ErrorSnackBar.show(context, state.message);
          } else if (state is PaymentRecorded) {
            // A payment from the platform counts at once: the figures again
            ErrorSnackBar.showConfirmation(
              context,
              AppLocalizations.of(context)!.platformPaymentRecorded,
            );
            _fetchData();
          } else if (state is PaymentError) {
            ErrorSnackBar.show(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is BankLoading;
          final hasData = _currentItem != null;

          return Column(
            children: [
              // Date selector at the top
              _buildPeriodSelector(context),
              // Header - uses _currentItem if available, shows zeros otherwise
              _buildHeader(context, _currentItem, isLoading),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasData
                    ? _buildContent(context, _currentItem!)
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Text(
                            AppLocalizations.of(context)?.noDataAvailable ??
                                'No data available for this date range',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
              // Always show footer - with zeros if no data
              if (!isLoading) _buildFooter(context, _currentItem),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
            newDateFrom = range.startDate; // null
            newDateTo = range.endDate; // null
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

  Widget _buildHeader(
    BuildContext context,
    RestaurantDebt? item,
    bool isLoading,
  ) {
    // Use item values or default to zero
    final amount = item?.amount ?? 0.0;
    final isCredit = item?.isCredit ?? widget.debtItem.isCredit;
    final isPositive = isCredit;
    final color = isPositive
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Text(
            widget.debtItem.restaurantName, // Always show original name
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.5.h),
          isLoading
              ? SizedBox(
                  height: 24.sp,
                  width: 24.sp,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  '${amount > 0 ? (isPositive ? '+' : '-') : ''}${amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
          if (_dateFrom != null || _dateTo != null)
            Padding(
              padding: EdgeInsets.only(top: 0.5.h),
              child: Text(
                // Named as the filter names it (it read "WEEK Balance")
                AppLocalizations.of(context)!.balanceForPeriod(
                  _periodLabel(AppLocalizations.of(context)!),
                ),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, RestaurantDebt item) {
    final orderSettlements = item.details
        .where((d) => d.source == 'order_settlements')
        .toList();
    final cashTransactions = item.details
        .where((d) => d.source == 'cash_transactions')
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (orderSettlements.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              AppLocalizations.of(context)!.orderSettlements,
            ),
            _buildOrderSettlementsList(context, orderSettlements),
            SizedBox(height: 3.h),
          ],
          if (cashTransactions.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              AppLocalizations.of(context)!.cashTransactions,
            ),
            _buildCashTransactionsList(context, cashTransactions),
            SizedBox(height: 3.h),
          ],
          if (orderSettlements.isEmpty && cashTransactions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Text(
                  AppLocalizations.of(context)!.noTransactionsInPeriod,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          // primaryColor is the surface in dark mode: black on black
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildOrderSettlementsList(
    BuildContext context,
    List<DriverCreditDebtDetail> details,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final item = details[index];
        return Card(
          margin: EdgeInsets.only(bottom: 1.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.orderNumber?.isNotEmpty == true
                      ? item.orderNumber!
                      : 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      _formatDate(item.date),
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _reasonLabel(
                    AppLocalizations.of(context)!,
                    item.reason,
                    false,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCashTransactionsList(
    BuildContext context,
    List<DriverCreditDebtDetail> details,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final item = details[index];
        final isIncoming = item.direction == 'incoming';
        final color = isIncoming ? Colors.green : Colors.orange;

        return Card(
          margin: EdgeInsets.only(bottom: 1.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // What a side paid beyond its debts, owed back by the
                        // other (anyone may pay more than they owe)
                        item.reason == 'overpayment'
                            ? AppLocalizations.of(context)!.paidBeyondWhatWasOwed
                            : isIncoming
                            ? AppLocalizations.of(context)!.receivedPayment
                            : AppLocalizations.of(context)!.sentPayment,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                        ),
                      ),
                      Text(
                        _formatDate(item.date),
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                        color: color,
                      ),
                    ),
                    Text(
                      _reasonLabel(
                        AppLocalizations.of(context)!,
                        item.reason,
                        isIncoming,
                      ),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context, RestaurantDebt? item) {
    // Calculate totals from details or use zeros
    double totalOrderSettlements = 0;
    double totalIncoming = 0;
    double totalOutgoing = 0;
    double netBalance = item?.amount ?? 0.0;

    if (item != null) {
      for (var d in item.details) {
        if (d.source == 'order_settlements') {
          totalOrderSettlements += d.amount;
        } else if (d.source == 'cash_transactions') {
          if (d.direction == 'incoming') {
            totalIncoming += d.amount;
          } else {
            totalOutgoing += d.amount;
          }
        }
      }
    }

    final paidTowardsOrders = item?.paidTowardsOrders;
    // Days chosen: the balance is what their orders still owe, whatever day
    // the cash came; the cash rows are those days' cash only
    final forSomeDays = _dateFrom != null || _dateTo != null;

    final isPositive = (item?.isCredit ?? widget.debtItem.isCredit);
    final balanceColor = isPositive
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildFooterRow(
              AppLocalizations.of(context)!.totalOrderSettlements,
              totalOrderSettlements.toStringAsFixed(2),
            ),
            if (paidTowardsOrders != null) ...[
              SizedBox(height: 1.h),
              _buildFooterRow(
                AppLocalizations.of(context)!.paidTowardsOrders,
                paidTowardsOrders.toStringAsFixed(2),
              ),
            ],
            SizedBox(height: 1.h),
            _buildFooterRow(
              forSomeDays
                  ? AppLocalizations.of(context)!.cashPaidInTheseDays
                  : AppLocalizations.of(context)!.totalCashOutgoing,
              totalOutgoing.toStringAsFixed(2),
            ),
            SizedBox(height: 1.h),
            _buildFooterRow(
              forSomeDays
                  ? AppLocalizations.of(context)!.cashReceivedInTheseDays
                  : AppLocalizations.of(context)!.totalCashIncoming,
              totalIncoming.toStringAsFixed(2),
            ),
            SizedBox(height: 1.5.h),
            const Divider(),
            SizedBox(height: 1.h),
            _buildFooterRow(
              AppLocalizations.of(context)!.netBalance,
              '${netBalance > 0 ? (isPositive ? '+' : '-') : ''}${netBalance.toStringAsFixed(2)}',
              isBold: true,
              color: balanceColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$value ${AppLocalizations.of(context)!.currency}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Why a row is owed, in the app's language (it was English): what the
  /// manager's balance sends, the loyalty coupon included
  String _reasonLabel(AppLocalizations l10n, String? reason, bool isIncoming) {
    switch (reason) {
      case 'settlement':
        return l10n.reasonOrderSettlement;
      case 'coupon_credit':
        return l10n.reasonCouponCredit;
      case 'global_coupon_credit':
        return l10n.reasonGlobalCouponCredit;
      case 'birthday_credit':
        return l10n.reasonBirthdayCredit;
      case 'loyalty_coupon_credit':
        return l10n.reasonLoyaltyCouponCredit;
      case 'overcharge':
        return l10n.reasonOvercharge;
      case 'overpay':
        return l10n.overpay;
      case 'payment':
        return isIncoming ? l10n.receivedPayment : l10n.sentPayment;
      default:
        return isIncoming ? l10n.overpay : l10n.reasonOvercharge;
    }
  }

  String _formatDate(String dateStr) {
    try {
      // The server's times are UTC: shown on the phone's clock
      final dateTime = parseServerTime(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}

/// How much the platform pays [item], and a note. More than it owes is the
/// receiver's debt to the platform (anyone may pay more than they owe).
class _PlatformPaymentDialog extends StatefulWidget {
  final RestaurantDebt item;

  const _PlatformPaymentDialog({required this.item});

  @override
  State<_PlatformPaymentDialog> createState() => _PlatformPaymentDialogState();
}

class _PlatformPaymentDialogState extends State<_PlatformPaymentDialog> {
  late final _amount = TextEditingController(
    text: widget.item.amount.toStringAsFixed(2),
  );
  final _notes = TextEditingController();
  String? _problem;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _send(AppLocalizations l10n) {
    final amount = parseTypedAmount(_amount.text);
    if (amount == null || amount <= 0) {
      setState(() => _problem = l10n.invalidAmount);
      return;
    }
    Navigator.of(context).pop((amount, _notes.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.platformPaymentTitle(widget.item.restaurantName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.platformPaymentHelp),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.amount,
              suffixText: l10n.currency,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_problem != null) ...[
            const SizedBox(height: 12),
            Text(
              _problem!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: () => _send(l10n), child: Text(l10n.confirm)),
      ],
    );
  }
}
