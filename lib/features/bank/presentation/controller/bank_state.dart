import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';

abstract class BankState extends Equatable {
  const BankState();

  @override
  List<Object?> get props => [];
}

class BankInitial extends BankState {
  const BankInitial();
}

class BankLoading extends BankState {
  const BankLoading();
}

class BalanceLoaded extends BankState {
  final DriverBalance balance;
  final RequestState balanceState;

  const BalanceLoaded({
    required this.balance,
    this.balanceState = RequestState.loaded,
  });

  @override
  List<Object?> get props => [balance, balanceState];

  BalanceLoaded copyWith({DriverBalance? balance, RequestState? balanceState}) {
    return BalanceLoaded(
      balance: balance ?? this.balance,
      balanceState: balanceState ?? this.balanceState,
    );
  }
}

class BalanceError extends BankState {
  final String message;

  const BalanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentRecording extends BankState {
  const PaymentRecording();
}

class PaymentRecorded extends BankState {
  final Transaction transaction;
  final String message;

  const PaymentRecorded({required this.transaction, required this.message});

  @override
  List<Object?> get props => [transaction, message];
}

class PaymentError extends BankState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionsLoaded extends BankState {
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final RequestState transactionsState;
  final String? statusFilter;
  final String? typeFilter;

  const TransactionsLoaded({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.transactionsState = RequestState.loaded,
    this.statusFilter,
    this.typeFilter,
  });

  @override
  List<Object?> get props => [
    transactions,
    currentPage,
    totalPages,
    hasMore,
    transactionsState,
    statusFilter,
    typeFilter,
  ];

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    RequestState? transactionsState,
    String? statusFilter,
    String? typeFilter,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      transactionsState: transactionsState ?? this.transactionsState,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

class TransactionsError extends BankState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AmountCalculating extends BankState {
  const AmountCalculating();
}

class AmountCalculated extends BankState {
  final double amount;
  final String formattedAmount;
  final bool hasExistingTransaction;
  final String? existingTransactionStatus;

  const AmountCalculated({
    required this.amount,
    required this.formattedAmount,
    this.hasExistingTransaction = false,
    this.existingTransactionStatus,
  });

  @override
  List<Object?> get props => [
    amount,
    formattedAmount,
    hasExistingTransaction,
    existingTransactionStatus,
  ];
}

class AmountCalculationError extends BankState {
  final String message;

  const AmountCalculationError(this.message);

  @override
  List<Object?> get props => [message];
}

// System amount states (separate from restaurant amount)
class SystemAmountCalculating extends BankState {
  const SystemAmountCalculating();
}

class SystemAmountCalculated extends BankState {
  final double amount;
  final String formattedAmount;
  final bool hasExistingTransaction;
  final String? existingTransactionStatus;

  const SystemAmountCalculated({
    required this.amount,
    required this.formattedAmount,
    this.hasExistingTransaction = false,
    this.existingTransactionStatus,
  });

  @override
  List<Object?> get props => [
    amount,
    formattedAmount,
    hasExistingTransaction,
    existingTransactionStatus,
  ];
}

class SystemAmountCalculationError extends BankState {
  final String message;

  const SystemAmountCalculationError(this.message);

  @override
  List<Object?> get props => [message];
}
