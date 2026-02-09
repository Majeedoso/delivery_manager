import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/bank/presentation/widgets/balance_summary_card.dart';
import 'package:delivery_manager/features/bank/presentation/widgets/restaurant_debt_card.dart';
import 'package:delivery_manager/features/bank/presentation/widgets/pending_payment_card.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class BankScreen extends StatefulWidget {
  static const String route = '/bank-receivables';

  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BankBloc>().add(const GetDriverBalanceEvent());
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
        child: BlocConsumer<BankBloc, BankState>(
          listener: (context, state) {
            if (state is PaymentError) {
              ErrorSnackBar.show(context, state.message);
            } else if (state is PaymentRecorded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is BalanceLoaded &&
                state.balanceState == RequestState.error) {
              ErrorSnackBar.show(
                context,
                AppLocalizations.of(context)!.errorLoadingData,
              );
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
                    Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        state.message.isNotEmpty
                            ? state.message
                            : AppLocalizations.of(context)!.errorLoadingData,
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

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BankBloc>().add(const RefreshBalanceEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(2.5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Summary
                      BalanceSummaryCard(driverBalance: balance),
                      SizedBox(height: 4.h),

                      // Restaurant Debts Section (what driver owes to restaurants)
                      if (balance.restaurantDebts.isNotEmpty) ...[
                        Text(
                          AppLocalizations.of(context)!.restaurantDebts,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        ...balance.restaurantDebts.map(
                          (debt) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: RestaurantDebtCard(restaurantDebt: debt),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],

                      // Restaurant Credits Section (what restaurants owe to driver)
                      if (balance.restaurantCredits.isNotEmpty) ...[
                        Text(
                          AppLocalizations.of(context)!.restaurantCredits,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        ...balance.restaurantCredits.map(
                          (debt) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: RestaurantDebtCard(restaurantDebt: debt),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],

                      // Pending Payments Section (payments waiting for restaurant confirmation)
                      if (balance.pendingPayments.isNotEmpty) ...[
                        Text(
                          AppLocalizations.of(context)!.pendingPayments,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        ...balance.pendingPayments.map(
                          (payment) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: PendingPaymentCard(pendingPayment: payment),
                          ),
                        ),
                      ],

                      // Empty State
                      if (balance.restaurantDebts.isEmpty &&
                          balance.restaurantCredits.isEmpty &&
                          balance.pendingPayments.isEmpty &&
                          balance.systemDebt == 0)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 10.h),
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 50.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                AppLocalizations.of(context)!.noDebts,
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
                        ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Text(AppLocalizations.of(context)!.noDataAvailable),
            );
          },
        ),
      ),
    );
  }
}
