import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isConfirmed = transaction.status == 'confirmed';
    final isRejected = transaction.status == 'rejected';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isConfirmed) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = AppLocalizations.of(context)!.confirmed;
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = AppLocalizations.of(context)!.rejected;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = AppLocalizations.of(context)!.pending;
    }

    // Determine transaction type display
    String transactionTypeDisplay;
    if (transaction.transactionType.contains('restaurant')) {
      transactionTypeDisplay = AppLocalizations.of(
        context,
      )!.paymentToRestaurant;
    } else if (transaction.transactionType.contains('system')) {
      transactionTypeDisplay = AppLocalizations.of(context)!.paymentToSystem;
    } else {
      transactionTypeDisplay = transaction.transactionType;
    }

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
                        transactionTypeDisplay,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 0.5.h),
                      if (transaction.restaurantName != null) ...[
                        Text(
                          '${AppLocalizations.of(context)!.restaurant}: ${transaction.restaurantName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: 0.2.h),
                      ],
                      if (transaction.notes != null &&
                          transaction.notes!.isNotEmpty) ...[
                        Text(
                          transaction.notes!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction.formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
            SizedBox(height: 1.h),
            Text(
              dateFormat.format(transaction.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (transaction.confirmedAt != null) ...[
              SizedBox(height: 0.5.h),
              Text(
                '${AppLocalizations.of(context)!.confirmedAt}: ${dateFormat.format(transaction.confirmedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
