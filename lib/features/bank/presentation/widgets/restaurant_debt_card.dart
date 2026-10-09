import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/currency.dart';

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
              // No "Overpay" badge: what a restaurant or a driver owes the
              // platform is its share of orders, not money paid too much
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // "System" was English in every language
                          restaurantDebt.counterpartyType == 'system'
                              ? AppLocalizations.of(context)!.system
                              : restaurantDebt.restaurantName,
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
                        AppLocalizations.of(
                          context,
                        )!.dinars(restaurantDebt.formattedAmount),
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
                      : '', // it read "N/A", in English
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
