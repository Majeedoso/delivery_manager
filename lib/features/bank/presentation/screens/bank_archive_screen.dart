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
import 'package:delivery_manager/features/bank/presentation/widgets/transaction_list_item.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class BankArchiveScreen extends StatefulWidget {
  static const String route = '/bank-archive';

  const BankArchiveScreen({super.key});

  @override
  State<BankArchiveScreen> createState() => _BankArchiveScreenState();
}

class _BankArchiveScreenState extends State<BankArchiveScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<BankBloc>().add(const GetTransactionsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<BankBloc>().state;
      if (state is TransactionsLoaded &&
          state.hasMore &&
          state.transactionsState != RequestState.loading) {
        context.read<BankBloc>().add(const LoadMoreTransactionsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bankArchive)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: BlocConsumer<BankBloc, BankState>(
          listener: (context, state) {
            if (state is TransactionsError) {
              ErrorSnackBar.show(context, state.message);
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

            if (state is TransactionsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        state.message,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BankBloc>().add(
                          const GetTransactionsEvent(),
                        );
                      },
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
                  context.read<BankBloc>().add(const GetTransactionsEvent());
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    final transaction = state.transactions[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: TransactionListItem(transaction: transaction),
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
    );
  }
}
