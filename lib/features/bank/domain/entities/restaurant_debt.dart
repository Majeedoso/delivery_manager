import 'package:delivery_manager/features/bank/domain/entities/driver_credit_debt_detail.dart';

class RestaurantDebt {
  final int restaurantId;
  final String restaurantName;
  final double amount;
  final String formattedAmount;
  final bool isCredit;
  final String counterpartyType;
  final DateTime? confirmedAt;
  final List<DriverCreditDebtDetail> details;

  const RestaurantDebt({
    required this.restaurantId,
    required this.restaurantName,
    required this.amount,
    required this.formattedAmount,
    this.isCredit = false,
    this.counterpartyType = 'restaurant',
    this.confirmedAt,
    this.details = const [],
  });
}
