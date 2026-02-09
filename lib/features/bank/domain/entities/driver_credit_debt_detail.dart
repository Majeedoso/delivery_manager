import 'package:equatable/equatable.dart';

class DriverCreditDebtDetail extends Equatable {
  final String source;
  final String? direction;
  final int id;
  final double amount;
  final String date;
  final String? type;
  final String? transactionType;
  final String? reason;
  final String? orderNumber;

  const DriverCreditDebtDetail({
    required this.source,
    this.direction,
    required this.id,
    required this.amount,
    required this.date,
    this.type,
    this.transactionType,
    this.reason,
    this.orderNumber,
  });

  @override
  List<Object?> get props => [
    source,
    direction,
    id,
    amount,
    date,
    type,
    transactionType,
    reason,
    orderNumber,
  ];
}
