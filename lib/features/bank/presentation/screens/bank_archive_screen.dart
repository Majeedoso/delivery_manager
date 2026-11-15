import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/load_more_on_scroll.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/bank/presentation/widgets/transaction_list_item.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/currency.dart';

/// The payments drivers and restaurants sent to the platform, and those the
/// platform made, the newest first, under each day's heading: those still
/// waiting are answered here (they waited for good: no page could answer
/// them). Of some days, one kind and one status, with what they moved.
class BankArchiveScreen extends StatefulWidget {
  static const String route = '/bank-archive';

  const BankArchiveScreen({super.key});

  @override
  State<BankArchiveScreen> createState() => _BankArchiveScreenState();
}

class _BankArchiveScreenState extends State<BankArchiveScreen> {
  /// The payments shown: of one status, or all (null)
  String? _status;

  /// Of some local days (the owner's ask, 2026-11-14), as the bank's other
  /// pages choose them
  String _period = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  /// Of one kind: a transaction type, 'platform', 'set_off', or all
  String _kind = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    String? day(DateTime? date) => date?.toIso8601String().split('T')[0];
    context.read<BankBloc>().add(
      GetTransactionsEvent(
        status: _status,
        type: _kind == 'all' ? null : _kind,
        from: day(_dateFrom),
        to: day(_dateTo),
      ),
    );
  }

  /// An answer is on its way: the list is read again after it
  bool get _answering {
    final state = context.read<BankBloc>().state;
    return state is TransactionsLoaded && state.answeringPaymentId != null;
  }

  void _show(String? status) {
    if (status == _status || _answering) return;
    setState(() => _status = status);
    _load();
  }

  void _choosePeriod(String period) {
    if (_answering) return;
    final range = period == 'dateRange'
        ? PeriodCalculator.getDefaultDateRange()
        : PeriodCalculator.calculatePeriodRange(period);
    setState(() {
      _period = period;
      _dateFrom = range.startDate;
      _dateTo = range.endDate;
    });
    _load();
  }

  Future<void> _chooseDay({required bool from}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (from ? _dateFrom : _dateTo) ?? clock.now(),
      firstDate: DateTime(2020),
      lastDate: clock.now(),
    );
    if (picked == null || !mounted || _answering) return;
    setState(() => from ? _dateFrom = picked : _dateTo = picked);
    _load();
  }

  void _chooseKind(String kind) {
    if (kind == _kind || _answering) return;
    setState(() => _kind = kind);
    _load();
  }

  /// Received: confirmed after a last look at the amount and who sent it.
  Future<void> _confirm(Transaction payment) async {
    final l10n = AppLocalizations.of(context)!;
    final received = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmPaymentReceivedTitle),
        content: Text(
          l10n.confirmPaymentReceived(
            l10n.dinars(payment.formattedAmount),
            TransactionListItem.payerOf(payment),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (received == true && mounted) {
      _answer(payment, confirm: true);
    }
  }

  /// Refused: why, which is required (the payer reads it).
  Future<void> _reject(Transaction payment) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RefusePaymentDialog(),
    );
    if (reason != null && mounted) {
      _answer(payment, confirm: false, notes: reason);
    }
  }

  void _answer(Transaction payment, {required bool confirm, String? notes}) {
    context.read<BankBloc>().add(
      AnswerPaymentEvent(
        transactionId: payment.id,
        confirm: confirm,
        notes: notes,
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <String?, String>{
      null: l10n.all,
      'pending': l10n.pending,
      'confirmed': l10n.confirmed,
      'rejected': l10n.rejected,
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(2.5.w, 1.h, 2.5.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PeriodDateSelector(
            selectedPeriod: _period,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            onPeriodChanged: _choosePeriod,
            onDateFromSelected: (_) => _chooseDay(from: true),
            onDateToSelected: (_) => _chooseDay(from: false),
            spacingBetween: 1.h,
          ),
          SizedBox(height: 1.h),
          // The same dropdown as the period's, for the kind of payment
          PeriodDateSelector(
            selectedPeriod: _kind,
            dateFrom: null,
            dateTo: null,
            customPeriodOptions: [
              {'value': 'all', 'label': l10n.allKinds},
              {'value': 'driver_to_system_payment', 'label': l10n.driver},
              {'value': 'restaurant_to_system_payment', 'label': l10n.restaurant},
              {'value': 'platform', 'label': l10n.paidByThePlatform},
              {'value': 'set_off', 'label': l10n.setOffLabel},
            ],
            onPeriodChanged: _chooseKind,
            onDateFromSelected: (_) async {},
            onDateToSelected: (_) async {},
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              for (final option in options.entries)
                ChoiceChip(
                  label: Text(option.value),
                  selected: _status == option.key,
                  onSelected: (_) => _show(option.key),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// What the days shown moved, the confirmed payments: none for those
  /// waiting or refused, which moved no money
  Widget _buildTotals(BuildContext context, TransactionsLoaded state) {
    final summary = state.summary;
    if (summary == null ||
        state.statusFilter == 'pending' ||
        state.statusFilter == 'rejected') {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Each on one line, smaller if need be: "Compensation" broke in two
    Widget total(String label, double amount) => Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              '${amount.toStringAsFixed(2)} ${l10n.currency}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
    return Card(
      margin: EdgeInsets.fromLTRB(2.5.w, 1.h, 2.5.w, 0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Row(
          children: [
            total(l10n.historyReceived, summary.received),
            total(l10n.historyPaid, summary.paid),
            total(l10n.setOffLabel, summary.setOff),
          ],
        ),
      ),
    );
  }

  /// A day's heading: today, yesterday, or its date in the manager's language
  Widget _dayHeading(BuildContext context, DateTime day) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateUtils.dateOnly(clock.now());
    final label = day == today
        ? l10n.today
        : day == today.subtract(const Duration(days: 1))
        ? l10n.yesterday
        : DateFormat.yMMMMEEEEd(
            Localizations.localeOf(context).toString(),
          ).format(day);
    return Padding(
      padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bankArchive)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: Column(
          children: [
            _buildFilters(context),
            Expanded(
              child: BlocConsumer<BankBloc, BankState>(
                listener: (context, state) {
                  if (state is TransactionsError) {
                    ErrorSnackBar.show(context, state.message);
                  } else if (state is TransactionsLoaded &&
                      state.lastAnswer != null) {
                    // The answer, said once: the payment changes its status
                    // (or leaves the list), or the server said why not
                    final answer = state.lastAnswer!;
                    if (answer.failure != null) {
                      ErrorSnackBar.show(context, answer.failure);
                    } else {
                      ErrorSnackBar.showConfirmation(
                        context,
                        answer.confirmed
                            ? AppLocalizations.of(
                                context,
                              )!.paymentConfirmedNotice
                            : AppLocalizations.of(
                                context,
                              )!.paymentRefusedNotice,
                      );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is BankLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is TransactionsError) {
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
                              // As the snackbar says it: it read "Exception: ..."
                              ErrorMessageMapper.getUserFriendlyMessage(
                                state.message,
                                AppLocalizations.of(context)!,
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: _load,
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TransactionsLoaded) {
                    if (state.transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 50.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              // Days chosen: none in them
                              _period == 'all'
                                  ? AppLocalizations.of(context)!.noTransactionsFound
                                  : AppLocalizations.of(
                                      context,
                                    )!.noTransactionsInPeriod,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final list = RefreshIndicator(
                      onRefresh: () async {
                        if (!_answering) _load();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(2.5.w),
                        itemCount:
                            state.transactions.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.transactions.length) {
                            // Loading indicator for pagination
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFFFF8A32),
                                ),
                              ),
                            );
                          }

                          final transaction = state.transactions[index];
                          final waiting = transaction.status == 'pending';
                          // A heading wherever the day changes (newest first)
                          final day = DateUtils.dateOnly(transaction.createdAt);
                          final newDay =
                              index == 0 ||
                              DateUtils.dateOnly(
                                    state.transactions[index - 1].createdAt,
                                  ) !=
                                  day;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (newDay) _dayHeading(context, day),
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: TransactionListItem(
                                  transaction: transaction,
                                  busy: state.answeringPaymentId != null,
                                  onConfirm: waiting
                                      ? () => _confirm(transaction)
                                      : null,
                                  onReject: waiting
                                      ? () => _reject(transaction)
                                      : null,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                    return Column(
                      children: [
                        _buildTotals(context, state),
                        Expanded(
                          child: LoadMoreOnScroll(
                            hasMore: state.hasMore,
                            // Nor while an answer is on its way: the list is
                            // read again after it
                            isLoadingMore:
                                state.transactionsState ==
                                    RequestState.loading ||
                                state.answeringPaymentId != null,
                            itemCount: state.transactions.length,
                            onLoadMore: () => context.read<BankBloc>().add(
                              const LoadMoreTransactionsEvent(),
                            ),
                            child: list,
                          ),
                        ),
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
}

/// Why the payment is refused: required (the payer reads it).
class _RefusePaymentDialog extends StatefulWidget {
  const _RefusePaymentDialog();

  @override
  State<_RefusePaymentDialog> createState() => _RefusePaymentDialogState();
}

class _RefusePaymentDialogState extends State<_RefusePaymentDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reason = _reason.text.trim();
    return AlertDialog(
      title: Text(l10n.refusePaymentTitle),
      content: TextField(
        controller: _reason,
        autofocus: true,
        maxLength: 500,
        decoration: InputDecoration(hintText: l10n.refusePaymentReasonHint),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: reason.isEmpty
              ? null
              : () => Navigator.of(context).pop(reason),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.reject),
        ),
      ],
    );
  }
}
