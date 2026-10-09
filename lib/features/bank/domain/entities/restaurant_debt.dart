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

  /// What the payments, of any date, already paid of these orders (the
  /// oldest first): with days chosen, the cash of those days pays others.
  final double? paidTowardsOrders;

  const RestaurantDebt({
    required this.restaurantId,
    required this.restaurantName,
    required this.amount,
    required this.formattedAmount,
    this.isCredit = false,
    this.counterpartyType = 'restaurant',
    this.confirmedAt,
    this.details = const [],
    this.paidTowardsOrders,
  });
}
