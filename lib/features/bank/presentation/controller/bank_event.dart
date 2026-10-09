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
  final String? selectedPeriod;
  final String? startDate;
  final String? endDate;
  final String? notes;

  const RecordRestaurantPaymentEvent({
    required this.restaurantId,
    required this.amount,
    this.selectedPeriod,
    this.startDate,
    this.endDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
    restaurantId,
    amount,
    selectedPeriod,
    startDate,
    endDate,
    notes,
  ];
}

class RecordSystemPaymentEvent extends BankEvent {
  final int driverId;
  final double amount;
  final String? notes;

  const RecordSystemPaymentEvent({
    required this.driverId,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [driverId, amount, notes];
}

/// The platform pays a restaurant ([restaurantId]) or a driver ([driverId])
/// what it owes them.
class RecordPlatformPaymentEvent extends BankEvent {
  final int? restaurantId;
  final int? driverId;
  final double amount;
  final String? notes;

  const RecordPlatformPaymentEvent({
    this.restaurantId,
    this.driverId,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [restaurantId, driverId, amount, notes];
}

/// The manager's word on a payment a driver or a restaurant sent to the
/// platform: received ([confirm]), or refused, saying why ([notes], which
/// the payer reads).
class AnswerPaymentEvent extends BankEvent {
  final int transactionId;
  final bool confirm;
  final String? notes;

  const AnswerPaymentEvent({
    required this.transactionId,
    required this.confirm,
    this.notes,
  });

  @override
  List<Object?> get props => [transactionId, confirm, notes];
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
  final int driverId;
  final String selectedPeriod;
  final String? startDate;
  final String? endDate;

  const CalculateSystemPaymentAmountEvent({
    required this.driverId,
    required this.selectedPeriod,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [driverId, selectedPeriod, startDate, endDate];
}
