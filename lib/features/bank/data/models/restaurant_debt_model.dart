import 'package:delivery_manager/features/bank/data/models/driver_credit_debt_detail_model.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/core/utils/currency.dart';
import 'package:delivery_manager/core/utils/server_time.dart';

class RestaurantDebtModel extends RestaurantDebt {
  const RestaurantDebtModel({
    required super.restaurantId,
    required super.restaurantName,
    required super.amount,
    required super.formattedAmount,
    super.isCredit,
    super.counterpartyType,
    super.confirmedAt,
    super.details,
    super.paidTowardsOrders,
  });

  /// Safely parses a value that might be a num or a String to double
  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// [isCredit]: the list it came in says it (the manager's debts are
  /// positive amounts); without it, the amount's sign.
  factory RestaurantDebtModel.fromJson(
    Map<String, dynamic> json, {
    bool? isCredit,
  }) {
    // Handle both old and new API formats
    // New format uses 'balance' instead of 'amount'
    // New format uses 'counterparty_id' instead of 'restaurant_id'

    final balancedRaw = json['balance'] ?? json['amount'];
    final double rawAmount = _parseDouble(balancedRaw);
    final double amount = rawAmount.abs(); // Keep amount positive

    // A restaurant's counterparty id is its owner's user id; the payment endpoints
    // take the restaurant's own id, sent beside it (paid by the owner's id, a
    // payment was refused, or went to another restaurant)
    final id = json['restaurant_id'] ?? json['counterparty_id'] ?? 0;
    final name =
        json['counterparty_name'] ?? json['restaurant_name'] ?? 'Unknown';
    final typeRaw = json['counterparty_type'] ?? json['type'];
    final counterpartyType = typeRaw?.toString() ??
        ((id is int ? id : int.tryParse(id.toString()) ?? 0) == 0
            ? 'system'
            : 'restaurant');

    // Attempt to parse a date
    DateTime? confirmedAt;
    final dateRaw =
        json['last_settlement_at'] ??
        json['last_transaction_at'] ??
        json['confirmed_at'];
    if (dateRaw != null) {
      if (dateRaw is String) {
        confirmedAt = tryParseServerTime(dateRaw);
      } else if (dateRaw is DateTime) {
        confirmedAt = dateRaw;
      }
    }

    // Parse details if available
    final detailsList =
        (json['details'] as List<dynamic>?)
            ?.map((e) => DriverCreditDebtDetailModel.fromJson(e))
            .toList() ??
        [];

    return RestaurantDebtModel(
      restaurantId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      restaurantName: name.toString(),
      amount: amount,
      formattedAmount:
          json['formatted_amount'] as String? ??
          '${amount.toStringAsFixed(2)} ${Currency.dzd.code}',
      isCredit: isCredit ?? rawAmount > 0,
      counterpartyType: counterpartyType,
      confirmedAt: confirmedAt,
      details: detailsList,
      paidTowardsOrders: json['paid_towards_orders'] == null
          ? null
          : _parseDouble(json['paid_towards_orders']),
    );
  }
}
