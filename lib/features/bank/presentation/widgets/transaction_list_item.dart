import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/currency.dart';

/// A payment a driver or a restaurant sent to the platform: who, how much,
/// when, what they wrote, and the answer. One still waiting for the manager
/// has Confirm / Reject ([onConfirm], [onReject]).
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  /// An answer is on its way: the buttons wait
  final bool busy;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.busy = false,
    this.onConfirm,
    this.onReject,
  });

  /// Who sent it: a restaurant by its own name (its owner's is not the
  /// restaurant's), a driver by theirs. What the platform paid is named by
  /// who received it
  static String payerOf(Transaction transaction) => isFromPlatform(transaction)
      ? transaction.restaurantName ?? transaction.toUserName ?? ''
      : transaction.restaurantName ?? transaction.fromUserName ?? '';

  /// A payment the platform made (decision 6 of manager_suite_report.md)
  static bool isFromPlatform(Transaction transaction) =>
      transaction.transactionType.startsWith('system_to_');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isConfirmed = transaction.status == 'confirmed';
    final isRejected = transaction.status == 'rejected';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isConfirmed) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = l10n.confirmed;
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = l10n.rejected;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = l10n.pending;
    }

    // Both pay the platform: a restaurant's read "Payment to Restaurant"
    final kind =
        const {
          'restaurant_to_system_payment',
          'system_to_restaurant_payment',
        }.contains(transaction.transactionType)
        ? l10n.restaurant
        : l10n.driver;
    final payerKind = isFromPlatform(transaction)
        ? '${l10n.paidByThePlatform} · $kind'
        : kind;
    final notes = transaction.notes?.trim() ?? '';
    final answer = transaction.responseNotes?.trim() ?? '';
    final answeredBy = transaction.confirmedByName?.trim() ?? '';
    final faded = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
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
                        payerOf(transaction),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(payerKind, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.dinars(transaction.formattedAmount),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14.sp, color: statusColor),
                        SizedBox(width: 0.5.w),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // What the payer wrote, and the answer, each as itself
            if (notes.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                l10n.paymentNote(notes),
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (answer.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                l10n.paymentAnswer(answer),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 1.h),
            Text(dateFormat.format(transaction.createdAt), style: faded),
            // When it was answered, and by which manager ("Confirmed At" was
            // written on a refused one)
            if (transaction.confirmedAt != null &&
                (isConfirmed || isRejected)) ...[
              SizedBox(height: 0.5.h),
              Text(
                [
                  '${isRejected ? l10n.refusedAt : l10n.confirmedAt}: '
                      '${dateFormat.format(transaction.confirmedAt!)}',
                  if (answeredBy.isNotEmpty) answeredBy,
                ].join(' · '),
                style: faded,
              ),
            ],
            if (!isConfirmed &&
                !isRejected &&
                onConfirm != null &&
                onReject != null) ...[
              SizedBox(height: 1.5.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : onConfirm,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.confirm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : onReject,
                      icon: const Icon(Icons.close),
                      label: Text(l10n.reject),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
