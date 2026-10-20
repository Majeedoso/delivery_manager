import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/bank/presentation/widgets/transaction_list_item.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/currency.dart';

/// The payments drivers and restaurants sent to the platform, the newest
/// first: those still waiting are answered here (they waited for good: no
/// page could answer them).
class BankArchiveScreen extends StatefulWidget {
  static const String route = '/bank-archive';

  const BankArchiveScreen({super.key});

  @override
  State<BankArchiveScreen> createState() => _BankArchiveScreenState();
}

class _BankArchiveScreenState extends State<BankArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

  /// The payments shown: of one status, or all (null)
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _load() {
    context.read<BankBloc>().add(GetTransactionsEvent(status: _status));
  }

  /// An answer is on its way: the list is read again after it
  bool get _answering {
    final state = context.read<BankBloc>().state;
    return state is TransactionsLoaded && state.answeringPaymentId != null;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<BankBloc>().state;
      if (state is TransactionsLoaded &&
          state.hasMore &&
          state.transactionsState != RequestState.loading &&
          state.answeringPaymentId == null) {
        context.read<BankBloc>().add(const LoadMoreTransactionsEvent());
      }
    }
  }

  void _show(String? status) {
    if (status == _status || _answering) return;
    setState(() => _status = status);
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
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
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
                              AppLocalizations.of(context)!.noTransactionsFound,
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

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (!_answering) _load();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
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
                          return Padding(
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
                          );
                        },
                      ),
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
