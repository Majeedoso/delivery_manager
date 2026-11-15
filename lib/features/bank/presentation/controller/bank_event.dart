import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object?> get props => [];
}

class GetDriverBalanceEvent extends BankEvent {
  final String? from;
  final String? to;

  /// One line's details page: its counterparty, its side ('credits': what
  /// they owe the platform), and the page of its rows
  final String? counterpartyType;
  final int? counterpartyId;
  final String? side;
  final int page;

  const GetDriverBalanceEvent({
    this.from,
    this.to,
    this.counterpartyType,
    this.counterpartyId,
    this.side,
    this.page = 1,
  });

  @override
  List<Object?> get props => [
    from,
    to,
    counterpartyType,
    counterpartyId,
    side,
    page,
  ];
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

  /// Some local days, yyyy-MM-dd
  final String? from;
  final String? to;
  final int page;
  final int perPage;

  const GetTransactionsEvent({
    this.status,
    this.type,
    this.from,
    this.to,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [status, type, from, to, page, perPage];
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
