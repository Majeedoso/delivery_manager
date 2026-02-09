import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/features/bank/domain/entities/pending_payment.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class PendingPaymentCard extends StatelessWidget {
  final PendingPayment pendingPayment;

  const PendingPaymentCard({super.key, required this.pendingPayment});

  @override
  Widget build(BuildContext context) {
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
                        pendingPayment.recipientName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        pendingPayment.isRestaurantPayment
                            ? AppLocalizations.of(context)!.paymentToRestaurant
                            : AppLocalizations.of(context)!.paymentToSystem,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pendingPayment.formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      AppLocalizations.of(context)!.amount,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              pendingPayment.formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (pendingPayment.notes != null &&
                pendingPayment.notes!.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                '${AppLocalizations.of(context)!.notes}: ${pendingPayment.notes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 14.sp,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    AppLocalizations.of(context)!.pending,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
