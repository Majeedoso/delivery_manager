import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object?> get props => [];
}

class GetDriverBalanceEvent extends BankEvent {
  final String? from;
  final String? to;

  const GetDriverBalanceEvent({this.from, this.to});

  @override
  List<Object?> get props => [from, to];
}

class RefreshBalanceEvent extends BankEvent {
  final String? from;
  final String? to;

  const RefreshBalanceEvent({this.from, this.to});

  @override
  List<Object?> get props => [from, to];
}

class RecordRestaurantPaymentEvent extends BankEvent {
  final int restaurantId;
  final double amount;
  final String? notes;

  const RecordRestaurantPaymentEvent({
    required this.restaurantId,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [restaurantId, amount, notes];
}

class RecordSystemPaymentEvent extends BankEvent {
  final double amount;
  final String? notes;

  const RecordSystemPaymentEvent({required this.amount, this.notes});

  @override
  List<Object?> get props => [amount, notes];
}

class GetTransactionsEvent extends BankEvent {
  final String? status;
  final String? type;
  final int page;
  final int perPage;

  const GetTransactionsEvent({
    this.status,
    this.type,
    this.page = 1,
    this.perPage = 15,
  });

  @override
  List<Object?> get props => [status, type, page, perPage];
}

class LoadMoreTransactionsEvent extends BankEvent {
  const LoadMoreTransactionsEvent();
}

class CalculateRestaurantPaymentAmountEvent extends BankEvent {
  final int restaurantId;
  final String selectedPeriod;
  final String? startDate;
  final String? endDate;

  const CalculateRestaurantPaymentAmountEvent({
    required this.restaurantId,
    required this.selectedPeriod,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [restaurantId, selectedPeriod, startDate, endDate];
}

class CalculateSystemPaymentAmountEvent extends BankEvent {
  final String selectedPeriod;
  final String? startDate;
  final String? endDate;

  const CalculateSystemPaymentAmountEvent({
    required this.selectedPeriod,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [selectedPeriod, startDate, endDate];
}
