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

  /// What is left to pay once what each side owes the other is set off: a
  /// payment between them is only the difference (the owner's rule,
  /// 2026-11-14). Null from a server that does not say it.
  final double? balanceAfterSetOff;

  /// Who the line is with, as the server names them (a restaurant by its
  /// owner's user id): its details page asks for its rows by it.
  final int counterpartyId;

  /// What the details page's footer shows, every row counted: the rows come
  /// 10 at a time (the owner's rule, 2026-11-15).
  final LineTotals? totals;

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
    this.balanceAfterSetOff,
    this.counterpartyId = 0,
    this.totals,
  });

  /// The same line with [rows] as its details: a details page gathers its
  /// pages of rows.
  RestaurantDebt withDetails(List<DriverCreditDebtDetail> rows) =>
      RestaurantDebt(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        amount: amount,
        formattedAmount: formattedAmount,
        isCredit: isCredit,
        counterpartyType: counterpartyType,
        confirmedAt: confirmedAt,
        details: rows,
        paidTowardsOrders: paidTowardsOrders,
        balanceAfterSetOff: balanceAfterSetOff,
        counterpartyId: counterpartyId,
        totals: totals,
      );
}

/// A line's totals, every row counted: the orders, the cash each way, and
/// what was set off (no cash).
class LineTotals {
  final double settlements;
  final double cashIn;
  final double cashOut;
  final double setOff;

  const LineTotals({
    required this.settlements,
    required this.cashIn,
    required this.cashOut,
    required this.setOff,
  });
}
