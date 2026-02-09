import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class RestaurantDebtCard extends StatelessWidget {
  final RestaurantDebt restaurantDebt;
  final VoidCallback? onTap;

  const RestaurantDebtCard({
    super.key,
    required this.restaurantDebt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overpay label at the top (only for credits)
              if (restaurantDebt.isCredit) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.overpay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurantDebt.restaurantName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        restaurantDebt.formattedAmount,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          // If it's credit, show GREEN, otherwise RED for debt
                          color: restaurantDebt.isCredit
                              ? Colors.green
                              : (restaurantDebt.amount > 0
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      if (!restaurantDebt.isCredit) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          AppLocalizations.of(context)!.amount,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Date and time at the bottom
              // Show even if confirmedAt is null (N/A)
              SizedBox(height: 1.5.h),
              Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  restaurantDebt.confirmedAt != null
                      ? _formatDateTime(restaurantDebt.confirmedAt!)
                      : 'N/A', // or a localized string if available
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}
