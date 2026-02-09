import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class BalanceSummaryCard extends StatelessWidget {
  final DriverBalance driverBalance;

  const BalanceSummaryCard({super.key, required this.driverBalance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.totalDebt,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Text(
              driverBalance.formattedTotalDebt,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: driverBalance.totalDebt > 0
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            const Divider(),
            SizedBox(height: 2.h),
            Text(
              AppLocalizations.of(context)!.systemDebt,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Text(
              driverBalance.formattedSystemDebt,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: driverBalance.systemDebt > 0
                    ? Colors.orange
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              AppLocalizations.of(context)!.systemDebtDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
