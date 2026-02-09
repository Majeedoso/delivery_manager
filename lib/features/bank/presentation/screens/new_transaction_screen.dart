import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/currency.dart';

class NewTransactionScreen extends StatefulWidget {
  static const String route = '/bank-new-transaction';

  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentType = 'restaurant';
  int? _selectedRestaurantId;

  // Period selection state
  String _selectedPeriod = 'week';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  // Calculated amount (from API) - for restaurant payments
  double? _calculatedAmount;
  bool _isCalculating = false;

  // Calculated system amount (from API) - for system payments
  double? _calculatedSystemAmount;
  bool _isCalculatingSystem = false;

  // Cached restaurant list and system debt (persisted across state changes)
  List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    // Initialize with week period
    final range = PeriodCalculator.calculatePeriodRange('week');
    _dateFrom = range.startDate;
    _dateTo = range.endDate;

    // Load balance to get restaurant list
    context.read<BankBloc>().add(const GetDriverBalanceEvent());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    if (_selectedRestaurantId == null) return;

    context.read<BankBloc>().add(
      CalculateRestaurantPaymentAmountEvent(
        restaurantId: _selectedRestaurantId!,
        selectedPeriod: _selectedPeriod,
        startDate: _dateFrom?.toIso8601String().split('T')[0],
        endDate: _dateTo?.toIso8601String().split('T')[0],
      ),
    );
  }

  void _calculateSystemAmount() {
    context.read<BankBloc>().add(
      CalculateSystemPaymentAmountEvent(
        selectedPeriod: _selectedPeriod,
        startDate: _dateFrom?.toIso8601String().split('T')[0],
        endDate: _dateTo?.toIso8601String().split('T')[0],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final currentDate = isStartDate ? _dateFrom : _dateTo;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      // Recalculate amount when date changes
      if (_selectedPaymentType == 'restaurant') {
        _calculateAmount();
      } else if (_selectedPaymentType == 'system') {
        _calculateSystemAmount();
      }
    }
  }

  void _submitPayment() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ErrorSnackBar.show(context, AppLocalizations.of(context)!.invalidAmount);
      return;
    }

    if (_selectedPaymentType == 'restaurant') {
      if (_selectedRestaurantId == null) {
        ErrorSnackBar.show(
          context,
          AppLocalizations.of(context)!.selectRestaurant,
        );
        return;
      }
      context.read<BankBloc>().add(
        RecordRestaurantPaymentEvent(
          restaurantId: _selectedRestaurantId!,
          amount: amount,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        ),
      );
    } else {
      context.read<BankBloc>().add(
        RecordSystemPaymentEvent(
          amount: amount,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.newTransaction)),
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
              // Clear form after successful payment
              _formKey.currentState?.reset();
              _amountController.clear();
              _notesController.clear();
              setState(() {
                _selectedRestaurantId = null;
                _calculatedAmount = null;
              });
            } else if (state is BalanceLoaded) {
              // Cache the restaurant list and system debt
              setState(() {
                _restaurants = state.balance.restaurantDebts
                    .map(
                      (debt) => {
                        'id': debt.restaurantId,
                        'name': debt.restaurantName,
                        'amount': debt.amount,
                      },
                    )
                    .toList();
              });
            } else if (state is AmountCalculating) {
              setState(() {
                _isCalculating = true;
              });
            } else if (state is AmountCalculated) {
              setState(() {
                _isCalculating = false;
                _calculatedAmount = state.amount;
              });
            } else if (state is AmountCalculationError) {
              setState(() {
                _isCalculating = false;
                _calculatedAmount = null;
              });
            } else if (state is SystemAmountCalculating) {
              setState(() {
                _isCalculatingSystem = true;
              });
            } else if (state is SystemAmountCalculated) {
              setState(() {
                _isCalculatingSystem = false;
                _calculatedSystemAmount = state.amount;
              });
            } else if (state is SystemAmountCalculationError) {
              setState(() {
                _isCalculatingSystem = false;
                _calculatedSystemAmount = null;
              });
            }
          },
          builder: (context, state) {
            final isLoading = state is BankLoading || state is PaymentRecording;

            // Use cached restaurant list from widget state
            // (populated in listener when BalanceLoaded is received)
            final restaurants = _restaurants;

            return SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recordPayment,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Payment Type Selection
                    Text(
                      AppLocalizations.of(context)!.paymentType,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'restaurant',
                          label: Text(AppLocalizations.of(context)!.restaurant),
                          icon: const Icon(Icons.restaurant),
                        ),
                        ButtonSegment(
                          value: 'system',
                          label: Text(AppLocalizations.of(context)!.system),
                          icon: const Icon(Icons.business),
                        ),
                      ],
                      selected: {_selectedPaymentType},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedPaymentType = selection.first;
                          _selectedRestaurantId = null;
                          _calculatedAmount = null;
                          _calculatedSystemAmount = null;
                        });
                        // If system payment selected, calculate system amount
                        if (selection.first == 'system') {
                          _calculateSystemAmount();
                        }
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Period Selection (Day, Week, Month, Year, Date Range) - FIRST
                    Text(
                      AppLocalizations.of(context)!.paymentDate,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    PeriodDateSelector(
                      selectedPeriod: _selectedPeriod,
                      dateFrom: _dateFrom,
                      dateTo: _dateTo,
                      onPeriodChanged: (String selectedValue) {
                        DateTime? newDateFrom;
                        DateTime? newDateTo;

                        if (selectedValue == 'dateRange') {
                          final range = PeriodCalculator.getDefaultDateRange();
                          newDateFrom = range.startDate;
                          newDateTo = range.endDate;
                        } else if (selectedValue == 'all') {
                          final range = PeriodCalculator.calculatePeriodRange(
                            'all',
                          );
                          newDateFrom = range.startDate;
                          newDateTo = range.endDate;
                        } else {
                          final range = PeriodCalculator.calculatePeriodRange(
                            selectedValue,
                          );
                          newDateFrom = range.startDate;
                          newDateTo = range.endDate;
                        }

                        setState(() {
                          _selectedPeriod = selectedValue;
                          _dateFrom = newDateFrom;
                          _dateTo = newDateTo;
                          _calculatedAmount = null;
                          _calculatedSystemAmount = null;
                        });
                        // Recalculate amount when period changes
                        if (_selectedPaymentType == 'restaurant') {
                          _calculateAmount();
                        } else if (_selectedPaymentType == 'system') {
                          _calculateSystemAmount();
                        }
                      },
                      onDateFromSelected: (DateTime? date) async {
                        await _selectDate(true);
                      },
                      onDateToSelected: (DateTime? date) async {
                        await _selectDate(false);
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Restaurant Selection (only for restaurant payments) - WITHOUT amounts
                    if (_selectedPaymentType == 'restaurant') ...[
                      Text(
                        AppLocalizations.of(context)!.selectRestaurant,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 1.h),
                      if (restaurants.isEmpty)
                        Text(
                          AppLocalizations.of(context)!.noDebts,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        )
                      else
                        Builder(
                          builder: (context) {
                            final fillColor =
                                Theme.of(
                                  context,
                                ).inputDecorationTheme.fillColor ??
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer;
                            final borderColor = Theme.of(
                              context,
                            ).colorScheme.inversePrimary;

                            return DropdownButton2<int>(
                              value: _selectedRestaurantId,
                              hint: Text(
                                AppLocalizations.of(context)!.selectRestaurant,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              iconStyleData: IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: borderColor,
                                  size: 28.sp,
                                ),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 60.h,
                                decoration: BoxDecoration(
                                  color: fillColor,
                                  borderRadius:
                                      MaterialTheme.getBorderRadiusMedium(),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 0.2.w,
                                  ),
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: MaterialTheme.getBorderRadiusMedium()
                                      .topLeft,
                                  thickness: WidgetStateProperty.all(0.6.w),
                                  thumbVisibility: WidgetStateProperty.all(
                                    true,
                                  ),
                                ),
                              ),
                              menuItemStyleData: MenuItemStyleData(
                                height: 6.h,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 0,
                                ),
                              ),
                              buttonStyleData: ButtonStyleData(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: fillColor,
                                  borderRadius:
                                      MaterialTheme.getBorderRadiusMedium(),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 0.2.w,
                                  ),
                                ),
                              ),
                              items: restaurants.map((restaurant) {
                                return DropdownMenuItem<int>(
                                  value: restaurant['id'] as int,
                                  child: Text(
                                    restaurant['name'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRestaurantId = value;
                                  _calculatedAmount = null;
                                });
                                // Trigger calculation when restaurant changes
                                _calculateAmount();
                              },
                            );
                          },
                        ),
                      SizedBox(height: 2.h),

                      // Calculated Total for selected restaurant
                      if (_selectedRestaurantId != null) ...[
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.totalDebt,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    _isCalculating
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            '${(_calculatedAmount ?? 0.0).toStringAsFixed(2)} ${Currency.dzd.code}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ],

                    // System debt info (for system payments)
                    if (_selectedPaymentType == 'system') ...[
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.totalDebt,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  _isCalculatingSystem
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          '${(_calculatedSystemAmount ?? 0.0).toStringAsFixed(2)} ${Currency.dzd.code}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Amount Input
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.amount,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: Currency.dzd.code,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.invalidAmount;
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return AppLocalizations.of(context)!.invalidAmount;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Notes Input
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.notes,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitPayment,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 2.h,
                                width: 2.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(AppLocalizations.of(context)!.recordPayment),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
